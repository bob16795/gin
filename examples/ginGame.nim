import gin
import gin/input
import gin/graphics


var kbState: KeyBoardState
var prevState: KeyBoardState

Setup:
    var
        image: Texture = loadTexture("images/ssss.bmp")
        bg: Color = initColor(255, 255, 255, 255)

Loop:
    template draw(time: cuint, context: GraphicsContext): untyped =
        clearBuffer(bg)
        renderTexture(image, initRectangle(0, 0, 100, 100), initRectangle(0, 0, 100, 100))

    template update(time: cuint): untyped =
        prevState = kbState
        kbState = getKeyBoardState()
        if kbState.pressedkeys.contains(0):
            endLoop
