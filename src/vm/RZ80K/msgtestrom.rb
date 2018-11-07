require "../lib/rombase"

class MsgTestROM < ROMBase

  def initialize()
    super(Bit6, Byte)
    write_byfile("../vm/RZ80K/msgtest2.bin")
  end
end 