# Preston precourt 2021
# this will store data types and processes
# for drawing in gin
import nimgl/glfw
import opengl
import sugar

type
  Point* = object
    X*: int
    Y*: int
  Rectangle* = object
    X*: int
    Y*: int
    Width*: uint
    Height*: uint

proc initGraphics*(keyProc: (GLFWWindow, int32, int32, int32, int32) -> void): GLFWWindow =
  assert glfwInit()
  var window = glfwCreateWindow(800, 600, "GIN Game Window")
  assert window != nil
  assert not glInit()
  return window

proc InitPoint*(X, Y: int): Point =
  result.X = X
  result.Y = Y

proc InitRectangle*(X, Y: int, Width, Height: uint): Rectangle =
  result.X = X
  result.Y = Y
  result.Width = Width
  result.Height = Height