require "lib/basicmemory"
require "lib/ioaccess"

# リニアなメモリクラス
class LinearMemory < BasicMemory
  
  # IOAccessをMix-in
  include IOAccess
  
end