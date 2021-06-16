import gin/graphics
import gin/input
import sdl2

type
    Storage = object
        gContext: GraphicsContext

var internalStorage: Storage

template Game*(gameTemplates: untyped): untyped =
    var
        # internal variables for time
        newTime, frameTime, currentTime: cuint
        dt: cuint = 167
        accumulator: cuint
        # bool to stop the loop
        running = true

    # setup stop loop to close window
    proc stopLoop(): void {.cdecl.} =
        running = false

    template endLoop(): untyped =
        running = false
    template internal: untyped =
        internalStorage
    template deltaTime: untyped =
        frameTime

    # load templates and vars from the game file
    gameTemplates

    # init the graphics device
    internalStorage.gContext = initGraphics()
    initInput()

    # run the setup template from the game
    setup()

    # start the main loop
    while running:
        # update deltatime
        newTime = getTicks()
        frameTime = newTime - currentTime
        currentTime = newTime
        accumulator += frameTime

        # process keyboard events
        if processEvents(): endLoop

        # run update everty dt mills
        while (accumulator >= dt):
            echo "update"
            update(frameTime)
            accumulator -= dt
        
        # run the draw template in the game file
        draw(frameTime, context)

        # finish rendering
        renderFinish()