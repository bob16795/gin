import sdl2 except Point
import graphics

type
    KeyboardState* = object
        pressedkeys*: seq[Scancode]
        modifiers*: Keymod
    MouseState* = object
        position*: Point
        pressedButtons*: seq[uint8]

var currentKeyboardState: KeyboardState
var currentMouseState: MouseState

# returns true if the program should end
proc processQuitEvents*(): bool =
    var e: Event
    while pollEvent(e):
        case e.kind:
            of QuitEvent:
                return true
            else:
                discard

proc processEvents*(): bool =
    currentKeyboardState.modifiers = getModState()
    var e: Event
    while pollEvent(e):
        case e.kind:
            of QuitEvent:
                return true
            of KeyDown:
                if not currentKeyboardState.pressedkeys.contains(e.key.keysym.scancode):
                    currentKeyboardState.pressedkeys.add(e.key.keysym.scancode)
                    return
            of KeyUp:
                if currentKeyboardState.pressedkeys.contains(e.key.keysym.scancode):
                    for i in 0..currentKeyboardState.pressedkeys.len():
                        if (currentKeyboardState.pressedkeys[i] == e.key.keysym.scancode):
                            currentKeyboardState.pressedkeys.del(i)
                            break
            of MouseMotion:
                currentMouseState.position.X = e.motion.x
                currentMouseState.position.Y = e.motion.y
            of MouseButtonDown:
                if not currentMouseState.pressedButtons.contains(e.button.button):
                    currentMouseState.pressedButtons.add(e.button.button)
                    return
            of MouseButtonUp:
                if currentMouseState.pressedButtons.contains(e.button.button):
                    for i in 0..currentMouseState.pressedButtons.len():
                        if (currentMouseState.pressedButtons[i] == e.button.button):
                            currentMouseState.pressedButtons.del(i)
                            break
            else:
                discard

proc initInput*() =
    currentKeyboardState.pressedkeys = @[]

proc getKeyBoardState*(): KeyboardState =
    return currentKeyboardState

proc getMouseState*(): MouseState =
    return currentMouseState

proc contains*(state: KeyboardState, code: Scancode): bool =
    return state.pressedkeys.contains(code)