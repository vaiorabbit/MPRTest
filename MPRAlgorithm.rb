# -*- ruby -*-
require 'rmath3d/rmath3d_plain'

module MPRAlgorithm
  include RMath3D

  #
  # Intersection test with MPR Algorithm.
  #
  def self.intersect(shapeA, shapeB)

    # Phase 1 : Portal discovery

    # v0 is an interior point in Minkowski difference B-A, and referred throughout this algorithm.
    v0 = shapeB.center - shapeA.center
    return true if v0.getLength <= RMath3D::TOLERANCE

    # v1 : support point in the direction of the origin ray
    origin_ray = -v0
    v1 = shapeB.get_support_point(origin_ray) - shapeA.get_support_point(-origin_ray)
    return false if RMath3D::RVec3.dot(v1,origin_ray) <= 0.0

    # v2 : perpendicular to plane containing origin, interior point v0 and first support point v1.
    v1_x_v0 = RMath3D::RVec3.cross(v1, v0)
    return true if v1_x_v0.getLength <= RMath3D::TOLERANCE
    v2 = shapeB.get_support_point(v1_x_v0) - shapeA.get_support_point(-v1_x_v0)
    return false if RMath3D::RVec3.dot(v2,v1_x_v0) <= 0.0

    # v3 : perpendicular to plane containing v0, v1 and second support point v2.
    v3 = nil
    loop do
      n = RMath3D::RVec3.cross(v1-v0, v2-v0)
      v3 = shapeB.get_support_point(n) - shapeA.get_support_point(-n)
      return false if RMath3D::RVec3.dot(v3,n) <= 0.0

      if RMath3D::RVec3.dot(n, origin_ray) < 0.0 # origin is outside the plane (v0,v1,v2).
        v2,v1 = v1,v2  # reverse the search direction n.
        redo
      end

      if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v3,v2), v0) < 0.0 # origin is outside the plane (v0,v2,v3). See Note [3].
        v1 = v3
        redo
      end

      if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v1,v3), v0) < 0.0 # origin is outside the plane (v0,v3,v1). See Note [3].
        v2 = v3
        redo
      end

      break
    end

    # Phase 2 : Portal refinement

    loop do
      # Check if origin is inside the portal plane (v1,v2,v3).
      n_portal = RMath3D::RVec3.cross(v2-v1, v3-v1)
      return true if RMath3D::RVec3.dot(n_portal,v1) >= 0.0

      # v4 : support point in the portal's normal direction.
      v4 = shapeB.get_support_point(n_portal) - shapeA.get_support_point(-n_portal)
      n_portal.normalize!

      # Check if origin is outside the support plane, and the interval distance between
      # the portal and the support plane is also checked to avoid endless loop.
      return false if RMath3D::RVec3.dot(v4,n_portal) <= 0 || RMath3D::RVec3.dot(v4-v3,n_portal) <= RMath3D::TOLERANCE

      # Portal refinement: See Note [4].
      if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v4,v1), v0) < 0.0
        if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v4,v2), v0) < 0.0
          v1 = v4 # New portal is (v2, v3, v4). So v1 is eliminated.
        else
          v3 = v4 # New portal is (v1, v2, v4). So v3 is eliminated.
        end
      else
        if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v4,v3), v0) < 0.0
          v2 = v4 # New portal is (v1, v3, v4). So v2 is eliminated.
        else
          v1 = v4 # New portal is (v2, v3, v4). So v1 is eliminated.
        end
      end
    end
  end

  class ContactInfo
    attr_accessor :normal
    attr_accessor :position
    attr_accessor :penetration
    attr_accessor :basis

    def initialize
      @normal = RMath3D::RVec3.new
      @position = RMath3D::RVec3.new
      @penetration = 0.0
      @basis  = RMath3D::RMtx3.new
    end

    def update_basis
      return if !@normal
      y_axis = RMath3D::RVec3.new
      z_axis = RMath3D::RVec3.new
      if @normal.x.abs > @normal.y.abs
        s = 1.0 / Math.sqrt(@normal.z**2 + @normal.x**2)
        y_axis.x =  @normal.z * s
        y_axis.z = -@normal.x * s

        z_axis.x =  @normal.y * y_axis.z
        z_axis.y =  @normal.z * y_axis.x - @normal.x * y_axis.z
        z_axis.z = -@normal.y * y_axis.x
      else
        s = 1.0 / Math.sqrt(@normal.z**2 + @normal.y**2)
        y_axis.y = -@normal.z * s
        y_axis.z =  @normal.y * s

        z_axis.x =  @normal.y * y_axis.z - @normal.z * y_axis.y
        z_axis.y = -@normal.x * y_axis.z
        z_axis.z =  @normal.x * y_axis.y
      end

      @basis[0,0] = @normal.x; @basis[0,1] = y_axis.x; @basis[0,2] = z_axis.x
      @basis[1,0] = @normal.y; @basis[1,1] = y_axis.y; @basis[1,2] = z_axis.y
      @basis[2,0] = @normal.z; @basis[2,1] = y_axis.z; @basis[2,2] = z_axis.z
    end
  end

  def self.get_contact(shapeA, shapeB)

    # Phase 1 : Portal discovery

    # v0 is an interior point in Minkowski difference B-A, and referred throughout this algorithm.
    v0A = shapeA.center
    v0B = shapeB.center
    v0 = v0B - v0A
    if v0.getLength <= RMath3D::TOLERANCE
      v0.setElements(0.0001, 0.0, 0.0)
    end

    # v1 : support point in the direction of the origin ray
    origin_ray = -v0
    v1A = shapeA.get_support_point(-origin_ray)
    v1B = shapeB.get_support_point(origin_ray)
    v1 = v1B - v1A
    return nil if RMath3D::RVec3.dot(v1,origin_ray) <= 0.0

    # v2 : perpendicular to plane containing origin, interior point v0 and first support point v1.
    v1_x_v0 = RMath3D::RVec3.cross(v1, v0)
    if v1_x_v0.getLength <= RMath3D::TOLERANCE
      info = ContactInfo.new
      info.normal = (v1-v0).normalize!
      info.position = 0.5 * (v1A + v1B)

      penetrationA = RMath3D::RVec3.dot((v1A - info.position), -info.normal).abs
      penetrationB = RMath3D::RVec3.dot((v1B - info.position),  info.normal).abs
      info.penetration = penetrationA + penetrationB

      return info
    end
    v2A = shapeA.get_support_point(-v1_x_v0)
    v2B = shapeB.get_support_point(v1_x_v0)
    v2 = v2B - v2A
    return nil if RMath3D::RVec3.dot(v2,v1_x_v0) <= 0.0

    # v3 : perpendicular to plane containing v0, v1 and second support point v2.
    v3 = nil
    v3A = nil
    v3B = nil
    loop do
      n = RMath3D::RVec3.cross(v1-v0, v2-v0)
      v3A = shapeA.get_support_point(-n)
      v3B = shapeB.get_support_point(n)
      v3 = v3B - v3A
      return nil if RMath3D::RVec3.dot(v3,n) <= 0.0

      if RMath3D::RVec3.dot(n, origin_ray) < 0.0 # origin is outside the plane (v0,v1,v2).
        v2A,v1A = v1A,v2A
        v2B,v1B = v1B,v2B
        v2,v1 = v1,v2  # reverse the search direction n.
        redo
      end

      if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v3,v2), v0) < 0.0 # origin is outside the plane (v0,v2,v3). See Note [3].
        v1A = v3A
        v1B = v3B
        v1 = v3
        redo
      end

      if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v1,v3), v0) < 0.0 # origin is outside the plane (v0,v3,v1). See Note [3].
        v2A = v3A
        v2B = v3B
        v2 = v3
        redo
      end

      break
    end

    # Phase 2 : Portal refinement

    hit = false
    info = nil

    loop do
      # Check if origin is inside the portal plane (v1,v2,v3).
      n_portal = RMath3D::RVec3.cross(v2-v1, v3-v1)
      n_portal.normalize!
      if !hit && RMath3D::RVec3.dot(n_portal,v1) >= 0.0
        info = ContactInfo.new
        info.normal = n_portal

        b0 = RMath3D::RVec3.dot(RMath3D::RVec3.cross(v1, v2) , v3)
        b1 = RMath3D::RVec3.dot(RMath3D::RVec3.cross(v3, v2) , v0)
        b2 = RMath3D::RVec3.dot(RMath3D::RVec3.cross(v0, v1) , v3)
        b3 = RMath3D::RVec3.dot(RMath3D::RVec3.cross(v2, v1) , v0)
        sum = b0 + b1 + b2 + b3

        if (sum <= 0)
          b0 = 0.0
          b1 = RMath3D::RVec3.dot(RMath3D::RVec3.cross(v2,v3), n_portal)
          b2 = RMath3D::RVec3.dot(RMath3D::RVec3.cross(v3,v1), n_portal)
          b3 = RMath3D::RVec3.dot(RMath3D::RVec3.cross(v1,v2), n_portal)
          sum = b1 + b2 + b3
        end

        inv = 1.0 / sum

