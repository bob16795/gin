import gin/graphics
import gin/input
import gin/templates
import gin/sound
import sdl2

type
    Storage = object
        gContext: GraphicsContext

var internalStorage: Storage

template Game*(gameTemplates: untyped): untyped =
    var
        # internal variables for time
        newTime, frameTime, currentTime: cuint
        dt: cuint = 17
        accumulator: cuint
        # bool to stop the loop
        running = true
        # graphics init data
        gInitData = initGraphicsInitData()

    # setup stop loop to close window
    template endLoop(): untyped =
        running = false
    template internal: untyped =
        internalStorage
    template deltaTime: untyped =
        frameTime
    
    WindowTemplates(context, gInitData)

    # load templates and vars from the game file
    gameTemplates

    # init data
    Initialize()

    # init the graphics device
    internalStorage.gContext = initGraphics(gInitData)
    initInput()
    initSound()

    # run the setup template from the game
    Setup()

    # start the main loop
    while running:
        # update deltatime
        newTime = getTicks()
        frameTime = newTime - currentTime
        currentTime = newTime
        accumulator += frameTime

        # run update everty dt mills
        while (accumulator >= dt):
            # process keyboard events
            if processEvents(): endLoop
            
            # run the update template in the game file
            Update(dt)

            # frame executed
            accumulator -= dt
        
        # run the draw template in the game file
        Draw(frameTime, context)

        # finish rendering
        renderFinish()
    Close()
