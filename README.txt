=  MPRTest : A demonstration of the Minkowski Portal Refinement algorithm

Demonstrates intersection tests with the Minkowski Portal Refinement
(MPR) algorithm, introduced by Gary Snethen.

                                             Last Update: Jul 20, 2013
                                                   Since: Nov 16, 2008
                                                  by  vaiorabbit
== Prerequisites

* Ruby Interpreter <http://www.ruby-lang.org/>
  * Version : 1.9.3 or higher
  * RubyInstaller For Windows :
    * http://rubyinstaller.org

* GLUT
  * Copy GLUT DLL (glut32.dll, etc.) somewhere in your PATH.
  * Tested with freeglut (http://freeglut.sourceforge.net).

* ruby-opengl <https://rubygems.org/gems/opengl>
  * Current version : 0.80.0
  * Available via RubyGems ($ gem install opengl).

* rmath3d <https://github.com/vaiorabbit/rmath3d>
  * Use 'Tool/get_latest_rmath3d.rb'

== Usage

X:\> ruby Application.rb

* The two objects are rendered with transparency when the intersection
  test (+MPRAlgorithm::intersect()+) returns +true+;


== Operation

* Q or Esc     : quit.
* Space        : reset the objects' setting.
* WASD         : move red object.
* Z            : change type of shape0 (red)
* IJKL         : move blue object.
* M            : change type of shape1 (blue)
* Mouse L/R    : move eye position.


== Reference

* Game Programming Gems 7 <http://www.charlesriver.com/Books/BookDetail.aspx?productID=373>
  * See "2.5 XenoCollide: Complex Collision Made Simple" for algorithm details.

* XenoCollide <http://xenocollide.com>
  * Support site maintained by Gary Snethen, the author of the GPG7 article.

* mpr2d <http://code.google.com/p/mpr2d/>
  * A 2D implementation of the MPR algorithm by Mason Green.


== Notice

* The MPR algorithm is not limited for intersection detection, but
  also capable of finding contact information (contact normal,
  etc.). See GPG7 for details.


== Credits

* vaiorabbit
  * https://twitter.com/vaiorabbit
  * http://sites.google.com/site/ltsevenscore/

 
== License

All source codes are available under the terms of the zlib/libpng license
(see LICENSE.txt).
