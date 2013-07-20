require 'opengl'

require_relative 'rmath3d_plain'
include RMath3D

require_relative 'Draw'
require_relative 'Camera'
require_relative 'MPRAlgorithm'
require_relative 'Shape'

class Application

  def draw
    @camera.load_camera_matrix()

    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT )
    glPushAttrib( GL_ALL_ATTRIB_BITS )

    glLightfv( GL_LIGHT0, GL_POSITION, [10,10,10,1] )
    glLightfv( GL_LIGHT0, GL_DIFFUSE,  [1,1,1,1] )
    glLightfv( GL_LIGHT0, GL_SPECULAR, [1,1,1,1] )
    glLightfv( GL_LIGHT0, GL_AMBIENT,  [0.2,0.2,0.2,1] )

    glLightfv( GL_LIGHT1, GL_POSITION, [-10,-10,-10,1] )
    glLightfv( GL_LIGHT1, GL_DIFFUSE,  [1,1,1,1] )
    glLightfv( GL_LIGHT1, GL_SPECULAR, [1,1,1,1] )
    glLightfv( GL_LIGHT1, GL_AMBIENT,  [0.2,0.2,0.2,1] )

    Draw.floor()

    # Render two shapes. Transparency is enabled when they overlap.

    glDepthMask( GL_FALSE ) if @overlap # For rendering with transparency.

    glMaterialfv( GL_FRONT, GL_SPECULAR, [0,0,0,1] )
    glMaterialfv( GL_FRONT, GL_AMBIENT, [0.2,0.2,0.2,1] )
    glMaterialf( GL_FRONT, GL_SHININESS, 0.0 )

    shapes = [@shape0, @shape1].sort_by { |s| s.center.transformCoord(@camera.mtxView).z }
    shapes.each do |s|
      glMaterialfv( GL_FRONT, GL_DIFFUSE, [s.rgb, @overlap ? 0.75 : 1.0].flatten! )
      s.draw
    end

    if @overlap.class == MPRAlgorithm::ContactInfo
      @overlap.update_basis
      glDepthMask( GL_TRUE )
      glDisable( GL_DEPTH_TEST )
      glDisable( GL_LIGHTING )
      # Draw.sphere( @overlap.position, 0.1 )
      Draw.arrow( @overlap.position, @overlap.normal, @overlap.penetration, @overlap.basis )
    end

    glPopAttrib()
    glutSwapBuffers()
  end


  def timer( value )
    glutTimerFunc( 1000/60, method(:timer).to_proc, 0 )
    glutPostRedisplay()
  end


  def key( key, x, y )
    case key
    when ?\e, ?q
      # 'Esc' or 'q' : Quit this program.
      exit
      return
    end

    case key
    when ?\s
      # 'Space' : Reset posture of all shapes.
      @shape0.reset
      @shape1.reset
      # @overlap = MPRAlgorithm.intersect( @shape0, @shape1 )
      @overlap = MPRAlgorithm.get_contact( @shape0, @shape1 )
      return
    when ?z
      # 'z' : Change type of shape0
      center = RVec3.new( @shape0.center )
      @shape0 = new_shape( @rgb_red )
      @shape0.center = center
      @overlap = MPRAlgorithm.get_contact( @shape0, @shape1 )
      return
    when ?m
      # 'm' : Change type of shape1
      center = RVec3.new( @shape1.center )
      @shape1 = new_shape( @rgb_blue )
      @shape1.center = center
      @overlap = MPRAlgorithm.get_contact( @shape0, @shape1 )
      return
    end

    shape0move = RVec3.new
    shape1move = RVec3.new

    case key
    # Move red shape.
    when ?a ; shape0move.x -= 0.125
    when ?s ; shape0move.z += 0.125
    when ?w ; shape0move.z -= 0.125
    when ?d ; shape0move.x += 0.125

    # Move blue shape.
    when ?j ; shape1move.x -= 0.125
    when ?k ; shape1move.z += 0.125
    when ?i ; shape1move.z -= 0.125
    when ?l ; shape1move.x += 0.125
    end

    # Transform the movement in view space into world space.
    mtxViewInv = @camera.mtxView.getInverse
    shape0move.transformNormal!( mtxViewInv )
    shape1move.transformNormal!( mtxViewInv )
    shape0move.y = 0
    shape1move.y = 0

    @shape0.center.add!( shape0move )
    @shape1.center.add!( shape1move )

    # @overlap = MPRAlgorithm.intersect( @shape0, @shape1 )
    @overlap = MPRAlgorithm.get_contact( @shape0, @shape1 )
  end


  def reshape( width, height )
    glViewport( 0, 0, width, height )
    glMatrixMode( GL_PROJECTION )
    glLoadIdentity()
    glMultMatrixf( RMtx4.new.perspectiveFovRH( 30.0*Math::PI/180.0, width.to_f/height.to_f, 0.1, 1000.0 ) )

    @window_width  = width
    @window_height = height

    glutPostRedisplay()
  end


  def mouse( button, state, x, y )
    @camera.set_mouse_state( button, state, x, y )
  end


  def motion( x, y )
    @camera.update_from_mouse_motion( x, y )
  end


  def new_shape( rgb )
    s = @shape_classes[rand(@shape_classes.length)].new
    s.reset
    s.rgb = rgb
    return s
  end


  def initialize
    @window_width  = 640
    @window_height = 360

    glutInit()
    glutInitDisplayMode( GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE )
    glutInitWindowPosition( 0, 0 )
    glutInitWindowSize( @window_width, @window_height )
    glutCreateWindow( "MPRAlgorithm::intersect Test" )

    glutDisplayFunc( method(:draw).to_proc )
    glutReshapeFunc( method(:reshape).to_proc )
    glutKeyboardFunc( method(:key).to_proc )
    glutMouseFunc( method(:mouse).to_proc )
    glutMotionFunc( method(:motion).to_proc )
    glutTimerFunc( 0, method(:timer).to_proc, 0 )

    # Common render states
    glEnable( GL_NORMALIZE )
    glEnable( GL_CULL_FACE )
    glEnable( GL_DEPTH_TEST )
    glDepthFunc( GL_LEQUAL )
    glDepthMask( GL_TRUE )
    glEnable( GL_BLEND )
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA )
    glEnable( GL_LIGHTING )
    glEnable( GL_LIGHT0 )
    glEnable( GL_LIGHT1 )
    glClearColor( 0.9, 0.9, 0.95, 1.0 )

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

    @shape0 = new_shape( @rgb_red )
    @shape1 = new_shape( @rgb_blue )
    # @overlap = MPRAlgorithm.intersect( @shape0, @shape1 )
    @overlap = MPRAlgorithm.get_contact( @shape0, @shape1 )
  end


  def start
    glutMainLoop()
  end


  def finalize
    Draw.finalize
  end
end


app = Application.new
begin
  app.start
ensure
  app.finalize
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
