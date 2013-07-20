require 'opengl'

module Draw

  def self.initialize
    init_floor()
    init_box()
    init_cylinder()
    init_cone()
    init_sphere()
    init_arrow()
  end

  def self.finalize
    displaylists = [@@dl_box, @@dl_cylinder, @@dl_cone, @@dl_sphere]
    displaylists.each do |dl|
      glDeleteLists( dl, 1 )
    end
  end

  def self.init_floor()
    pos_max = 10.0
    pos_min = -pos_max

    nlines = 10

    stride = (pos_max - pos_min) / nlines

    pos = Array.new( 3 * 2*(nlines+1), 0.0 )

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

    @@packed_pos = pos.pack( "d*" )
    @@packed_pos_indices = pos.length/3
    pos = nil
  end

  def self.floor()
    glPushAttrib( GL_ALL_ATTRIB_BITS )

    glLineWidth( 1.0 )
    glDisable( GL_LIGHTING )
    glShadeModel( GL_FLAT )
    glColor( [ 0.2, 0.2, 0.8, 1.0 ] )

    glEnableClientState( GL_VERTEX_ARRAY )
    glVertexPointer( 3, GL_DOUBLE, 0, @@packed_pos )
    glDrawArrays( GL_LINES, 0, @@packed_pos_indices )
    glDisableClientState( GL_VERTEX_ARRAY )

    glPopAttrib()
  end

  def self.init_box
    @@dl_box = glGenLists(1)
    glNewList( @@dl_box, GL_COMPILE )
    glutSolidCube(1)
    glEndList()
  end

  def self.box( pos, quat, half )
    glPushMatrix()

    mtx = RMtx4.new.rotationQuaternion(quat)
    mtx.e03 = pos.x
    mtx.e13 = pos.y
    mtx.e23 = pos.z
    glMultMatrixf( mtx.to_a )

    glPushMatrix()
    glScalef( 2.0*half.x, 2.0*half.y, 2.0*half.z )
    glCallList( @@dl_box )
    glPopMatrix()

    glPopMatrix()
  end

  def self.init_cylinder
    @@dl_cylinder = glGenLists(1)
    glNewList( @@dl_cylinder, GL_COMPILE )

    n = 18

    glBegin( GL_QUADS )
    n.times do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i+1)/n * Math::PI/180)
      x1 = Math.sin(360*(i+1)/n * Math::PI/180)
      glNormal3f( x0, 0.0, z0 )
      glVertex3f( x0,  0.5, z0 )
      glNormal3f( x0, 0.0, z0 )
      glVertex3f( x0, -0.5, z0 )
      glNormal3f( x1, 0.0, z1 )
      glVertex3f( x1, -0.5, z1 )
      glNormal3f( x1, 0.0, z1 )
      glVertex3f( x1,  0.5, z1 )
    end
    glEnd()

    glBegin( GL_TRIANGLE_FAN )
    glNormal3f( 0.0, 1.0, 0.0 )
    glVertex3f( 0.0, 0.5, 0.0 )
    n.times do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i+1)/n * Math::PI/180)
      x1 = Math.sin(360*(i+1)/n * Math::PI/180)
      glNormal3f( 0.0, 1.0, 0.0 )
      glVertex3f( x0,  0.5, z0 )
      glNormal3f( 0.0, 1.0, 0.0 )
      glVertex3f( x1,  0.5, z1 )
    end
    glEnd()

    glBegin( GL_TRIANGLE_FAN )
    glNormal3f( 0.0, -1.0, 0.0 )
    glVertex3f( 0.0, -0.5, 0.0 )
    n.downto(1) do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i-1)/n * Math::PI/180)
      x1 = Math.sin(360*(i-1)/n * Math::PI/180)
      glNormal3f( 0.0, -1.0, 0.0 )
      glVertex3f( x0,  -0.5, z0 )
      glNormal3f( 0.0, -1.0, 0.0 )
      glVertex3f( x1,  -0.5, z1 )
    end
    glEnd()

    glEndList()
  end

  def self.cylinder( pos, quat, radius, half_height )
    glPushMatrix()

    mtx = RMtx4.new.rotationQuaternion(quat)
    mtx.e03 = pos.x
    mtx.e13 = pos.y
    mtx.e23 = pos.z
    glMultMatrixf( mtx.to_a )

    glScalef( radius, 2.0*half_height, radius )
    glCallList( @@dl_cylinder )
    glPopMatrix()
  end


  def self.init_cone
    @@dl_cone = glGenLists(1)
    glNewList( @@dl_cone, GL_COMPILE )

    n = 18

    glBegin( GL_TRIANGLE_FAN )
    glNormal3f( 0.0, 1.0, 0.0 )
    glVertex3f( 0.0, 1.0, 0.0 )
    n.times do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i+1)/n * Math::PI/180)
      x1 = Math.sin(360*(i+1)/n * Math::PI/180)
      glNormal3f( x0, 0.0, z0 )
      glVertex3f( x0, 0.0, z0 )
      glNormal3f( x1, 0.0, z1 )
      glVertex3f( x1, 0.0, z1 )
    end
    glEnd()

    glBegin( GL_TRIANGLE_FAN )
    glNormal3f( 0.0, -1.0, 0.0 )
    glVertex3f( 0.0,  0.0, 0.0 )
    n.downto(1) do |i|
      z0 = Math.cos(360*i/n * Math::PI/180)
      x0 = Math.sin(360*i/n * Math::PI/180)
      z1 = Math.cos(360*(i-1)/n * Math::PI/180)
      x1 = Math.sin(360*(i-1)/n * Math::PI/180)
      glNormal3f( 0.0, -1.0, 0.0 )
      glVertex3f( x0,   0.0, z0 )
      glNormal3f( 0.0, -1.0, 0.0 )
      glVertex3f( x1,   0.0, z1 )
    end
    glEnd()

    glEndList()
  end


  def self.cone( pos, quat, radius, height )
    glPushMatrix()

    mtx = RMtx4.new.rotationQuaternion(quat)
    mtx.e03 = pos.x
    mtx.e13 = pos.y
    mtx.e23 = pos.z
    glMultMatrixf( mtx.to_a )

    glScalef( radius, height, radius )
    glCallList( @@dl_cone )
    glPopMatrix()
  end

  def self.init_sphere
    @@dl_sphere = glGenLists(1)
    glNewList( @@dl_sphere, GL_COMPILE )
    glutSolidSphere(1.0, 16, 16)
    glEndList()
  end

  def self.sphere( pos, radius )
    glPushMatrix()
    glTranslatef( pos.x, pos.y, pos.z )
    glScalef( radius, radius, radius )
    glCallList( @@dl_sphere )
    glPopMatrix()
  end

  def self.init_arrow
    @@dl_arrow = glGenLists(1)
    glNewList( @@dl_arrow, GL_COMPILE )
    glutSolidCone( 0.1, 0.5, 8, 8 )
    glEndList()
  end

  def self.arrow( pos, dir, depth, basis )
    line_translation = pos + depth * dir

    glBegin( GL_LINES )
    glColor4f( 1,1,0,1 )
    glVertex3f( pos.x, pos.y, pos.z )
    glColor4f( 0,0.8,0,1 )
    glVertex3f( line_translation.x, line_translation.y, line_translation.z )
    glEnd()

    mtxRotY = RMtx3.new.rotationY( 90.0 * Math::PI/180.0 )
    mtx = basis * mtxRotY
    mtx4x4 = RMtx4.new( mtx[0,0], mtx[0,1], mtx[0,2], 0.0,
                        mtx[1,0], mtx[1,1], mtx[1,2], 0.0,
                        mtx[2,0], mtx[2,1], mtx[2,2], 0.0,
                        0.0,      0.0,      0.0,      1.0 )
    glPushMatrix()
    glTranslatef( line_translation.x, line_translation.y, line_translation.z )
    glMultMatrixf( mtx4x4 )
    glCallList( @@dl_arrow )
    glPopMatrix()
  end

  def self.triangle( *pos )
#     raise ArgumentError if pos.length != 3
#     raise ArgumentError if pos[0].class != RVec3 || pos[1].class != RVec3 || pos[2].class != RVec3

    glBegin( GL_TRIANGLES )
    normal = RVec3.cross(pos[2]-pos[0], pos[1]-pos[0]).normalize!()
    glNormal3fv( normal.to_a )
    glVertex3fv( pos[0].to_a )
    glVertex3fv( pos[1].to_a )
    glVertex3fv( pos[2].to_a )

    normal = RVec3.cross(pos[1]-pos[0], pos[2]-pos[0]).normalize!()
    glNormal3fv( normal.to_a )
    glVertex3fv( pos[0].to_a )
    glVertex3fv( pos[2].to_a )
    glVertex3fv( pos[1].to_a )
    glEnd();
  end

end


=begin
MPRTest : A demonstration program of Minkowski Portal Refinement.
Copyright (c) 2008- vaiorabbit <http://twitter.com/vaiorabbit>

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
