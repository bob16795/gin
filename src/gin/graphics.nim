# Preston precourt 2021
# this will store data types and processes
# for drawing in gin
import nimgl/glfw
import opengl
import lib/SOIL

proc `$`[T](list: UncheckedArray[T]): string =
  result = "["
  for i in 0..11:
    result &= $list[i] & ", "
  result = result[0..^3]
  result &= "]"

type
  Point* = object
    X*: int
    Y*: int
  Rectangle* = object
    X*: int
    Y*: int
    Width*: uint
    Height*: uint
  Texture* = object
    id: GLuint
    size: Point
    vao: GLuint
    vbo: GLuint
    ubo: GLuint
    vertices: seq[int16]
    uvs: seq[float]

const
  vertexShader: string =
    "#version 330\n" &
    "layout (location = 0) in vec2 vert;\n" &
    "layout (location = 1) in vec2 _uv;\n" &
    "out vec2 uv;\n" &
    "void main()\n" &
    "{\n" &
    "  uv = _uv;\n" &
    "  gl_Position = vec4(vert.x / 400.0 - 1.0, vert.y / 300.0 - 1.0, 0.0, 1.0);\n" &
    "}\n"
  fragShader: string =
    "#version 330\n" &
    "out vec4 color;\n" &
    "in vec2 uv;\n" &
    "uniform sampler2D tex;\n" &
    "void main()\n" &
    "{\n" &
    "  color = vec4(1, 1, 1, 1);\n" &
    "  //color = texture(tex, uv);\n" &
    "}\n"

proc initGraphics*(): GLFWWindow =
  assert glfwInit()
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GL_FALSE.int32)
  var window = glfwCreateWindow(800, 600, "GIN Game Window")
  assert window != nil
  window.makeContextCurrent()
  assert glInit()
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glFrontFace(GL_CCW)
  glEnable(GL_BLEND)
  glDisable(GL_DEPTH_TEST)
  glDisable(GL_SCISSOR_TEST)

  var width, height: cint

  window.getFramebufferSize(addr width, addr height)

  glViewport(0, 0, width, height)
  return window

proc compileShader(source: cstring, shaderType: GLenum): GLuint =
  var shaderHandler: GLuint

  shaderHandler = glCreateShader(shaderType)
  var
    sourceptr = source
    
  glShaderSource(shaderHandler, 1'i32, addr sourceptr, nil)
  glCompileShader(shaderHandler)

  var success: GLint

  glGetShaderiv(shaderHandler, GL_COMPILE_STATUS, addr success)
  if (success == 0):
    var log: cstring = cast[cstring](alloc(512))
    var d: cint = 0
    glGetShaderInfoLog(shaderHandler, 512, addr d, log)
    echo log
    quit(1)
  return shaderHandler

proc getShaderProgramId(vertexFile, fragmentFile: cstring): GLuint =
  var programId, vertexHandler, fragmentHandler: GLuint

  vertexHandler = compileShader(vertexFile, GL_VERTEX_SHADER)
  fragmentHandler = compileShader(fragmentFile, GL_FRAGMENT_SHADER)

  programId = glCreateProgram()
  glAttachShader(programId, vertexHandler)
  glAttachShader(programId, fragmentHandler)
  glLinkProgram(programId)

  var success: GLint

  glGetProgramiv(programId, GL_LINK_STATUS, addr success)
  if (success == 0):
    var log: cstring = cast[cstring](alloc(512))
    var d: cint = 0
    glGetProgramInfoLog(programId, 512, addr d, log)
    echo log
    quit(1)

  glDeleteShader(vertexHandler)
  glDeleteShader(fragmentHandler)

  return programId

proc initShader*(): GLuint =
  result = getShaderProgramId(vertexShader, fragShader)
  glUseProgram(result)
  return result


proc loadTexture*(image: cstring, prog: GLuint): Texture =
  var width, height: cint
  var tex: Texture
  glGenTextures(1, addr tex.id)
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, tex.id)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.GLint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.GLint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST.GLint)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST.GLint)
  var img = SOIL_load_image(image, width.addr, height.addr, nil, SOIL_LOAD_RGB)
  if (img.isNil):
    echo "Image is Nil"
    return
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.GLint, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, img)
  SOIL_free_image_data(img)

  # setup size
  tex.size.X = width
  tex.size.Y = height

  # create buffers n stuff
  glGenVertexArrays(1, addr tex.vao)
  glGenBuffers(1, addr tex.vbo)
  glGenBuffers(1, addr tex.ubo)
  glUniform1i(glGetUniformLocation(prog, "tex"), 0)
  return tex

proc renderTexture*(tex: var Texture, srcRect: Rectangle, destRect: Rectangle) =
  echo "render"
  var
    x1 = destRect.X.int16
    y1 = destRect.Y.int16
    x2 = destRect.X.int16 + destRect.Width.int16
    y2 = destRect.Y.int16 + destRect.Height.int16
    u2 = (1 / tex.size.X) * (srcRect.X + srcRect.Width.int).float
    u1 = (1 / tex.size.X) * (srcRect.X).float
    v2 = (1 / tex.size.Y) * (srcRect.Y + srcRect.Height.int).float
    v1 = (1 / tex.size.Y) * (srcRect.Y).float

  tex.vertices = @[x2, y1,
                   x2, y2,
                   x1, y1,
                   
                   x2, y2,
                   x1, y2,
                   x1, y1]
  tex.uvs      = @[u2, v2,
                   u2, v1,
                   u1, v2,
                   
                   u2, v1,
                   u1, v1,
                   u1, v2]

  echo tex.vertices
  echo tex.uvs

  glBindTexture(GL_TEXTURE_2D, tex.id)
  glBindVertexArray(tex.vao)

  glBindBuffer(GL_ARRAY_BUFFER, tex.vbo)
  glBufferData(GL_ARRAY_BUFFER, cint(int16.sizeof * tex.vertices.len), tex.vertices.addr, GL_DYNAMIC_DRAW)
  var a: cint = 0
  glVertexAttribPointer(0, 2, EGL_SHORT, GL_FALSE.GLboolean, 2 * sizeof(int16), addr a)

  glBindBuffer(GL_ARRAY_BUFFER, tex.ubo)
  glBufferData(GL_ARRAY_BUFFER, cint(cfloat.sizeof * tex.uvs.len), tex.uvs.addr, GL_DYNAMIC_DRAW)
  var b: cint = 0
  glVertexAttribPointer(1, 2, EGL_FLOAT, GL_TRUE.GLboolean, 2 * sizeof(GLfloat), addr b)    
  glEnableVertexAttribArray(0)
  glEnableVertexAttribArray(1)

  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindVertexArray(0)

  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, tex.id)

  glBindVertexArray(tex.vao)
  glBindBuffer(GL_ARRAY_BUFFER, tex.vbo)
  glDrawArraysInstanced(GL_TRIANGLES, 0, 6, 1)
  glBindVertexArray(0)

proc clearBuffer*(window: GLFWWindow) =
  glClearColor(0.68f, 1f, 0.34f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)

proc InitPoint*(X, Y: int): Point =
  result.X = X
  result.Y = Y

proc InitRectangle*(X, Y: int, Width, Height: uint): Rectangle =
  result.X = X
  result.Y = Y
  result.Width = Width
  result.Height = Height

proc renderStart*(shader: GLuint) =
  echo "start"
  glUseProgram(shader)

proc renderFinish*(window: GLFWWindow) =
  echo "finish?"
  glUseProgram(0)
  window.swapBuffers()