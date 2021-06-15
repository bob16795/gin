import gin/graphics
import gin/input
import nimgl/glfw

type
    Storage = object
        window: GLFWWindow

var internal: Storage 

template Setup*(setupContent: untyped): untyped =
    internal.window = initGraphics()
    initInput(internal.window)
    setupContent

template Loop*(loopContent: untyped): untyped =
    var running = true
    proc stopLoop(w: GLFWWindow): void {.cdecl.} =
        running = false
    template endLoop(): untyped =
        running = false
    discard internal.window.setWindowCloseCallback(stopLoop)
    while running:
        glfwPollEvents()
        clearBuffer(internal.window)
        loopContent