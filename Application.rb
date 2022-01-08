require 'opengl'
require 'glfw'
require 'rmath3d/rmath3d_plain'

require_relative 'Draw'
require_relative 'Camera'
require_relative 'MPRAlgorithm'
require_relative 'Shape'

def glfw_library_path()
  case GL.get_platform
  when :OPENGL_PLATFORM_WINDOWS
    Dir.pwd + '/glfw3.dll'
  when :OPENGL_PLATFORM_MACOSX
    './libglfw.dylib'
  when :OPENGL_PLATFORM_LINUX
    '/usr/lib/x86_64-linux-gnu/libglfw.so' # not tested
  else
    raise RuntimeError, "Unsupported platform."
  end
end

# module Fiddle
#   class Closure
#     class BlockCaller
#       def self.finalize(id)
#         puts "Object #{id} dying at #{Time.new}"
#       end
#     end
#   end
# end

class Application

  def draw
    @camera.load_camera_matrix()

    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL.PushAttrib(GL::ALL_ATTRIB_BITS)

    GL.Lightfv(GL::LIGHT0, GL::POSITION, [10,10,10,1].pack('F4'))
    GL.Lightfv(GL::LIGHT0, GL::DIFFUSE,  [1,1,1,1].pack('F4'))
    GL.Lightfv(GL::LIGHT0, GL::SPECULAR, [1,1,1,1].pack('F4'))
    GL.Lightfv(GL::LIGHT0, GL::AMBIENT,  [0.2,0.2,0.2,1].pack('F4'))

    GL.Lightfv(GL::LIGHT1, GL::POSITION, [-10,-10,-10,1].pack('F4'))
    GL.Lightfv(GL::LIGHT1, GL::DIFFUSE,  [1,1,1,1].pack('F4'))
    GL.Lightfv(GL::LIGHT1, GL::SPECULAR, [1,1,1,1].pack('F4'))
    GL.Lightfv(GL::LIGHT1, GL::AMBIENT,  [0.2,0.2,0.2,1].pack('F4'))

    Draw.floor()

    # Render two shapes. Transparency is enabled when they overlap.

    GL.DepthMask(GL::FALSE) if @overlap # For rendering with transparency.

    GL.Materialfv(GL::FRONT, GL::SPECULAR, [0,0,0,1].pack('F4'))
    GL.Materialfv(GL::FRONT, GL::AMBIENT, [0.2,0.2,0.2,1].pack('F4'))
    GL.Materialf(GL::FRONT, GL::SHININESS, 0.0)

    shapes = [@shape0, @shape1].sort_by { |s| s.center.transformCoord(@camera.mtxView).z }
    shapes.each do |s|
      GL.Materialfv(GL::FRONT, GL::DIFFUSE, [s.rgb, @overlap ? 0.75 : 1.0].flatten!.pack('F4'))
      s.draw
    end

    if @overlap.class == MPRAlgorithm::ContactInfo
      @overlap.update_basis
      GL.DepthMask(GL::TRUE)
      GL.Disable(GL::DEPTH_TEST)
      GL.Disable(GL::LIGHTING)
      Draw.point(@overlap.position)
      Draw.arrow(@overlap.position, @overlap.normal, @overlap.penetration, @overlap.basis)
    end

    GL.PopAttrib()

    GLFW.SwapBuffers(@window)
    GLFW.PollEvents()
  end
  private :draw

  # :GLFWkeyfun
  def key(window, key, scancode, action, mods)
    if key == GLFW::KEY_ESCAPE && action == GLFW::PRESS
      GLFW.SetWindowShouldClose(window, 1)
    end

    if action == GLFW::PRESS
      case key
      when GLFW::KEY_SPACE
        # 'Space' : Reset posture of all shapes.
        @shape0.reset
        @shape1.reset
        # @overlap = MPRAlgorithm.intersect(@shape0, @shape1)
        @overlap = MPRAlgorithm.get_contact(@shape0, @shape1)
        return
      when GLFW::KEY_Z
        # 'z' : Change type of shape0
        center = RMath3D::RVec3.new(@shape0.center)
        @shape0 = new_shape(@rgb_red)
        @shape0.center = center
        @overlap = MPRAlgorithm.get_contact(@shape0, @shape1)
        return
      when GLFW::KEY_M
        # 'm' : Change type of shape1
        center = RMath3D::RVec3.new(@shape1.center)
        @shape1 = new_shape(@rgb_blue)
        @shape1.center = center
        @overlap = MPRAlgorithm.get_contact(@shape0, @shape1)
        return
      end
    end

    shape0move = RMath3D::RVec3.new
    shape1move = RMath3D::RVec3.new

    case key
    # Move red shape.
    when GLFW::KEY_A ; shape0move.x -= 0.125
    when GLFW::KEY_S ; shape0move.z += 0.125
    when GLFW::KEY_W ; shape0move.z -= 0.125
    when GLFW::KEY_D ; shape0move.x += 0.125

    # Move blue shape.
    when GLFW::KEY_J ; shape1move.x -= 0.125
    when GLFW::KEY_K ; shape1move.z += 0.125
    when GLFW::KEY_I ; shape1move.z -= 0.125
    when GLFW::KEY_L ; shape1move.x += 0.125
    end

    # Transform the movement in view space into world space.
    mtxViewInv = @camera.mtxView.getInverse
    shape0move.transformNormal!(mtxViewInv)
    shape1move.transformNormal!(mtxViewInv)
    shape0move.y = 0
    shape1move.y = 0

    @shape0.center.add!(shape0move)
    @shape1.center.add!(shape1move)

    # @overlap = MPRAlgorithm.intersect(@shape0, @shape1)
    @overlap = MPRAlgorithm.get_contact(@shape0, @shape1)
  end
  private :key

  # :GLFWwindowsizefun
  def reshape(window, width, height)
    @window_width  = width
    @window_height = height

    width_buf = ' ' * 8
    height_buf = ' ' * 8
    GLFW.GetFramebufferSize(@window, width_buf, height_buf)

    GL.Viewport(0, 0, width_buf.unpack1('L'), height_buf.unpack1('L'))
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GL.MultMatrixf(RMath3D::RMtx4.new.perspectiveFovRH(30.0*Math::PI/180.0, width.to_f/height.to_f, 0.1, 1000.0).to_a.pack('F16'))
  end
  private :reshape

  # :GLFWmousebuttonfun
  def mouse(window, button, action, mods)
    x_buf = ' ' * 8
    y_buf = ' ' * 8
    GLFW.GetCursorPos(window, x_buf, y_buf)
    x = x_buf.unpack1('D')
    y = y_buf.unpack1('D')

    @camera.set_mouse_state(button, action, x, y)
  end
  private :mouse

  # :GLFWcursorposfun
  def motion(window, x, y)
    @camera.update_from_mouse_motion(x, y)
  end
  private :motion

  def new_shape(rgb)
    s = @shape_classes.rotate![0].new
    s.reset
    s.rgb = rgb
    return s
  end

  def initialize

    GLFW.load_lib(glfw_library_path())
    GLFW.Init()

    @window = GLFW.CreateWindow(640, 360, "MPRAlgorithm::intersect Test", nil, nil)

    return if @window.null?

    GLFW.MakeContextCurrent(@window)

    GL.load_lib()

    @key_callback = GLFW::create_callback(:GLFWkeyfun, method(:key))
    @size_callback = GLFW::create_callback(:GLFWwindowsizefun, method(:reshape))
    @mousebutton_callback = GLFW::create_callback(:GLFWmousebuttonfun, method(:mouse))
    @cursorpos_callback = GLFW::create_callback(:GLFWcursorposfun, method(:motion))
    GLFW.SetKeyCallback(@window, @key_callback)
    GLFW.SetWindowSizeCallback(@window, @size_callback)
    GLFW.SetMouseButtonCallback(@window, @mousebutton_callback)
    GLFW.SetCursorPosCallback(@window, @cursorpos_callback)

    @size_callback.call(@window, 640, 360)

    # ObjectSpace.define_finalizer(@key_callback,
    #                              @key_callback.class.method(:finalize).to_proc)

    # Common render states
    GL.Enable(GL::NORMALIZE)
    GL.Enable(GL::CULL_FACE)
    GL.Enable(GL::DEPTH_TEST)
    GL.DepthFunc(GL::LEQUAL)
    GL.DepthMask(GL::TRUE)
    GL.Enable(GL::BLEND)
    GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)
    GL.Enable(GL::LIGHTING)
    GL.Enable(GL::LIGHT0)
    GL.Enable(GL::LIGHT1)
    GL.ClearColor(0.9, 0.9, 0.95, 1.0)

    Draw.initialize

    @camera = Camera.new

    @shape_classes = [MPRAlgorithm::Box,
                      MPRAlgorithm::Cylinder,
                      MPRAlgorithm::Cone,
                      MPRAlgorithm::Sphere,
                      MPRAlgorithm::Triangle
                     ]

    @rgb_red  = [1.0,0.1,0.1]
    @rgb_blue = [0.1,0.1,1.0]

    @shape0 = new_shape(@rgb_red)
    @shape1 = new_shape(@rgb_blue)
    # @overlap = MPRAlgorithm.intersect(@shape0, @shape1)
    @overlap = MPRAlgorithm.get_contact(@shape0, @shape1)
  end

  def run
    while GLFW.WindowShouldClose(@window) == 0
      draw
    end
  end

  def finalize
    Draw.finalize
  end
end


if __FILE__ == $PROGRAM_NAME
  begin
    app = Application.new
    app.run
  ensure
    app&.finalize
  end
end

=begin
MPRTest : A demonstration program of Minkowski Portal Refinement.
Copyright (c) 2008-2022 vaiorabbit <http://twitter.com/vaiorabbit>

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source
    distribution.
=end
