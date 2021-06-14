import gin/graphics
import gin/input
import nimgl/glfw

template Setup*(setupContent: untyped): untyped =
    var w* = initGraphics()
    initInput(w)
    setupContent

template Loop*(loopContent: untyped): untyped =
    var running = true
    template EndLoop(): untyped =
        running = false
    while running:
        glfwPollEvents()
        loopContent