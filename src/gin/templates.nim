import gin/graphics

template WindowTemplates*(context: GraphicsContext, data: GraphicsInitData): untyped =

    # set the window name
    template setWindowName(d: string): untyped =
        data.name = d
        
    # set the window size
    template setWindowSize(d: Point): untyped =
        data.size = d