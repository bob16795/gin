# Preston precourt 2021
# this will store data types and processes
# for drawing in gin
import nimgl/glfw
import opengl
import lib/SOIL

type
  Point* = object
    X*: int
    Y*: int
  Rectangle* = object
    X*: int
    Y*: int
    Width*: uint
    Height*: uint

proc initGraphics*(): GLFWWindow =
  assert glfwInit()
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  var window = glfwCreateWindow(800, 600, "GIN Game Window")
  assert window != nil
  window.makeContextCurrent()
  assert glInit()
  return window

proc loadTexture*(image: cstring): ptr cuchar =
  var width, height: cint
  var c: cint = 0
  var img = SOIL_load_image(image, width.addr, height.addr, c.addr, SOIL_LOAD_RGBA)
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.GLint, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image)
  return img

proc clearBuffer*(window: GLFWWindow) =
  glClearColor(0.68f, 1f, 0.34f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  window.swapBuffers()

proc InitPoint*(X, Y: int): Point =
  result.X = X
  result.Y = Y

proc InitRectangle*(X, Y: int, Width, Height: uint): Rectangle =
  result.X = X
  result.Y = Y
  result.Width = Width
  result.Height = Height