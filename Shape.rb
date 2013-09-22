# -*- ruby -*-
require_relative 'Draw'
require 'rmath3d/rmath3d'

def urand( range )
  range*rand() - range/2.0
end

module MPRAlgorithm
  include RMath3D

  class Box

    attr_accessor :orientation, :center, :half, :rgb

    def initialize
      @orientation = RQuat.new( 0.0, 0.0, 0.0, 1.0 )
      @center = RVec3.new
      @half = RVec3.new( 0.5, 0.5, 0.5 )
      @rgb = [1.0, 1.0, 1.0]
    end

    # returns suppot point in world coorinate.
    def get_support_point( dir_world ) # dir_world : RMath3D::RVec3
      orientation_conj = @orientation.getConjugated
      dir_local = orientation_conj * RQuat.new( dir_world.x, dir_world.y, dir_world.z, 0.0 ) * @orientation

      support_local = RVec3.new( @half )
      support_local.x *= -1.0 if dir_local.x < 0.0
      support_local.y *= -1.0 if dir_local.y < 0.0
      support_local.z *= -1.0 if dir_local.z < 0.0

      support_world = (@orientation * RQuat.new(support_local.x, support_local.y, support_local.z, 0.0) * orientation_conj).xyz
      support_world.add! @center
      return support_world
    end

    def reset
      @center.setElements( urand(6.0), 2*rand, urand(6.0) )
      @half.setElements( 0.5+rand, 1.0+rand, 0.5+rand )
      @orientation.rotationAxis( RVec3.new(rand+0.1,0,urand(2.0)).normalize!, Math::PI*urand(2.0) )
    end

    def draw
      Draw.box(@center, @orientation.normalize!, @half)
    end
  end


  class Cylinder

    attr_accessor :orientation, :center, :radius, :half_height, :rgb

    def initialize
      @orientation = RQuat.new( 0.0, 0.0, 0.0, 1.0 )
      @center = RVec3.new
      @radius = 1.0
      @half_height = 0.5
      @rgb = [1.0, 1.0, 1.0]
    end

    # returns suppot point in world coorinate.
    def get_support_point( dir_world ) # dir_world : RMath3D::RVec3
      orientation_conj = @orientation.getConjugated
      dir_local = orientation_conj * RQuat.new( dir_world.x, dir_world.y, dir_world.z, 0.0 ) * @orientation

      u = RVec3.new( 0.0, 1.0, 0.0 )
      v = dir_local.xyz.getNormalized
      w = v - RVec3.dot(u,v) * u

      w_length = w.getLength
      sign = RVec3.dot(u,v) >= 0.0 ? 1.0 : -1.0

      support_local = nil
      if w_length > RMath3D::TOLERANCE
        support_local = sign * @half_height * u + @radius * (1.0/w_length) * w
      else
        support_local = sign * @half_height * u
      end

      support_world = (@orientation * RQuat.new(support_local.x, support_local.y, support_local.z, 0.0) * orientation_conj).xyz
      support_world.add! @center
      return support_world
    end

    def reset
      @center.setElements( urand(6.0), 2*rand, urand(6.0) )
      @orientation.rotationAxis( RVec3.new(rand+0.1,0,urand(2.0)).normalize!, Math::PI*urand(2.0) )
      @radius = 1.0+rand()
      @half_height = 1.0+rand()
    end

    def draw
      Draw.cylinder(@center, @orientation.normalize!, @radius, @half_height)
    end
  end


  class Cone

    attr_accessor :orientation, :center, :radius, :height, :rgb

    def initialize
      @orientation = RQuat.new( 0.0, 0.0, 0.0, 1.0 )
      @center = RVec3.new
      @radius = 1.0
      @height = 0.5
      @rgb = [1.0, 1.0, 1.0]
    end

    # returns suppot point in world coorinate.
    def get_support_point( dir_world ) # dir_world : RMath3D::RVec3
      orientation_conj = @orientation.getConjugated
      dir_local = orientation_conj * RQuat.new( dir_world.x, dir_world.y, dir_world.z, 0.0 ) * @orientation

      u = RVec3.new( 0.0, 1.0, 0.0 )
      v = dir_local.xyz.getNormalized
      w = v - RVec3.dot(u,v) * u

      w_length = w.getLength
      w.normalize!
      sin_theta = @radius / Math.sqrt( @radius*@radius + @height*@height )
      sin_phi   = RVec3.dot(u,v)

      support_local = nil
      if sin_phi >= sin_theta
        support_local = @height * u
      else
        if w_length > RMath3D::TOLERANCE
          support_local = @radius * w
        else
          support_local = RVec3.new
        end
      end

      support_world = (@orientation * RQuat.new(support_local.x, support_local.y, support_local.z, 0.0) * orientation_conj).xyz
      support_world.add! @center
      return support_world
    end

    def reset
      @center.setElements( urand(6.0), 2*rand, urand(6.0) )
      @orientation.rotationAxis( RVec3.new(rand+0.1,0,urand(2.0)).normalize!, Math::PI*urand(2.0) )
      @radius = 0.5+2.0*rand()
      @height = 2.0+rand()
    end

    def draw
      Draw.cone(@center, @orientation.normalize!, @radius, @height)
    end
  end


  class Sphere

    attr_accessor :center, :radius, :rgb

    def initialize
      @center = RVec3.new
      @radius = 1.0
      @rgb = [1.0, 1.0, 1.0]
    end

    # returns suppot point in world coorinate.
    def get_support_point( dir_world ) # dir_world : RMath3D::RVec3
      support_local = @radius * dir_world.getNormalized
      support_world = support_local + @center
      return support_world
    end

    def reset
      @center.setElements( urand(6.0), 2*rand, urand(6.0) )
      @radius = 1.0+rand()
    end

    def draw
      Draw.sphere(@center, @radius)
    end
  end

  class Triangle

    attr_accessor :orientation, :center, :vertex, :rgb

    def initialize
      @orientation = RQuat.new( 0.0, 0.0, 0.0, 1.0 )
      @center = RVec3.new
      @vertex = [RVec3.new, RVec3.new, RVec3.new]
      @rgb = [1.0, 1.0, 1.0]
    end

    # returns suppot point in world coorinate.
    def get_support_point( dir_world ) # dir_world : RMath3D::RVec3
      orientation_conj = @orientation.getConjugated
      dir_local = orientation_conj * RQuat.new( dir_world.x, dir_world.y, dir_world.z, 0.0 ) * @orientation

      farthest = 0
      max_dot_product = RVec3.dot(@vertex[0],dir_local)
      dot_product = RVec3.dot(@vertex[1],dir_local)
      if max_dot_product < dot_product
        max_dot_product = dot_product
        farthest = 1
      end
      dot_product = RVec3.dot(@vertex[2],dir_local)
      if max_dot_product < dot_product
        max_dot_product = dot_product
        farthest = 2
      end
      support_local = @vertex[farthest]

      support_world = (@orientation * RQuat.new(support_local.x, support_local.y, support_local.z, 0.0) * orientation_conj).xyz
      support_world.add! @center
      return support_world
    end

    def reset
      @center.setElements( urand(6.0), 2*rand, urand(6.0) )
      @vertex[0].setElements( 1.5+rand, 0, 1.5+rand )
      @vertex[1].setElements( -2.5+rand, 0, -2.5+rand )
      @vertex[2].setElements( -2.5+rand, 0, 1.5+rand )
      @orientation.rotationAxis( RVec3.new(rand+0.1,0,urand(2.0)).normalize!, Math::PI*urand(2.0) )
    end

    def draw
      mtxOrientation = RMtx3.new.rotationQuaternion(@orientation)
      Draw.triangle( @vertex[0].transformRS( mtxOrientation ) + @center,
                     @vertex[1].transformRS( mtxOrientation ) + @center,
                     @vertex[2].transformRS( mtxOrientation ) + @center )
    end
  end

end
