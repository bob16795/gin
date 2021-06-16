import gin
import gin/input
import gin/graphics
from sdl2 import Scancode

Game:
    var
        image: Texture 
        bg: Color

        kbState: KeyBoardState
        prevKbState: KeyBoardState

    proc checkSinglePress(code: Scancode): bool =
        return kbState.contains(code) and not prevKbState.contains(code)

    template Initialize(): untyped =
        # setWindowSize(initPoint(100, 100))
        setWindowName("lmao")

    template Setup(): untyped =
        image = loadTexture("images/ssss.bmp")
        bg = initColor(255, 255, 255, 255)

    template Draw(time: cuint, context: GraphicsContext): untyped =
        clearBuffer(bg)
        draw(image, initRectangle(0, 0, 100, 100), initRectangle(0, 0, 100, 100))

    template Update(time: cuint): untyped =
        prevKbState = kbState
        kbState = getKeyBoardState()
        if checkSinglePress(SDL_SCANCODE_ESCAPE):
            endLoop