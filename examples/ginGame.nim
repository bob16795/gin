import gin
import gin/input
import gin/graphics
import nimgl/glfw


var kbState: KeyBoardState
var prevState: KeyBoardState

Setup:
    discard
    var image: Texture = loadTexture("images/ssss.png")

Loop:
    prevState = kbState
    kbState = getKeyBoardState()
    if kbState.pressedkeys.contains(GLFWKey.ESCAPE):
        endLoop
