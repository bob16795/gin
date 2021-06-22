import sdl2
import sdl2/audio
import os
import storage

type
    SoundEffect* = object
        spec: AudioSpec
        length: uint32
        buffer: ptr uint8
    AudioData = object
        length: uint32
        position: ptr uint8

var 
    audioDevice: AudioDeviceID

proc initSound*() =
    init(INIT_AUDIO)

proc callback(userdata: pointer, stream: ptr uint8, len: cint) {.cdecl.} =
    var data = cast[AudioData](userdata)
    if data.length == 0:
        return
    var length = len.uint32
    if length > data.length:
        length = data.length

    mixAudio(stream, data.position, length, SDL_MIX_MAXVOLUME)

    data.position[] += length.uint8
    data.length -= length

proc initSoundEffect*(path: string): SoundEffect =
    var
        spec: AudioSpec
        length: uint32
        buffer: ptr uint8
    discard loadWAV(getFullFilePath(path), addr spec, addr buffer, addr length)
    result.spec = spec
    spec.callback = callback
    result.length = length
    result.buffer = buffer
    audioDevice = openAudioDevice(nil, 0, addr result.spec, nil, 0)


proc play*(effect: SoundEffect) =
    var success = queueAudio(audioDevice, effect.buffer, effect.length)
    pauseAudioDevice(audioDevice, 0)

proc pause*(effect: SoundEffect) =
    pauseAudioDevice(audioDevice, 1)