#         info.pointA = (b0 * v0A + b1 * v1A + b2 * v2A + b3 * v3A) * inv
#         info.pointB = (b0 * v0B + b1 * v1B + b2 * v2B + b3 * v3B) * inv

        pA = (b0 * v0A + b1 * v1A + b2 * v2A + b3 * v3A) * inv
        pB = (b0 * v0B + b1 * v1B + b2 * v2B + b3 * v3B) * inv

        sA = shapeA.get_support_point(-n_portal)
        sB = shapeB.get_support_point( n_portal)

        pointA = pA + RMath3D::RVec3.dot((sA-pA), n_portal) * n_portal
        pointB = pB + RMath3D::RVec3.dot((sB-pB), n_portal) * n_portal

        info.position = 0.5 * (pointA + pointB)

        penetrationA = RMath3D::RVec3.dot((pointA - info.position), -n_portal).abs
        penetrationB = RMath3D::RVec3.dot((pointB - info.position),  n_portal).abs
        info.penetration = penetrationA + penetrationB

        hit = true
      end

      # v4 : support point in the portal's normal direction.
      v4A = shapeA.get_support_point(-n_portal)
      v4B = shapeB.get_support_point(n_portal)
      v4 = v4B - v4A

      # Check if origin is outside the support plane, and the interval distance between
      # the portal and the support plane is also checked to avoid endless loop.
      if RMath3D::RVec3.dot(v4,n_portal) <= 0.0 || RMath3D::RVec3.dot(v4-v3,n_portal) <= 1.0e-6
        return hit ? info : nil
      end

      # Portal refinement: See Note [4].
      if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v4,v1), v0) < 0.0
        if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v4,v2), v0) < 0.0
          v1A = v4A
          v1B = v4B
          v1 = v4 # New portal is (v2, v3, v4). So v1 is eliminated.
        else
          v3A = v4A
          v3B = v4B
          v3 = v4 # New portal is (v1, v2, v4). So v3 is eliminated.
        end
      else
        if RMath3D::RVec3.dot(RMath3D::RVec3.cross(v4,v3), v0) < 0.0
          v2A = v4A
          v2B = v4B
          v2 = v4 # New portal is (v1, v3, v4). So v2 is eliminated.
        else
          v1A = v4A
          v1B = v4B
          v1 = v4 # New portal is (v2, v3, v4). So v1 is eliminated.
        end
      end
    end
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
