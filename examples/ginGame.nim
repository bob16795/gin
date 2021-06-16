import gin
import gin/input
import gin/graphics
import nimgl/glfw


var kbState: KeyBoardState
var prevState: KeyBoardState

Setup:
    var image: Texture = loadTexture("images/ssss.png", internal.shader)

Loop:
    prevState = kbState
    kbState = getKeyBoardState()
    renderTexture(image, InitRectangle(2, 2, 100, 100), InitRectangle(100, 100, 1000, 1000))
    if kbState.pressedkeys.contains(GLFWKey.ESCAPE):
        endLoop
