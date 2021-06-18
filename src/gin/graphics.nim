# Preston precourt 2021
# this will store data types and processes
# for drawing in gin
import sdl2
import sdl2/ttf
import os
import math

type
  Point* = object
    X*: cint
    Y*: cint
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
  FontFace* = object
    fnt*: FontPtr
    size*: cint


  GraphicsContext* = object
    window*: WindowPtr
    renderer: RendererPtr
  GraphicsInitData* = object
    name*: string
    size*: Point
  Texture* = object
    surface: SurfacePtr
    texture: TexturePtr

var context*: GraphicsContext

proc Rect(r: Rectangle): Rect =
  result.x = r.X
  result.y = r.Y
  result.w = r.Width
  result.h = r.Height

proc initGraphics*(data: GraphicsInitData): GraphicsContext =
  result.window = createWindow(data.name, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, data.size.X, data.size.Y, 0)
  result.renderer = createRenderer(result.window, -1, 0)
  context = result
  ttfInit()
  return result

proc loadTexture*(image: string): Texture =
  result.surface = loadBMP(getAppDir() / image)
  if result.surface == nil:
    echo "Failed to load image " & image
    quit(1)
  result.texture = createTextureFromSurface(context.renderer, result.surface)

proc draw*(tex: var Texture, srcRect: Rectangle, destRect: Rectangle, angle: float32 = 0) =
  var
    src = srcRect.Rect
    dst = destRect.Rect
  copyEx(context.renderer, tex.texture, addr src, addr dst, angle, nil)

proc clearBuffer*(c: Color) =
  context.renderer.setDrawColor(c.r, c.g, c.b, c.a)
  context.renderer.clear()

proc initPoint*(X, Y: cint): Point =
  result.X = X
  result.Y = Y

proc initRectangle*(X, Y: cint, Width, Height: cint): Rectangle =
  result.X = X
  result.Y = Y
  result.Width = Width
  result.Height = Height

proc initRectangle*(position, size: Point): Rectangle =
  result.X = position.X
  result.Y = position.Y
  result.Width = size.X
  result.Height = size.Y

proc size*(r: Rectangle): Point =
  result.X = r.Width
  result.Y = r.Height

proc location*(r: Rectangle): Point =
  result.X = r.X
  result.Y = r.Y

proc `location=`*(r: var Rectangle, p: Point) =
  r.X = p.X
  r.Y = p.Y

proc initColor*(r, g, b, a: uint8): Color =
  result.r = r
  result.g = g
  result.b = b
  result.a = a

proc renderFinish*() =
  context.renderer.present()

proc initGraphicsInitData*(): GraphicsInitData =
  result.name = "Gin Game"
  result.size = initPoint(640, 480)

proc `*`*(p: Point, i: cint): Point =
  result = p
  result.X *= i
  result.Y *= i

proc center*(r: Rectangle): Point =
  return initPoint(r.X + (r.Width / 2).cint, r.Y + (r.Height / 2).cint)

proc distance*(a, b: Point): float =
  var c: Point
  c.X = a.X - b.X
  c.Y = a.Y - b.Y
  return sqrt((c.X * c.X + c.Y * c.Y).float)

proc renderText*(face: FontFace, pos: Point,text: string, fgc: Color) =
  var
    fg = sdl2.color(fgc.r, fgc.g, fgc.b, fgc.a)
    surface = renderTextBlended(face.fnt, text, fg)
  var
    texture = context.renderer.createTextureFromSurface(surface)
    tw, th: cint
  discard face.fnt.sizeText(text, addr tw, addr th)
  var
    srcr = initRectangle(0, 0, tw, th).Rect
    dstr = initRectangle(pos, initPoint(tw, th)).Rect
  copy(context.renderer, texture, addr srcr, addr dstr)

proc initFontFace*(name: string, size: cint): FontFace =
  result.fnt = openFont(getAppDir() / name, size)
  result.size = size