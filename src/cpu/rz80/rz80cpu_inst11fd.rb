# FD xx 系命令処理モジュール
module Rz80CPUInst11FD
  # ---------------------------------------------------------------------------
  def inst11_FD00(opr1, opr2)
    #puts "inst11_FD00(#{opr1}, #{opr2})"

    case inst_opr2
    when 0b000      # FD 10 xxx 000
    when 0b001
    when 0b010
    when 0b011
    when 0b100
    when 0b101
    when 0b110
    when 0b111
    end
  end
  
  # ---------------------------------------------------------------------------
  def inst11_FD01(opr1, opr2)
    #puts "inst11_FD01(#{opr1}, #{opr2})"

    case inst_opr2
    when 0b000      # FD 10 xxx 000
    when 0b001
    when 0b010
    when 0b011
    when 0b100
    when 0b101
    when 0b110
    when 0b111
    end
  end
  
  # ---------------------------------------------------------------------------
  def inst11_FD10(opr1, opr2)
    #puts "inst11_FD10(#{opr1}, #{opr2})"

    case inst_opr2
    when 0b000      # FD 10 xxx 000
    when 0b001
    when 0b010
    when 0b011
    when 0b100
    when 0b101
    when 0b110
    when 0b111
    end
  end
  
  # ---------------------------------------------------------------------------
  def inst11_FD11(opr1, opr2)
    #puts "inst11_FD11(#{opr1}, #{opr2})"

    case inst_opr2
    when 0b000      # FD 10 xxx 000
    when 0b001
    when 0b010
    when 0b011
      case inst_opr1
      when 0b001    # DD 11 001 011   -> FD CB xx
        inst11_CB(@IR.value)
      when 0b100    # DD 11 100 011   EX  (SP), IY
        
      end
    when 0b100
    when 0b101
    when 0b110
    when 0b111
    end
  end
	
end