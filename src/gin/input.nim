import sdl2 except Point
import graphics

type
    KeyboardState* = object
      pressedkeys*: seq[Scancode]
      modifiers*: Keymod
    MouseState* = object
      position*: Point
      pressedButtons*: seq[uint8]
    JoypadState* = object
      axis*: seq[int]
      pressedButtons*: seq[uint8]

var currentKeyboardState: KeyboardState
var currentMouseState: MouseState
var currentJoypadState: JoypadState
var currentWindowSize: Point

# returns true if the program should end
proc processQuitEvents*(): bool =
  var e: Event
  while pollEvent(e):
    case e.kind:
      of QuitEvent:
        return true
      of WindowEvent:
        if e.window.event == WindowEvent_Resized:
          currentWindowSize = initPoint(e.window.data1, e.window.data2)
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
      of JoyAxisMotion:
        while len(currentJoypadState.axis) < e.jaxis.axis.int:
          currentJoypadState.axis.add(0)
        currentJoypadState.axis[e.jaxis.axis] = e.jaxis.value.int
      of JoyButtonDown:
        if not currentJoypadState.pressedButtons.contains(e.jbutton.button):
           currentJoypadState.pressedButtons.add(e.jbutton.button)
           return
      of JoyButtonUp:
        if currentJoypadState.pressedButtons.contains(e.jbutton.button):
          for i in 0..currentJoypadState.pressedButtons.len():
            if (currentJoypadState.pressedButtons[i] == e.jbutton.button):
              currentJoypadState.pressedButtons.del(i)
              break
      of WindowEvent:
        if e.window.event == WindowEvent_Resized:
          currentWindowSize = initPoint(e.window.data1, e.window.data2)
      else:
        discard

proc initInput*(data: GraphicsInitData) =
  currentKeyboardState.pressedkeys = @[]
  currentWindowSize = data.size

proc getKeyBoardState*(): KeyboardState =
  return currentKeyboardState

proc getMouseState*(): MouseState =
  return currentMouseState

proc getJoypadState*(): JoypadState =
  return currentJoypadState

proc getWindowSize*(): Point =
  return currentWindowSize

proc contains*(state: KeyboardState, code: Scancode): bool =
  return state.pressedkeys.contains(code)
