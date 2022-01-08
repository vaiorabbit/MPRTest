require 'opengl'
require 'rmath3d/rmath3d_plain'
require_relative 'Geometry'

module Draw

  include RMath3D

  def self.initialize
    init_floor()
    init_box()
    init_cylinder()
    init_cone()
    init_sphere()
    init_point()
    init_arrow()
  end

  def self.finalize
    displaylists = [@@dl_box, @@dl_cylinder, @@dl_cone, @@dl_sphere, @@dl_point, @@dl_arrow]
    displaylists.each do |dl|
      GL.DeleteLists(dl, 1)
    end
  end

  def self.init_floor()
    pos_max = 10.0
    pos_min = -pos_max

    nlines = 10

    stride = (pos_max - pos_min) / nlines

    pos = Array.new(3 * 2*(nlines+1), 0.0)

    for i in 0..nlines do
      pos[6*i+0] = pos_min
      pos[6*i+1] = 0.0
      pos[6*i+2] = pos_min+stride*i

      pos[6*i+3] = pos_max
      pos[6*i+4] = 0.0
      pos[6*i+5] = pos_min+stride*i
    end

    for i in 0..nlines do
      j = i + nlines+1

      pos[6*j+0] = pos_min+stride*i
      pos[6*j+1] = 0.0
      pos[6*j+2] = pos_min

      pos[6*j+3] = pos_min+stride*i
      pos[6*j+4] = 0.0
      pos[6*j+5] = pos_max
    end

    @@packed_pos = pos.pack("d*")
    @@packed_pos_indices = pos.length/3
    pos = nil
  end

  def self.floor()
    GL.PushAttrib(GL::ALL_ATTRIB_BITS)

    GL.LineWidth(1.0)
    GL.Disable(GL::LIGHTING)
    GL.ShadeModel(GL::FLAT)
    GL.Color4fv([ 0.2, 0.2, 0.8, 1.0 ].pack('F4'))

    GL.EnableClientState(GL::VERTEX_ARRAY)
    GL.VertexPointer(3, GL::DOUBLE, 0, @@packed_pos)
    GL.DrawArrays(GL::LINES, 0, @@packed_pos_indices)
    GL.DisableClientState(GL::VERTEX_ARRAY)

    GL.PopAttrib()
  end

  def self.init_box
    @@dl_box = GL.GenLists(1)
    GL.NewList(@@dl_box, GL::COMPILE)
    geomSolidCube(1)
    GL.EndList()
  end

  def self.box(pos, quat, half)
    GL.PushMatrix()

    mtx = RMtx4.new.rotationQuaternion(quat)
    mtx.e03 = pos.x
    mtx.e13 = pos.y
    mtx.e23 = pos.z
    GL.MultMatrixf(mtx.to_a.pack('F16'))

    GL.PushMatrix()
    GL.Scalef(2.0*half.x, 2.0*half.y, 2.0*half.z)
    GL.CallList(@@dl_box)
    GL.PopMatrix()

    GL.PopMatrix()
  end

  def self.init_cylinder
    @@dl_cylinder = GL.GenLists(1)
    GL.NewList(@@dl_cylinder, GL::COMPILE)

    n = 18

    GL.Begin(GL::QUADS)
    n.times do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i+1)/n * Math::PI/180)
      x1 = Math.sin(360*(i+1)/n * Math::PI/180)
      GL.Normal3f(x0, 0.0, z0)
      GL.Vertex3f(x0,  0.5, z0)
      GL.Normal3f(x0, 0.0, z0)
      GL.Vertex3f(x0, -0.5, z0)
      GL.Normal3f(x1, 0.0, z1)
      GL.Vertex3f(x1, -0.5, z1)
      GL.Normal3f(x1, 0.0, z1)
      GL.Vertex3f(x1,  0.5, z1)
    end
    GL.End()

    GL.Begin(GL::TRIANGLE_FAN)
    GL.Normal3f(0.0, 1.0, 0.0)
    GL.Vertex3f(0.0, 0.5, 0.0)
    n.times do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i+1)/n * Math::PI/180)
      x1 = Math.sin(360*(i+1)/n * Math::PI/180)
      GL.Normal3f(0.0, 1.0, 0.0)
      GL.Vertex3f(x0,  0.5, z0)
      GL.Normal3f(0.0, 1.0, 0.0)
      GL.Vertex3f(x1,  0.5, z1)
    end
    GL.End()

    GL.Begin(GL::TRIANGLE_FAN)
    GL.Normal3f(0.0, -1.0, 0.0)
    GL.Vertex3f(0.0, -0.5, 0.0)
    n.downto(1) do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i-1)/n * Math::PI/180)
      x1 = Math.sin(360*(i-1)/n * Math::PI/180)
      GL.Normal3f(0.0, -1.0, 0.0)
      GL.Vertex3f(x0,  -0.5, z0)
      GL.Normal3f(0.0, -1.0, 0.0)
      GL.Vertex3f(x1,  -0.5, z1)
    end
    GL.End()

    GL.EndList()
  end

  def self.cylinder(pos, quat, radius, half_height)
    GL.PushMatrix()

    mtx = RMtx4.new.rotationQuaternion(quat)
    mtx.e03 = pos.x
    mtx.e13 = pos.y
    mtx.e23 = pos.z
    GL.MultMatrixf(mtx.to_a.pack('F16'))

    GL.Scalef(radius, 2.0*half_height, radius)
    GL.CallList(@@dl_cylinder)
    GL.PopMatrix()
  end


  def self.init_cone
    @@dl_cone = GL.GenLists(1)
    GL.NewList(@@dl_cone, GL::COMPILE)

    n = 18

    GL.Begin(GL::TRIANGLE_FAN)
    GL.Normal3f(0.0, 1.0, 0.0)
    GL.Vertex3f(0.0, 1.0, 0.0)
    n.times do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i+1)/n * Math::PI/180)
      x1 = Math.sin(360*(i+1)/n * Math::PI/180)
      GL.Normal3f(x0, 0.0, z0)
      GL.Vertex3f(x0, 0.0, z0)
      GL.Normal3f(x1, 0.0, z1)
      GL.Vertex3f(x1, 0.0, z1)
    end
    GL.End()

    GL.Begin(GL::TRIANGLE_FAN)
    GL.Normal3f(0.0, -1.0, 0.0)
    GL.Vertex3f(0.0,  0.0, 0.0)
    n.downto(1) do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i-1)/n * Math::PI/180)
      x1 = Math.sin(360*(i-1)/n * Math::PI/180)
      GL.Normal3f(0.0, -1.0, 0.0)
      GL.Vertex3f(x0,   0.0, z0)
      GL.Normal3f(0.0, -1.0, 0.0)
      GL.Vertex3f(x1,   0.0, z1)
    end
    GL.End()

    GL.EndList()
  end


  def self.cone(pos, quat, radius, height)
    GL.PushMatrix()

    mtx = RMtx4.new.rotationQuaternion(quat)
    mtx.e03 = pos.x
    mtx.e13 = pos.y
    mtx.e23 = pos.z
    GL.MultMatrixf(mtx.to_a.pack('F16'))

    GL.Scalef(radius, height, radius)
    GL.CallList(@@dl_cone)
    GL.PopMatrix()
  end

  def self.init_sphere
    @@dl_sphere = GL.GenLists(1)
    GL.NewList(@@dl_sphere, GL::COMPILE)
    geomSolidSphere(1.0, 16, 16)
    GL.EndList()
  end

  def self.sphere(pos, radius)
    GL.PushMatrix()
    GL.Translatef(pos.x, pos.y, pos.z)
    GL.Scalef(radius, radius, radius)
    GL.CallList(@@dl_sphere)
    GL.PopMatrix()
  end

  def self.init_point
    @@dl_point = GL.GenLists(1)
    GL.NewList(@@dl_point, GL::COMPILE)
    GL.Color4f(1,1,0,1)
    geomSolidSphere(1.0, 16, 16)
    GL.EndList()
  end

  def self.point(pos)
    radius = 0.05
    GL.PushMatrix()
    GL.Translatef(pos.x, pos.y, pos.z)
    GL.Scalef(radius, radius, radius)
    GL.CallList(@@dl_point)
    GL.PopMatrix()
  end

  def self.init_arrow
    @@dl_arrow = GL.GenLists(1)
    GL.NewList(@@dl_arrow, GL::COMPILE)
    GL.Color4f(0,0.8,0,1)
    geomSolidCone(0.1, 0.5, 8, 8)
    GL.EndList()
  end

  def self.arrow(pos, dir, depth, basis)
    line_translation = pos + depth * dir

    GL.Begin(GL::LINES)
    GL.Color4f(1,1,0,1)
    GL.Vertex3f(pos.x, pos.y, pos.z)
    GL.Color4f(0,0.8,0,1)
    GL.Vertex3f(line_translation.x, line_translation.y, line_translation.z)
    GL.End()

    mtxRotY = RMtx3.new.rotationY(90.0 * Math::PI/180.0)
    mtx = basis * mtxRotY
    mtx4x4 = RMtx4.new(mtx[0,0], mtx[0,1], mtx[0,2], 0.0,
                        mtx[1,0], mtx[1,1], mtx[1,2], 0.0,
                        mtx[2,0], mtx[2,1], mtx[2,2], 0.0,
                        0.0,      0.0,      0.0,      1.0)
    GL.PushMatrix()
    GL.Translatef(line_translation.x, line_translation.y, line_translation.z)
    GL.MultMatrixf(mtx4x4.to_a.pack('F16'))
    GL.CallList(@@dl_arrow)
    GL.PopMatrix()
  end

  def self.triangle(*pos)
#     raise ArgumentError if pos.length != 3
#     raise ArgumentError if pos[0].class != RVec3 || pos[1].class != RVec3 || pos[2].class != RVec3

    GL.Begin(GL::TRIANGLES)
    normal = RVec3.cross(pos[2]-pos[0], pos[1]-pos[0]).normalize!()
    GL.Normal3fv(normal.to_a.pack('F3'))
    GL.Vertex3fv(pos[0].to_a.pack('F3'))
    GL.Vertex3fv(pos[1].to_a.pack('F3'))
    GL.Vertex3fv(pos[2].to_a.pack('F3'))

    normal = RVec3.cross(pos[1]-pos[0], pos[2]-pos[0]).normalize!()
    GL.Normal3fv(normal.to_a.pack('F3'))
    GL.Vertex3fv(pos[0].to_a.pack('F3'))
    GL.Vertex3fv(pos[2].to_a.pack('F3'))
    GL.Vertex3fv(pos[1].to_a.pack('F3'))
    GL.End();
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
