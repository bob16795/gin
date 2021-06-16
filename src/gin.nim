import gin/graphics
import gin/input
import opengl
import nimgl/glfw

type
    Storage = object
        window: GLFWWindow
        shader: GLuint

var internalStorage: Storage 

template Setup*(setupContent: untyped): untyped =
    internalStorage.window = initGraphics()
    internalStorage.shader = initShader()
    initInput(internalStorage.window)
    template internal: untyped =
        internalStorage
    setupContent

template Loop*(loopContent: untyped): untyped =
    var
        newTime, frameTime, currentTime: float
        dt: float = 1 / 60
        accumulator: float
        running = true

    # setup stop loop to close window
    proc stopLoop(w: GLFWWindow): void {.cdecl.} =
        running = false
    discard internalStorage.window.setWindowCloseCallback(stopLoop)


    template endLoop(): untyped =
        running = false
    template internal: untyped =
        internalStorage
    template draw: untyped =
        not(accumulator >= dt)
    template deltaTime: untyped =
        frameTime

    while running:
        newTime = glfwGetTime()
        frameTime = newTime - currentTime
        currentTime = newTime

        if (draw):
            clearBuffer(internalStorage.window)
            renderStart(internalStorage.shader)
            glfwPollEvents()
        loopContent
        if (draw):
            renderFinish(internalStorage.window)