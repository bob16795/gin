import math

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

proc `+`*(p: Vector, i: float32): Vector =
  result = p
  result.X += i
  result.Y += i

proc `-`*(p: Vector, i: float32): Vector =
  result = p
  result.X = (result.X - i).float32
  result.Y = (result.Y - i).float32

proc distance*(a, b: Vector): float =
  var c: Vector
  c.X = a.X - b.X
  c.Y = a.Y - b.Y
  return sqrt((c.X * c.X + c.Y * c.Y).float)

proc angle*(p: Vector): float32 =
  return arctan2(p.X, p.Y)

proc setAngle*(p: var Vector, radians: float32) =
  p.X = cos(radians)
  p.Y = sin(radians)

proc rotated*(p: Vector; phi: float32): Vector =
  result.setAngle(phi + p.angle)
  result = result * p.distance(initVector(0, 0))
