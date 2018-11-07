require "../lib/ioportbase"

class Rz80IO < IOPortBase

    def initialize
      super(Byte, Byte)
    end 
end 