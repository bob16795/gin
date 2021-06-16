import gin
import gin/input
import gin/graphics
from sdl2 import Scancode

var kbState: KeyBoardState
var prevState: KeyBoardState

Setup:
    var
        image: Texture = loadTexture("images/ssss.bmp")
        bg = initColor(255, 255, 255, 255)

Loop:
    template draw(time: cuint, context: GraphicsContext): untyped =
        clearBuffer(bg)
        renderTexture(image, initRectangle(0, 0, 100, 100), initRectangle(0, 0, 100, 100))

    template update(time: cuint): untyped =
        prevState = kbState
        kbState = getKeyBoardState()
        if kbState.contains(SDL_SCANCODE_ESCAPE):
            endLoop
