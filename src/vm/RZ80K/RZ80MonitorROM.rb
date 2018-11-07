require "../lib/rombase"
class RZ80MonitorROM < ROMBase
	
	def initialize()
		super(TNibble, Byte)
		write_byfile("../vm/RZ80K/NEWMON.ROM")
	end 
end 