import sdl2/audio
import sdl2

{.experimental: "codeReordering".}

const
    AUDIO_FORMAT = AUDIO_S16LSB
    AUDIO_FREQ = 44100
    AUDIO_CHANNELS = 2
    AUDIO_SAMPLES = 4096
    AUDIO_MAX_SOUNDS = 25
    AUDIO_MUSIC_FADE_VALUE = 2
    AUDIO_ALLOW_CHANGES = SDL_AUDIO_ALLOW_FREQUENCY_CHANGE or SDL_AUDIO_ALLOW_CHANNELS_CHANGE

type
    PrivateAudioDevice* = object
        device*: AudioDeviceID
        want*: AudioSpec
        audioEnable*: uint8
    Audio* {.bycopy.} = object
        length*: uint32
        lengthTrue*: uint32
        bufferTrue*: ptr uint8
        buffer*: ptr uint8
        loop*: uint8
        fade*: uint8
        free*: uint8
        volume*: uint8
        audio*: AudioSpec
        next*: ptr Audio

var
    gDevice: ptr PrivateAudioDevice
    gSoundCount: uint32

proc playSound*(filename: cstring, volume: cint) =
    playAudio(filename, nil, 0, volume)

proc playMusic*(filename: cstring, volume: cint) =
    playAudio(filename, nil, 1, volume)

proc playSoundFromMemory*(audio: ptr Audio, volume: cint) =
    playAudio(nil, audio, 0, volume)

proc playMusicFromMemory*(audio: ptr Audio, volume: cint) =
    playAudio(nil, audio, 1, volume)

proc initAudio*() =
    var global: ptr Audio
    gDevice = cast[ptr PrivateAudioDevice](alloc(sizeof(PrivateAudioDevice)))
    gSoundCount = 0
    if gDevice == nil:
        echo "AUDIO COULDNT BE LOADED"
        return
    zeroMem(addr gDevice.want, sizeof(gDevice.want))
    gDevice.want.freq = AUDIO_FREQ
    gDevice.want.format = AUDIO_FORMAT
    gDevice.want.channels = AUDIO_CHANNELS
    gDevice.want.samples = AUDIO_SAMPLES
    gDevice.want.callback = audioCallback
    gDevice.want.userdata = alloc(sizeof(Audio))
    global = cast[ptr Audio](gDevice.want.userdata)
    if global == nil:
        echo ":|"
        return
    global.buffer = nil
    global.next = nil
    gDevice.device = openAudioDevice(nil, 0, addr(gDevice.want), nil, AUDIO_ALLOW_CHANGES)
    if gDevice.device == 0:
        echo "cant open audio dev"
        return
    else:
        gDevice.audioEnable = 1
        unpauseAudio()

proc endAudio*() =
    if gDevice.audioEnable != 0:
        pauseAudio()
        freeAudio(cast[ptr Audio](gDevice.want.userdata))
        closeAudioDevice(gDevice.device)

proc pauseAudio*() =
    if gDevice.audioEnable != 0:
        pauseAudioDevice(gDevice.device, 1)

proc unpauseAudio*() =
    if gDevice.audioEnable != 0:
        pauseAudioDevice(gDevice.device, 0)

proc freeAudio*(a: ptr Audio) =
    var temp, audio: ptr Audio
    audio = a
    while audio != nil:
        if audio.free == 1:
            freeWAV(audio.bufferTrue)
        temp = audio
        audio = audio.next
        discard temp.free

proc createAudio*(filename: cstring, loop: uint8, volume: cint): ptr Audio =
    var newAudio: ptr Audio = cast[ptr Audio](alloc(sizeof(Audio)))
    if newAudio == nil:
        echo "couldnt load audio: " & $filename
        return nil
    if filename == nil:
        echo "filename is nil"
        return nil
    newAudio.next = nil
    newAudio.loop = loop
    newAudio.fade = 0
    newAudio.free = 1
    newAudio.volume = volume.uint8
    if loadWav($filename, addr newAudio.audio, addr newAudio.bufferTrue, addr newAudio.lengthTrue) == nil:
        echo "wav couldnt be loaded: " & $filename
        discard newAudio.free
        return nil
    newAudio.buffer = newAudio.bufferTrue
    newAudio.length = newAudio.lengthTrue
    newAudio.audio.callback = nil
    newAudio.audio.userdata = nil
    return newAudio

proc playAudio(filename: cstring, audio: ptr Audio, loop: uint8, volume: cint) =
    var newAudio: ptr Audio
    if gDevice.audioEnable == 0:
        return
    if loop == 0:
        if gSoundCount >= AUDIO_MAX_SOUNDS:
            return
        else:
            inc gSoundCount
    if filename != nil:
        newAudio = createAudio(filename, loop, volume)
    elif audio != nil:
        newAudio = cast[ptr Audio](alloc(sizeof(Audio)))
        copyMem(newAudio, audio, sizeof(Audio))
        newAudio.volume = volume.uint8
        newAudio.loop = loop
        newAudio.free = 0
    else:
        echo "all audio params are null"
        return
    lockAudioDevice(gDevice.device)
    if loop == 1:
        addMusic(cast[ptr Audio](gDevice.want.userdata), newAudio)
    else:
        addAudio(cast[ptr Audio](gDevice.want.userdata), newAudio)
    unlockAudioDevice(gDevice.device)

proc addMusic(root: ptr Audio, newAudio: ptr Audio) =
    var musicFound: uint8 = 0
    var rootNext: ptr Audio = root.next

    while rootNext != nil:
        if rootNext.loop == 1 and rootNext.fade == 0:
            if musicFound != 0:
                rootNext.length = 0
                rootNext.volume = 0
            rootNext.fade = 1
        elif rootNext.loop == 1 and rootNext.fade == 1:
            musicFound = 1
        rootNext = rootNext.next
    addAudio(root, newAudio)

proc audioCallback(userdata: pointer, stream: ptr uint8, len: cint) {.cdecl.} =
    var audio: ptr Audio = cast[ptr Audio](userdata)
    var previous: ptr Audio = audio
    var tempLength: uint32
    var music: uint8 = 0
    zeroMem(stream, len)
    audio = audio.next
    while audio != nil:
        if audio.length > 0:
            if audio.fade == 1 and audio.loop == 1:
                music = 1
                if audio.volume > 0:
                    if audio.volume - AUDIO_MUSIC_FADE_VALUE < 0:
                        audio.volume = 0
                    else:
                        dec(audio.volume, AUDIO_MUSIC_FADE_VALUE)
                else:
                    audio.length = 0
            if music != 0 and audio.loop == 1 and audio.fade == 0:
                tempLength = 0
            else:
                if (cast[uint32](len) > audio.length):
                    tempLength = audio.length
                else:
                    tempLength = cast[uint32](len)
            mixAudioFormat(stream, audio.buffer, AUDIO_FORMAT, tempLength, audio.volume.cint)
            audio.buffer = cast[ptr uint8](cast[int](audio.buffer) + tempLength.int)
            audio.length -= tempLength
            previous = audio
            audio = audio.next
        elif audio.loop == 1 and audio.fade == 0:
            audio.buffer = audio.bufferTrue
            audio.length = audio.lengthTrue
        else:
            previous.next = audio.next
            if (audio.loop == 0):
                dec(gSoundCount)
            audio.next = nil
            freeAudio(audio)
            audio = previous.next

proc addAudio*(r: ptr Audio, newAudio: ptr Audio) =
    var root = r
    if root == nil:
        return
    while root.next != nil:
        root = root.next
    root.next = newAudio