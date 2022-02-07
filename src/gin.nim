import gin/graphics
import gin/input
import gin/templates
import gin/sound
import sdl2
import os
import asyncdispatch
export asyncdispatch

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
        # percent loaded
        pc {.global.}: float = 0
        loadStatus: string = "Loading"

    # setup stop loop to close window
    template endLoop(): untyped =
        running = false
    template internal: untyped =
        internalStorage
    template deltaTime: untyped =
        frameTime
    template setDt(value: int): untyped =
        dt = value

    WindowTemplates(context, gInitData)

    # load templates and vars from the game file
    gameTemplates

    # init data
    Initialize()

    if sdl2.init(INIT_AUDIO) != SdlSuccess:
        quit "failed to init SDL2!"

    # init the graphics device
    internalStorage.gContext = initGraphics(gInitData)
    initInput(gInitData)
    initAudio()

    # run the setup template from the game
    proc setupProcthing() {.async.} =
        template setPercent(perc: float): untyped =
            pc = perc
        template setStatus(status: string): untyped =
            loadStatus = status
        Setup()
        endLoop()
    
    asyncCheck setupProcthing()
    while running:
      poll()
      if processQuitEvents(): endLoop
      drawLoading(pc, loadStatus)
      renderFinish()
    
    running = true
    # start the main loop
    while running:
        # update deltatime
        newTime = getTicks()
        frameTime = newTime - currentTime
        currentTime = newTime
        accumulator += frameTime

        # run update everty dt mills
        # process keyboard events
        if processEvents(): endLoop
        
        # run the update template in the game file
        Update(accumulator)

        # frame executed
        accumulator = 0
        
        # run the draw template in the game file
        Draw(frameTime, context)

        # finish rendering
        renderFinish()
    Close()
