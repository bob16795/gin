import nimgl/glfw
import opengl

type
    KeyboardState* = object
        pressedkeys*: seq[int32]
        modifiers*: int32

var currentKeyboardState: KeyboardState

proc inputKeyProc(window: GLFWWindow, key: int32, scancode: int32,
                   action: int32, mods: int32): void {.cdecl.} =
    if action == GLFWPress and not currentKeyboardState.pressedkeys.contains(key):
        currentKeyboardState.pressedkeys.add(key)
    if action == GLFWRelease and currentKeyboardState.pressedkeys.contains(key):
        for i in 1..high(currentKeyboardState.pressedkeys):
            if currentKeyboardState.pressedkeys[i] == key:
                currentKeyboardState.pressedkeys.del(i)
                break
    currentKeyboardState.modifiers = mods

proc initInput*(window: GLFWWindow) =
    discard window.setKeyCallback(inputKeyProc)
    window.makeContextCurrent()
    currentKeyboardState.pressedkeys = @[]
    currentKeyboardState.modifiers = 0

proc getKeyBoardState*(): KeyboardState =
    return currentKeyboardState