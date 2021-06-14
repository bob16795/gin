import graphics

template Setup*(a: untyped): untyped =
    initGraphics()
    initInput()
    a

template Loop*(loopContent: untyped): untyped =
    var running = true
    template EndLoop(): untyped =
        running = false
    while running:
        loopContent
    