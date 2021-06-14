import gin
import gin/input
import nimgl/glfw


var kbState: KeyBoardState
var prevState: KeyBoardState

Setup:
    discard

Loop:
    prevState = kbState
    kbState = getKeyBoardState()
    if kbState.pressedkeys.contains(GLFWKey.ESCAPE):
        EndLoop
