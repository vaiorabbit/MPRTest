<!-- -*- mode:markdown; coding:utf-8; -*- -->

# MPRTest : A demonstration of the Minkowski Portal Refinement algorithm #

Demonstrates intersection tests with the Minkowski Portal Refinement
(MPR) algorithm, introduced by Gary Snethen.

*   Last Update: Jul 20, 2013
*   Since: Nov 16, 2008

Example:
*   Cone-Cylinder (not colliding) <img src="https://raw.githubusercontent.com/vaiorabbit/MPRTest/master/doc/Result00.png" width="350">
*   Cone-Cylinder (detected colliding position and penetration) <img src="https://raw.githubusercontent.com/vaiorabbit/MPRTest/master/doc/Result01.png" width="350">

## Prerequisites ##

*   Ruby Interpreter <http://www.ruby-lang.org/>
    *   Version : 2.0.0 or higher
    *   RubyInstaller For Windows :
        *   http://rubyinstaller.org

*   GLUT
  *   Copy GLUT DLL (glut32.dll or freeglut.dll) here.
  *   freeglut (http://freeglut.sourceforge.net).

*   opengl-bindings
    *   Available via RubyGems.

            $ gem install opengl-bindings

    *   Ref.:
        *   https://rubygems.org/gems/opengl-bindings
        *   https://github.com/vaiorabbit/ruby-opengl

*   rmath3d
    *   Available via RubyGems

            $ gem install rmath3d

    *   Notice: This library provides native extension. You must setup develop environment (or DevKit) before installation.

    *   Ref.:
        *    https://rubygems.org/gems/rmath3d
        *    https://github.com/vaiorabbit/rmath3d
        *    http://blog.mattwynne.net/2010/10/12/installing-ruby-gems-with-native-extensions-on-windows/

## Usage ##

    X:\> ruby Application.rb

*   The two objects are rendered with transparency when the intersection
    test (`MPRAlgorithm::get_contact()`) returns `true`;


## Operation ##

*   Q or Esc     : quit.
*   Space        : reset the objects' setting.
*   WASD         : move red object.
*   Z            : change type of shape0 (red)
*   IJKL         : move blue object.
*   M            : change type of shape1 (blue)
*   Mouse L/R    : move eye position.


## Reference ##

*   Game Programming Gems 7 <http://www.charlesriver.com/Books/BookDetail.aspx?productID=373>
    *   See "2.5 XenoCollide: Complex Collision Made Simple" for algorithm details.

*   XenoCollide <http://xenocollide.com>
    *   Support site maintained by Gary Snethen, the author of the GPG7 article.

*   mpr2d <http://code.google.com/p/mpr2d/>
    *   A 2D implementation of the MPR algorithm by Mason Green.


## License ##

All source codes are available under the terms of the zlib/libpng license
(see LICENSE.txt).

-------------------------------------------------------------------------------

# MPRTest : Minkowski Portal Refinement アルゴリズムのデモプログラム #

Gary Snethen 氏による Minkowski Portal Refinement (MPR) アルゴリズムのデモプログラムです。


## 必要なもの ##

*   Ruby <http://www.ruby-lang.org/>
    *   バージョン : 2.0.0 以降
    *   RubyInstaller For Windows :
        *   http://rubyinstaller.org

*   GLUT
  *   GLUTのDLL (glut32.dll もしくは freeglut.dll) をここにコピーしてください.
  *   freeglut (http://freeglut.sourceforge.net).

*   opengl-bindings
    *   RubyGems でインスールできます。

            $ gem install opengl-bindings

    *   参考:
        *   https://rubygems.org/gems/opengl-bindings
        *   https://github.com/vaiorabbit/ruby-opengl

*   rmath3d
    *   RubyGems でインスールできます。

            $ gem install rmath3d

    *   注意: このライブラリはC言語を利用しているため、インストール時にビルドが必要です。インストールの前に開発環境の用意が必要です。

    *   Ref.:
        *    https://rubygems.org/gems/rmath3d
        *    https://github.com/vaiorabbit/rmath3d
        *    http://blog.mattwynne.net/2010/10/12/installing-ruby-gems-with-native-extensions-on-windows/


## 使い方 ##

    X:\> ruby Application.rb

*   交差判定 (`MPRAlgorithm::get_contact()`) が true となる場合に、2つの箱が半透明で描画されます。


## Operation ##

*   Q または Esc         : プログラムの終了
*   Space                : オブジェクトの設定をリセット
*   WASD                 : 赤いオブジェクトの移動
*   Z                    : 赤いオブジェクトの形状変更
*   IJKL                 : 青いオブジェクトの移動
*   M                    : 青いオブジェクトの形状変更
*   マウスでの L/R       : 視点の移動


## 参考文献 ##

*   Game Programming Gems 7 <http://www.charlesriver.com/Books/BookDetail.aspx?productID=373>
    *   "2.5 XenoCollide: Complex Collision Made Simple" にアルゴリズムの詳細が掲載されています。

*   XenoCollide <http://xenocollide.com>
    *   Gary Snethen 氏（上記GPG7の著者）によるサポートサイトです。

*   mpr2d <http://code.google.com/p/mpr2d/>
    *   Mason Green 氏による 2D版のデモプログラムです。


## License ##

ソースコードは zlib/libpng ライセンスの条件下で利用可能です。
