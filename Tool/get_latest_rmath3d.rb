require 'open-uri'
open( '../rmath3d_plain.rb', 'w' ) do |file|
  file << open('https://raw.github.com/vaiorabbit/rmath3d/master/lib/rmath3d/rmath3d_plain.rb').read
end
