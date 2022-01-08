require 'opengl'
require 'rmath3d/rmath3d_plain'

class Camera
  include RMath3D

  attr_reader :mtxView

  def initialize
    @mouse_state = 0
    @prev_x = 0
    @prev_y = 0
    @phi = Math::PI/2.0
    @theta = Math::PI/3.0
    @radius = 20.0

    @position = RVec3.new(@radius * Math.sin(@theta) * Math.cos(@phi), @radius * Math.cos(@theta), @radius * Math.sin(@theta) * Math.sin(@phi))
    @at       = RVec3.new(0, 0, 0)
    @up       = RVec3.new(0, 1, 0)

    @mtxView = RMtx4.new.lookAtRH(@position, @at, @up)
  end

  def set_mouse_state(button, state, x, y)
    if button == GLFW::MOUSE_BUTTON_LEFT
      if state == GLFW::PRESS
        @mouse_state |= 1
      else # GLFW::RELEASE
        @mouse_state &= ~1
      end
    end
    if button == GLFW::MOUSE_BUTTON_RIGHT
      if state == GLFW::PRESS
        @mouse_state |= 2
      else # GLFW::RELEASE
        @mouse_state &= ~2
      end
    end
    if button == GLFW::MOUSE_BUTTON_MIDDLE
      if state == GLFW::PRESS
        @mouse_state |= 4
      else # GLFW::RELEASE
        @mouse_state &= ~4
      end
    end
    @prev_x = x
    @prev_y = y
  end

  def update_from_mouse_motion(x, y)
    if @mouse_state != 0
      dx = (x - @prev_x).to_f
      dy = (y - @prev_y).to_f

      if @mouse_state == 1 # Left
        scale = 0.5
        @phi += scale * dx * Math::PI/180
        @theta -= scale * dy * Math::PI/180
      elsif @mouse_state == 2 # Right
        scale = 0.5
        @radius -= scale * dy
      end

      wrap_params()
      @position.x = @radius * Math.sin(@theta) * Math.cos(@phi)
      @position.z = @radius * Math.sin(@theta) * Math.sin(@phi)
      @position.y = @radius * Math.cos(@theta)

      @renew_view = true
      @renew_pvinv = true
    end

    @prev_x = x
    @prev_y = y
  end

  def wrap_params
    @phi -= 2*Math::PI if @phi > 2*Math::PI
    @phi += 2*Math::PI if @phi < -2*Math::PI

    @theta = Math::PI/2 if @theta > Math::PI/2
    @theta = RMath3D::TOLERANCE if @theta < RMath3D::TOLERANCE

    @radius = 30.0 if @radius > 30.0
    @radius = 10.0 if @radius < 10.0
  end

  def load_camera_matrix
    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()

    GL.MultMatrixf(@mtxView.lookAtRH(@position, @at, @up).to_a.pack('F16'))
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
