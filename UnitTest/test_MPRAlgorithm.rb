require 'rmath3d/rmath3d'
include RMath3D

class TC_MPRAlgorithm < MiniTest::Test
  def setup
  end

  def teardown
  end

  def test_intersect_boxes
    box0 = MPRAlgorithm::Box.new
    box1 = MPRAlgorithm::Box.new

    box0.center.setElements( 0.0, 0.0, 0.0 )
    box0.half.setElements( 0.5, 0.5, 0.5 )
    box0.orientation = RQuat.new( 0.0,0.0,0.0, 1.0 )

    box1.center.setElements( 1.0, 0.0, 0.0 )
    box1.half.setElements( 0.5, 0.5, 0.5 )
    box1.orientation = RQuat.new.rotationAxis( RVec3.new(0,0,1), Math::PI/4 )

    result = MPRAlgorithm.intersect( box0, box1 )
    assert( true == result )
  end
end
