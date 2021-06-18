import gin/graphics
import gin/storage

template WindowTemplates*(context: GraphicsContext, data: GraphicsInitData): untyped =

    # set the window name
    template setWindowName(d: string): untyped =
        data.name = d
        
    # set the window size
    template setWindowSize(size: Point): untyped =
        data.size = size

    # set the app name IMPORTANT !!!
    template setAppName(name: string): untyped =
        storage.APPNAME = name