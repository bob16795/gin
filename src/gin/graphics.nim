# Preston precourt 2021
# this will store data types and processes
# for drawing in gin
import sdl2
import sdl2/ttf
import math
import storage
export sdl2.DisplayMode

type
  Point* = object
    X*: cint
    Y*: cint
  Rectangle* = object of RootObj
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
    valid*: bool
    fnt*: FontPtr
    size*: cint
  GraphicsContext* = object
    window*: WindowPtr
    renderer: RendererPtr
  GraphicsInitData* = object
    name*: string
    size*: Point
  Texture* = object
    texture: TexturePtr

var
  context*: GraphicsContext

proc Rect(r: Rectangle): Rect =
  result.x = r.X
  result.y = r.Y
  result.w = r.Width
  result.h = r.Height

proc initGraphics*(data: GraphicsInitData): GraphicsContext =
  result.window = createWindow(data.name, SDL_WINDOWPOS_UNDEFINED,
      SDL_WINDOWPOS_UNDEFINED, data.size.X, data.size.Y, SDL_WINDOW_RESIZABLE)

  result.renderer = createRenderer(result.window, -1, 0)
  discard setDrawBlendMode(result.renderer, BLENDMODE_BLEND);
  context = result
  ttfInit()
  return result

proc setFullscreen*(value: bool) =
  if value:
    discard setFullscreen(context.window, 1)
  else:
    discard setFullscreen(context.window, 0)

proc getDisplayModes*(): seq[DisplayMode] =
  var display_mode_count = getNumDisplayModes(0)
  if display_mode_count < 1:
    echo "You dont have any screens"
    quit(1)

  var mode: DisplayMode
  for i in 0..display_mode_count:
    discard getDisplayMode(0, i, mode)
    result &= mode

proc setDisplayMode*(dm: var DisplayMode) =
  discard setDisplayMode(context.window, addr dm)

proc loadTexture*(image: string): Texture =
  var surface = loadBMP(getFullFilePath(image))
  if surface == nil:
    echo "Failed to load image " & image
    quit(1)
  when defined(GinDebug):
    echo "loaded " & image
  result.texture = createTextureFromSurface(context.renderer, surface)
  freeSurface(surface)

proc loadTextureMem*(data: pointer, size: cint): Texture =
  var rw = rwFromMem(data, size)
  var surface = loadBMP_RW(rw, 0)
  if surface == nil:
    echo "Failed to load image"
    quit(1)
  when defined(GinDebug):
    echo "loaded an image"
  result.texture = createTextureFromSurface(context.renderer, surface)
  freeSurface(surface)

proc draw*(tex: var Texture, srcRect: Rectangle, destRect: Rectangle,
    c: graphics.Color, angle: float32 = 0) =
  var
    src = srcRect.Rect
    dst = destRect.Rect
  discard setTextureColorMod(tex.texture, c.r, c.g, c.b)
  copyEx(context.renderer, tex.texture, addr src, addr dst, angle, nil)
  discard setTextureColorMod(tex.texture, 255, 255, 255)


proc draw*(tex: var Texture, srcRect: Rectangle, destRect: Rectangle,
    angle: float32 = 0) =
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

proc `size=`*(r: var Rectangle, size: Point) =
  r.Width = size.X
  r.Height = size.Y

proc offset*(r: Rectangle, offset: Point): Rectangle =
  result.X = r.X + offset.X
  result.Y = r.Y + offset.Y
  result.Width = r.Width
  result.Height = r.Height

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

proc `/`*(p: Point, i: cint): Point =
  result = p
  result.X = (result.X / i).cint
  result.Y = (result.Y / i).cint

proc center*(r: Rectangle): Point =
  return initPoint(r.X + (r.Width / 2).cint, r.Y + (r.Height / 2).cint)

proc distance*(a, b: Point): float =
  var cx, cy: float32
  cx = (a.X - b.X).float32
  cy = (a.Y - b.Y).float32
  return sqrt(cx * cx + cy * cy)

proc renderText*(face: FontFace, pos: Point, text: string, fgc: Color) =
  try:
    var
      fg = sdl2.color(fgc.r, fgc.g, fgc.b, fgc.a)
      surface = renderUtf8Blended(face.fnt, text, fg)
      texture = context.renderer.createTextureFromSurface(surface)
      tw, th: cint
    discard face.fnt.sizeUtf8(text, addr tw, addr th)
    var
      srcr = initRectangle(0, 0, tw, th).Rect
      dstr = initRectangle(pos, initPoint(tw, th)).Rect
    copy(context.renderer, texture, addr srcr, addr dstr)
    freeSurface(surface)
    destroy(texture)
  except: echo ":("

proc sizeText*(face: FontFace, text: string): Point =
  var
    tw, th: cint
  discard face.fnt.sizeUtf8(text, addr tw, addr th)
  return initPoint(tw, th)

proc initFontFace*(name: string, size: cint): FontFace =
  result.fnt = openFont(getFullFilePath(name), size)
  result.size = size
  result.valid = true

proc `+`*(A, B: Point): Point =
  return initPoint(A.X + B.X, A.Y + B.Y)

proc `-`*(A, B: Point): Point =
  return initPoint(A.X - B.X, A.Y - B.Y)

proc drawOutline*(r: Rectangle, c: Color) =
  var rect = r.Rect
  setDrawColor(context.renderer, c.r, c.g, c.b, c.a)
  drawRect(context.renderer, rect)

proc drawFill*(r: Rectangle, c: Color) =
  var rect = r.Rect
  setDrawColor(context.renderer, c.r, c.g, c.b, c.a)
  fillRect(context.renderer, rect)

proc angle*(p: Point): float32 =
  return arctan2(p.X.float32, p.Y.float32)

proc setAngle*(p: var Point, radians: float32) =
  p.X = cos(radians).cint
  p.Y = sin(radians).cint

proc rotated*(p: Point; phi: float32): Point =
  result.setAngle(phi + p.angle)
  result = result * p.distance(initPoint(0, 0)).cint
