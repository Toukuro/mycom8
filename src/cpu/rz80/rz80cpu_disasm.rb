class Rz80CPUDisAssembler < Rz80CPUController
	
	
	def Nop
		puts "NOP"
	end 
	
	def ExAF
		puts "EX		AF, AF'"
	end 
	
	def Djnz(e)
		puts "DJNZ	"
	end 
	
	def JrCond(opr)
	end 
	
	def Ld16Imd(opr)
	end 
	
	def Add16Imd(opr)
	end 
	
	def Ld8Ref(opr)
	end 
	
	def IncReg16(opr)
	end 
	
	def DecReg16(opr)
	end 
	
	def IncReg8(opr)
	end 
	
	def DecReg8(opr)
	end 
	
	def Ld8Imd(opr)
	end 
	
	def AccumOpr(opr)
	end 

end