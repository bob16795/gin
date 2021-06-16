# Preston precourt 2021
# this will store data types and processes
# for drawing in gin
import sdl2
import os

type
  Point* = object
    X*: int
    Y*: int
  Rectangle* = object
    X*: cint
    Y*: cint
    Width*: cint
    Height*: cint
  Color* = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8

  GraphicsContext* = object
    window: WindowPtr
    renderer: RendererPtr
  Texture* = object
    surface: SurfacePtr
    texture: TexturePtr

var context*: GraphicsContext

proc Rect(r: Rectangle): Rect =
  result.x = r.X
  result.y = r.Y
  result.w = r.Width
  result.h = r.Height

proc initGraphics*(): GraphicsContext =
  result.window = createWindow("Gin Game", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0)
  result.renderer = createRenderer(result.window, -1, 0)
  context = result
  return result

proc loadTexture*(image: string): Texture =
  result.surface = loadBMP(getAppDir() / image)
  if result.surface == nil:
    echo "Failed to load image " & image
    quit(1)
  result.texture = createTextureFromSurface(context.renderer, result.surface)

proc renderTexture*(tex: var Texture, srcRect: Rectangle, destRect: Rectangle) =
  var
    src = srcRect.Rect
    dst = destRect.Rect
  copy(context.renderer, tex.texture, addr src, addr dst)

proc clearBuffer*(c: Color) =
  context.renderer.setDrawColor(c.r, c.g, c.b, c.a)
  context.renderer.clear()

proc initPoint*(X, Y: int): Point =
  result.X = X
  result.Y = Y

proc initRectangle*(X, Y: cint, Width, Height: cint): Rectangle =
  result.X = X
  result.Y = Y
  result.Width = Width
  result.Height = Height

proc initColor*(r, g, b, a: uint8): Color =
  result.r = r
  result.g = g
  result.b = b
  result.a = a

proc renderFinish*() =
  context.renderer.present()