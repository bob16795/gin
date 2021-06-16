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

    template setup(): untyped =
        image = loadTexture("images/ssss.bmp")
        bg = initColor(255, 255, 255, 255)

    template draw(time: cuint, context: GraphicsContext): untyped =
        clearBuffer(bg)
        renderTexture(image, initRectangle(0, 0, 50, 50), initRectangle(0, 0, 100, 100))

    template update(time: cuint): untyped =
        prevKbState = kbState
        kbState = getKeyBoardState()
        if kbState.contains(SDL_SCANCODE_ESCAPE):
            endLoop
