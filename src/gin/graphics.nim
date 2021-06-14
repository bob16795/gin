# Preston precourt 2021
# this will store data types and processes
# for drawing in gin

type
  Point* = object
    X*: int
    Y*: int
  Rectangle* = object
    X*: int
    Y*: int
    Width*: uint
    Height*: uint

proc InitPoint*(X, Y: int): Point =
  result.X = X
  result.Y = Y

proc InitRectangle*(X, Y: int, Width, Height: uint): Rectangle =
  result.X = X
  result.Y = Y
  result.Width = Width
  result.Height = Height