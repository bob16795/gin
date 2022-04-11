import math
import graphics

type 
  Vector* = object
    X*: float32
    Y*: float32

proc initVector*(X, Y: float32): Vector=
  result.X = X
  result.Y = Y

proc `*`*(p: Vector, i: float32): Vector =
  result = p
  result.X *= i
  result.Y *= i

proc `/`*(p: Vector, i: float32): Vector =
  result = p
  result.X = (result.X / i).float32
  result.Y = (result.Y / i).float32

proc `+`*(p: Vector, i: Vector): Vector =
  result = p
  result.X += i.X
  result.Y += i.Y

proc `-`*(p: Vector, i: Vector): Vector =
  result = p
  result.X = (result.X - i.X).float32
  result.Y = (result.Y - i.Y).float32

proc distance*(a, b: Vector): float =
  var c: Vector
  c.X = a.X - b.X
  c.Y = a.Y - b.Y
  return sqrt((c.X * c.X + c.Y * c.Y).float)

proc mag*(v: Vector): float =
  return distance(v, initVector(0, 0))

proc norm*(v: Vector): Vector =
  return v / v.mag()

proc angle*(p: Vector): float32 =
  return arctan2(p.Y, p.X)

proc setAngle*(p: var Vector, radians: float32) =
  p.X = cos(radians)
  p.Y = sin(radians)

proc rotated*(p: Vector; phi: float32): Vector =
  result.setAngle(phi + p.angle)
  result = result * sqrt((p.X * p.X + p.Y * p.Y).float)

proc Point*(p: Vector): Point =
  result = initPoint(p.X.cint, p.Y.cint)

proc toVector*(p: Point): Vector =
  result = initVector(p.X.float32, p.Y.float32)

proc lerp*(a, b: Vector, t: float32): Vector =
  result = a
  result.X += t * (b.X - a.X)
  result.Y += t * (b.Y - a.Y)
