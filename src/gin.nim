import gin/graphics
import gin/input
import sdl2

type
    Storage = object
        gContext: GraphicsContext

var internalStorage: Storage

template Setup*(setupContent: untyped): untyped =
    internalStorage.gContext = initGraphics()
    initInput()
    template internal: untyped =
        internalStorage
    setupContent

template Loop*(loopTemplates: untyped): untyped =
    var
        newTime, frameTime, currentTime: cuint
        dt: cuint = 167
        accumulator: cuint
        running = true

    # setup stop loop to close window
    proc stopLoop(): void {.cdecl.} =
        running = false

    template endLoop(): untyped =
        running = false
    template internal: untyped =
        internalStorage
    template draw: untyped =
        not(accumulator >= dt)
    template deltaTime: untyped =
        frameTime

    loopTemplates

    while running:
        newTime = getTicks()
        frameTime = newTime - currentTime
        currentTime = newTime
        accumulator += frameTime

        if processEvents(): endLoop
        while (not draw):
            echo "update"
            update(frameTime)
            accumulator -= frameTime
        if (draw):
            echo "draw"
            draw(frameTime, context)
            renderFinish()