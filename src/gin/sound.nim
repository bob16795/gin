import sdl2
import sdl2/audio
import os
import storage

type
    SoundEffect* = object
        spec: AudioSpec
        length: uint32
        buffer: ptr uint8
        audioDevice: AudioDeviceID

proc initSound*() =
    init(INIT_AUDIO)

proc initSoundEffect*(path: string): SoundEffect =
    var
        spec: AudioSpec
        length: uint32
        buffer: ptr uint8
    discard loadWAV(getFullFilePath(path), addr spec, addr buffer, addr length)
    result.spec = spec
    result.length = length
    result.buffer = buffer
    result.audioDevice = openAudioDevice(nil, 0, addr result.spec, nil, 0)

proc play*(effect: SoundEffect) =
    var success = queueAudio(effect.audioDevice, effect.buffer, effect.length)
    pauseAudioDevice(effect.audioDevice, 0)

proc pause*(effect: SoundEffect) =
    pauseAudioDevice(effect.audioDevice, 1)