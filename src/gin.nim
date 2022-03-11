import gin/graphics
import gin/input
import gin/templates
import gin/sound
import sdl2
import os
import asyncdispatch
export asyncdispatch
import sdl2/joystick

type
  Storage = object
    gContext: GraphicsContext

var internalStorage: Storage



template Game*(gameTemplates: untyped): untyped =
  proc main() =
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

    if sdl2.init(INIT_EVERYTHING) != SdlSuccess:
      quit "failed to init SDL2!"

    # init the graphics device
    internalStorage.gContext = initGraphics(gInitData)
    initInput(gInitData)
    initAudio()

    # run the setup template from the game
    template setPercent(perc: float): untyped =
      pc = perc
      if processQuitEvents(): endLoop
      drawLoading(pc, loadStatus)
      renderFinish()
    template setStatus(status: string): untyped =
      loadStatus = status
      if processQuitEvents(): endLoop
      drawLoading(pc, loadStatus)
      renderFinish()
    Setup()

    # start the main loop
    while running:
      # update deltatime
      let now = getTicks()
      if frameTime > now:
        delay(frameTime - now) # Delay to maintain steady frame rate
      frameTime += dt
      var totalTime = frameTime - currentTime

      # run update everty dt mills
      # process keyboard events
      if processEvents(): endLoop

      # run the update template in the game file
      Update(totalTime)

      # run the draw template in the game file
      Draw(totalTime, context)

      # finish rendering
      renderFinish()

      currentTime = frameTime
    Close()
  main()
