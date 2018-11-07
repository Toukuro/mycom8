# DD xx 系命令処理モジュール
module Rz80CPUInst11DD
  # ===========================================================================
  def inst11_DD00(opr1, opr2)
    #puts "inst11_DD00(#{opr1}, #{opr2})"
    inst11_IX00(@regs.regIX, opr1, opr2)
  end
  
  def inst11_FD00(opr1, opr2)
    #puts "inst11_FD00(#{opr1}, #{opr2})"
    inst11_IX00(@regs.regIY, opr1, opr2)
  end
  
  # ---------------------------------------------------------------------------
  def inst11_DD01(opr1, opr2)
    #puts "inst11_DD01(#{opr1}, #{opr2})"
    inst11_IX01(@regs.regIX, opr1, opr2)
  end

  def inst11_FD01(opr1, opr2)
    #puts "inst11_FD01(#{opr1}, #{opr2})"
    inst11_IX01(@regs.regIY, opr1, opr2)
  end
  
  # ---------------------------------------------------------------------------
  def inst11_DD10(opr1, opr2)
    #puts "inst11_DD10(#{opr1}, #{opr2})"
    inst11_IX10(@regs.regIX, opr1, opr2)
  end
  
  def inst11_FD10(opr1, opr2)
    #puts "inst11_FD10(#{opr1}, #{opr2})"
    inst11_IX10(@regs.regIY, opr1, opr2)
  end
  
  # ---------------------------------------------------------------------------
  def inst11_DD11(opr1, opr2)
    #puts "inst11_DD11(#{opr1}, #{opr2})"
    inst11_IX11(@regs.regIX, opr1, opr2)
  end
  
  def inst11_FD11(opr1, opr2)
    #puts "inst11_FD11(#{opr1}, #{opr2})"
    inst11_IX11(@regs.regIY, opr1, opr2)
  end
  
  # ===========================================================================
  def inst11_IX00(regIdx, opr1, opr2)
    case opr2
    when 0b001      # DD/FD 00 xxx 001
      case opr1
      when 0b000    # DD/FD 00 000 001    ADD   IX/IY, BC
        @regs.add(regIdx, @regs.regBC.value)
      when 0b011    # DD/FD 00 011 001    ADD   IX/IY, DE
        @regs.add(regIdx, @regs.regDE.value)
      when 0b100    # DD/FD 00 100 001    LD    IX/IY, nn
        regIdx.lreg.value = fetch()
        regIdx.hreg.value = fetch()
      when 0b101    # DD/FD 00 101 001    ADD   IX/IY, HL
        @regs.add(regIdx, @regs.regHL.value)
      when 0b111    # DD/FD 00 111 001    ADD   IX/IY, SP
        @regs.add(regIdx, @regs.regSP.value)
      else
        raise VmCpuInstructionError
      end
    when 0b010      # DD/FD 00 xxx 010
      case opr1
      when 0b100    # DD/FD 00 100 010    LD    (nn), IX/IY
        @AD.lreg.value = fetch()
        @AD.hreg.value = fetch()
        set_ref16(@AD, regIdx)
      when 0b101    # DD/FD 00 101 010    LD    IX/IY, (nn)
        @AD.lreg.value = fetch()
        @AD.hreg.value = fetch()
        regIdx.value = get_ref16(@AD)
      else
        raise VmCpuInstructionError
      end
    when 0b011      # DD/FD 00 xxx 011
      case opr1
      when 0b100    # DD/FD 00 100 011    INC   IX/IY
        @regs.inc(regIdx)
      when 0b101    # DD/FD 00 101 011    DEC   IX/IY
        @regs.dec(regIdx)
      else
        raise VmCpuInstructionError
      end
    when 0b100      # DD/FD 00 xxx 100
      case opr1
      when 0b100    # DD/FD 00 100 100    INC   IXH/IYH
        @alu.inc(regIdx.hreg)        
      when 0b101    # DD/FD 00 101 100    INC   IXL/IYL
        @alu.inc(regIdx.lreg)
      when 0b110    # DD/FD 00 110 100    INC   (IX/IY+d)
        disp = fetch()
        @alu.regTMP.value = get_ref8idx(regIdx, disp)
        @alu.inc(@alu.regTMP)
        set_ref8idx(regIdx, disp, @alu.regTMP.value)
      else
        raise VmCpuInstructionError
      end
    when 0b101      # DD/FD 00 xxx 101
      case opr1
      when 0b100    # DD/FD 00 100 101    DEC   IXH/IYH
        @alu.inc(regIdx.hreg)
      when 0b101    # DD/FD 00 101 101    DEC   IXL/IYL
        @alu.inc(regIdx.lreg)
      when 0b110    # DD/FD 00 110 101    DEC   (IX/IY+d)
        disp = fetch()
        @alu.regTMP.value = get_ref8idx(regIdx, disp)
        @alu.inc(@alu.regTMP)
        set_reg8idx(regIdx, disp, @alu.regTMP.value)
      else
        raise VmCpuInstructionError
      end
    when 0b110      # DD/FD 00 xxx 110
      case opr1
      when 0b100    # DD/FD 00 100 110    LD    IXH/IYH, n
        regIdx.hreg.value = fetch()
      when 0b101    # DD/FD 00 101 110    LD    IXL/IYL, n
        regIdx.lreg.value = fetch()
      when 0b110    # DD/FD 00 110 110    LD    (IX/IY+d), n
        disp = fetch()
        set_ref8idx(regIdx, disp, fetch())
      else
        raise VmCpuInstructionError
      end
    else
      raise VmCpuInstructionError
    end
  end
  
  # ---------------------------------------------------------------------------
  #
  def inst11_IX01(regIdx, opr1, opr2)
    case opr2
    when 0b000      # DD/FD 01 xxx 000
      case opr1
      when 0b100    # DD/FD 01 100 000    LD    IXH/IYH, B
        regIdx.hreg.value = @regs.regB.value
      when 0b101    # DD/FD 01 101 000    LD    IXL/IYL, B
        regIdx.lreg.value = @regs.regB.value
      when 0b110    # DD/FD 01 110 000    LD    (IX/IY+d), B
        disp = fetch()
        set_ref8idx(regIdx, disp, @regs.regB.value)
      else
        raise VmCpuInstructionError
      end
    when 0b001      # DD/FD 01 xxx 001
      case opr1
      when 0b100    # DD/FD 01 100 000    LD    IXH/IYH, C
        regIdx.hreg.value = @regs.regC.value
      when 0b101    # DD/FD 01 101 000    LD    IXL/IYL, C
        regIdx.lreg.value = @regs.regC.value
      when 0b110    # DD/FD 01 110 000    LD    (IX/IY+d), C
        disp = fetch()
        set_ref8idx(regIdx, disp, @regs.regC.value)
      else
        raise VmCpuInstructionError
      end
    when 0b010      # DD/FD 01 xxx 010
      case opr1
      when 0b100    # DD/FD 01 100 000    LD    IXH/IYH, D
        regIdx.hreg.value = @regs.regD.value
      when 0b101    # DD/FD 01 101 000    LD    IXL/IYL, D
        regIdx.lreg.value = @regs.regD.value
      when 0b110    # DD/FD 01 110 000    LD    (IX/IY+d), D
        disp = fetch()
        set_ref8idx(regIdx, disp, @regs.regD.value)
      else
        raise VmCpuInstructionError
      end
    when 0b011      # DD/FD 01 xxx 011
      case opr1
      when 0b100    # DD/FD 01 100 000    LD    IXH/IYH, E
        regIdx.hreg.value = @regs.regE.value
      when 0b101    # DD/FD 01 101 000    LD    IXL/IYL, E
        regIdx.lreg.value = @regs.regE.value
      when 0b110    # DD/FD 01 110 000    LD    (IX/IY+d), E
        disp = fetch()
        set_ref8idx(regIdx, disp, @regs.regD.value)
      else
        raise VmCpuInstructionError
      end
    when 0b100      # DD/FD 01 xxx 100
      case opr1
      when 0b000, 0b001, 0b010, 0b011, 0b111 
                    # DD/FD 01 rrr 100    LD    r, IXH/IYH
        reg8 = opr_reg8(opr1)
        reg8.value = regIdx.hreg.value
      when 0b100    # DD/FD 01 100 100    LD    IXH/IYH, H
        regIdx.hreg.value = @regs.regH.value
      when 0b101    # DD/FD 01 101 100    LD    IXL/IYL, H
        regIdx.lreg.value = @regs.regL.value
      when 0b110    # DD/FD 01 110 100    LD    (IX/IY+d), H
        disp = fetch()
        set_ref8idx(regIdx, disp, @regs.regH.value)
      else
        raise VmCpuInstructionError
      end
    when 0b101      # DD/FD 01 xxx 101
      case opr1
      when 0b000, 0b001, 0b010, 0b011, 0b111
                    # DD/FD 01 rrr 101    LD    r, IXL/IYL
        reg8 = opr_reg8(opr1)
        reg8.value = regIdx.lreg.value
      when 0b100    # DD/FD 01 100 101    LD    IXH/IYH, L
        regIdx.hreg.value = @regs.regL.value
      when 0b101    # DD/FD 01 101 101    LD    IXL/IYL, L
        regIdx.lreg.value = @regs.regL.value
      when 0b110    # DD/FD 01 110 101    LD    (IX/IY+d), L
        disp = fetch()
        set_ref8idx(regIdx, disp, @regs.regL.value)
      else
        raise VmCpuInstructionError
      end
    when 0b110      # DD/FD 01 xxx 110    LD    r, (IX/IY+d)
      if opr1 == 0b110 then
        raise VmCpuInstructionError
      else
        disp = fetch()
        reg8 = opr_reg8(opr1)
        reg8.value = get_ref8idx(regIdx, disp)
      end
    when 0b111      # DD/FD 01 xxx 111
      case opr1
      when 0b100    # DD/FD 01 100 000    LD    IXH/IYH, A
        regIdx.hreg.value = @alu.regA.value
      when 0b101    # DD/FD 01 101 000    LD    IXL/IYL, A
        regIdx.lreg.value = @alu.regA.value
      when 0b110    # DD/FD 01 110 000    LD    (IX/IY+d), A
        disp = fetch()
        set_ref8idx(regIdx, disp, @alu.regA.value)
      else
        raise VmCpuInstructionError
      end
    else
      raise VmCpuInstructionError
    end
  end
  
  # ---------------------------------------------------------------------------
  #
  def inst11_IX10(regIdx, opr1, opr2)
    case opr2
    when 0b100      # DD/FD 10 xxx 100
      @alu.regTMP.value = regIdx.hreg.value
    when 0b101      # DD/FD 10 xxx 101
      @alu.regTMP.value = regIdx.lreg.value
    when 0b110      # DD/FD 10 xxx 110
      disp = fetch()
      @alu.regTMP.value = get_ref8idx(regIdx, disp)
    else
      raise VmCpuInstructionError
    end
    
    case opr1     # DD/FD 10 000 100    ADD   A, (IX/IY+d)
    when OPR8_ADD
      @alu.addA
    when OPR8_ADC # DD/FD 10 001 100    ADC   A, (IX/IY+d)
      @alu.adcA
    when OPR8_SUB # DD/FD 10 010 100    SUB   A, (IX/IY+d)
      @alu.subA
    when OPR8_SBC # DD/FD 10 011 100    SBC   A, (IX/IY+d)
      @alu.sbcA
    when OPR8_AND # DD/FD 10 100 100    AND   (IX/IY+d)
      @alu.andA
    when OPR8_XOR # DD/FD 10 101 100    XOR   (IX/IY+d)
      @alu.xorA
    when OPR8_OR  # DD/FD 10 110 100    OR    (IX/IY+d)
      @alu.orA
    when OPR8_CP  # DD/FD 10 111 100    CP    (IX/IY+d)
      @alu.cpA
    end
  end
  
  # ---------------------------------------------------------------------------
  #
  def inst11_IX11(regIdx, opr1, opr2)
    case opr2
    when 0b001      # DD/FD 11 xxx 001
      case opr1
      when 0b100    # DD/FD 11 100 001    POP   IX/IY
        regIdx.value = pop16()
      when 0b101    # DD/FD 11 101 001    JP    (IX/IY)
        @regs.regPC.value = regIdx.value
      when 0b111    # DD/FD 11 111 001    LD    SP, IX/IY
        @regs.regSP.value = regIdx.value
      else
        raise VmCpuInstructionError
      end
    when 0b011      # DD/FD 11 xxx 011
      case opr1
      when 0b001    # DD/FD 11 001 011   -> DD/FD CB xx
        fetch()
        inst11_CB(inst_div, inst_opr1, inst_opr2)
      when 0b100    # DD/FD 11 100 011   EX  (SP), IX/IY
        @AD.value = get_ref16(@regs.regSP)
        set_ref16(@regs.regSP, regIdx.value)
        regIdx.value = @AD.value
      else
        raise VmCpuInstructionError
      end
    when 0b101      # DD/FD 11 xxx 101
      case opr1
      when 0b100    # DD/FD 11 100 101    PUSH    IX/IY
        push16(regIdx.value)
      else
        raise VmCpuInstructionError
      end
    else
      raise VmCpuInstructionError
    end
  end
end