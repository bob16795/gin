import sdl2

type
    KeyboardState* = object
        pressedkeys*: seq[Scancode]
        modifiers*: Keymod

var currentKeyboardState: KeyboardState

# returns true if the program should end
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
            of KeyUp:
                if not currentKeyboardState.pressedkeys.contains(e.key.keysym.scancode):
                    break
                for i in 0..currentKeyboardState.pressedkeys.len():
                    if (currentKeyboardState.pressedkeys[i] == e.key.keysym.scancode):
                        currentKeyboardState.pressedkeys.del(i)
                        break
            else:
                discard

proc initInput*() =
    currentKeyboardState.pressedkeys = @[]

proc getKeyBoardState*(): KeyboardState =
    return currentKeyboardState

proc contains*(state: KeyboardState, code: Scancode): bool =
    return state.pressedkeys.contains(code)