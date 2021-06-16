import sdl2

type
    KeyboardState* = object
        pressedkeys*: seq[int32]
        modifiers*: int32

var currentKeyboardState: KeyboardState

# returns true if the program should end
proc processEvent*(): bool =
    var e: Event
    while pollEvent(e):
        if e.kind == QuitEvent:
            return true



proc initInput*() =
    currentKeyboardState.pressedkeys = @[]
    currentKeyboardState.modifiers = 0

proc getKeyBoardState*(): KeyboardState =
    return currentKeyboardState