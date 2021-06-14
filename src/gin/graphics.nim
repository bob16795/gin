# Preston precourt 2021
# this will store data types and processes
# for drawing in gin

type
  Rectangle* = object
    X: int
    Y: int
    Width: uint
    Height: uint

proc InitRectangle*(X, Y: int, Width, Height: uint): Rectangle =
  result.X = X
  result.Y = Y
  result.Width = Width
  result.Height = Height