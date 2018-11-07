# ED xx 系命令処理モジュール
module Rz80CPUInst11ED
	# ---------------------------------------------------------------------------
	# EX 01 xxx xxx 
  # @param opr1 [Integer] オペランド１
  # @param opr2 [Integer] オペランド２
  def inst11_ED01(opr1, opr2)
    puts "inst11_ED01(#{opr1}, #{opr2})"
  
    case opr2
    when 0b000    # ED 01 xxx 000
      if opr1 == Rz80CPU::REF8_HL then    # ED 01 110 000   IN    (HL), (C)
        @alu.regTMP.value = @port[@regs.regC.value]
        set_ref16(@regs.regHL, @alu.regTMP.value)
      else                                # ED 01 rrr 000   IN      r, (C)
        reg8 = get_reg8(opr1)
        reg8.value = @port[@regs.regC.value]
      end
    when 0b001    # ED 01 xxx 001
      if opr1 == Rz80CPU::REF8_HL then    # ED 01 110 001   OUT   (C), (HL)
        @alu.regTMP.value = get_ref8(@regs.regHL)
        @port[@regs.regC.value] = @alu.regTMP.value
      else                                # ED 01 rrr 001   OUT   (C), r
        reg8 = get_reg8(opr1)
        @port[@regs.regC.value] = reg8.value
      end
    when 0b010    # ED 01 xxx 010
      reg16 = get_reg16(opr1 >> 1)
      if (opr1 & 0b001).zero? then        # ED 01 rr0 010   SBC   HL, rr
        @regs.regHL.value -= reg16.value - @alu.flgCarry
        @alu.flgNegate = 0
      else                                # ED 01 rr1 010   ADC   HL, rr
        @regs.regHL.value += reg16.value + @alu.flgCarry
        @alu.flgNegate = 0
      end 
    when 0b011    # ED 01 xxx 011
      reg16 = opr_reg16(opr1 >> 1)
      @AD.lreg.value = fetch()
      @AD.hreg.value = fetch()
      if (opr1 & 0b001).zero? then        # ED 01 rr0 011   LD    (nn), reg16
        set_ref16(@AD, reg16.value)
      else                                # ED 01 rr1 011   LD    reg16, (nn)
        reg16.value = get_ref16(@AD)
      end
    when 0b100    # ED 01 xxx 100
      case opr1
      when 0b000                           # ED 01 000 100   NEG
        @alu.regTMP.value = @alu.regA.value
        @alu.regA.value   = 0
        @alu.subA
      else
        raise VmCpuInstructionError
      end
    when 0b101    # ED 01 xxx 101
      case opr1
      when 0b000                          # ED 01 000 101   RETN
        # マスク不能割り込みの終了
      when 0b001                          # ED 01 001 101   RETI
        # 割り込み処理の終了
      else
        raise VmCpuInstructionError
      end
    when 0b110    # ED 01 xxx 110
      case opr1
      when 0b000                          # ED 01 000 110   IM    0
        # 割り込みモード0
      when 0b010                          # ED 01 010 110   IM    1
        # 割り込みモード1
      when 0b011                          # ED 01 011 110   IM    2
        # 割り込みモード2
      else
        raise VmCpuInstructionError
      end
    when 0b111    # ED 01 xxx 111
      case opr1
      when 0b000                          # ED 01 000 111   LD    I, A
        @regs.regI.value = @alu.regA.value
      when 0b001                          # ED 01 001 111   LD    R, A
        @regs.regR.value = @alu.regA.value
      when 0b010                          # ED 01 010 111   LD    A, I
        @alu.regA.value = @regs.regI.value
      when 0b011                          # ED 01 011 111   LD    A, R
        @alu.regA.value = @regs.regR.value
      when 0b100                          # ED 01 100 111   RRD
        @alu.regTMP.value = get_ref8(@regs.regHL)
        t_nib = @alu.regA.lnib
        @alu.regA.lnib = @alu.regTMP.lnib
        @alu.regTMP.value = (t_nib << 4) | @alu.regTMP.hnib
        set_ref8(@regs.regHL, @alu.regTMP.value)
      when 0b101                          # ED 01 101 111   RLD
        @alu.regTMP.value = get_ref8(@regs.regHL)
        t_nib = @alu.regA.lnib
        @alu.regA.lnib = @alu.regTMP.hnib
        @alu.regTMP.value = (@alu.regTMP.lnib << 4) | t_nib
        set_ref8(@regs.regHL, @alu.regTMP.value)
      else
        raise VmCpuInstructionError
      end
    end
  end 
  
  # ---------------------------------------------------------------------------
	#
  # @param opr1 [Integer] オペランド１
  # @param opr2 [Integer] オペランド２
  def inst11_ED10(opr1, opr2)
    puts "inst11_ED10(#{opr1}, #{opr2})"

    case opr2
    when 0b000    # ED 10 xxx 000
      case opr1
      when 0b100    # ED 10 100 000   LDI
        inst11_LDI
      when 0b101    # ED 10 101 000   LDD
        inst11_LDD
      when 0b110    # ED 10 110 000   LDIR
        while @regs.regBC.value.nonzero?
          inst11_LDI
        end
      when 0b111    # ED 10 111 000   LDDR
        while @regs.regBC.value.nonzero?
          inst11_LDD
        end
      else
        raise VmCpuInstructionError
      end
    when 0b001    # ED 10 xxx 001
      case opr1
      when 0b100                          # ED 10 100 001   CPI
        inst11_CPI
      when 0b101                          # ED 10 101 001   CPD
        inst11_CPD
      when 0b110                          # ED 10 110 001   CPIR
        while @regs.regBC.value.nonzero?
          inst11_CPI
        end
      when 0b111                          # ED 10 111 001   CPDR
        while @regs.regBC.value.nonzero?
          inst11_CPD
        end
      else
        raise VmCpuInstructionError
      end
    when 0b010    # ED 10 xxx 010
      case opr1
      when 0b100                          # ED 10 100 010   INI
        inst11_INI
      when 0b101                          # ED 10 101 010   IND
        inst11_IND
      when 0b110                          # ED 10 110 010   INIR
        while @regs.regBC.value.nonzero?
          inst11_INI
        end
      when 0b111                          # ED 10 111 010   INDR
        while @regs.regBC.value.nonzero?
          inst11_IND
        end
      else
        raise VmCpuInstructionError
      end
    when 0b011    # ED 10 xxx 011
      case opr1
      when 0b100                          # ED 10 100 011   OUTI
        inst11_OUTI
      when 0b101                          # ED 10 101 011   OUTD
        inst11_OUTD
      when 0b110                          # ED 10 110 011   OUTIR
        while @regs.regBC.value.nonzero?
          inst11_OUTI
        end
      when 0b111                          # ED 10 111 011   OUTDR
        while @regs.regBC.value.nonzero?
          inst11_OUTD
        end
      else
        raise VmCpuInstructionError
      end
    else
      raise VmCpuInstructionError
    end
  end

  # メモリ転送（加算）
  def inst11_LDI
    set_ref8(@regs.regDE, get_ref8(@regs.regHL))
    @regs.inc(@regs.regDE)
    @regs.inc(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgParity = @regs.regBC.value.zero? ? 0 : 1
    @alu.flgNegate = 0
    @alu.flgHCarry = 0
  end
  
  # メモリ転送（減算）
  def inst11_LDD
    set_ref8(@regs.regDE, get_ref8(@regs.regHL))
    @regs.dec(@regs.regDE)
    @regs.dec(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgParity = @regs.regBC.value.zero? ? 0 : 1
    @alu.flgNegate = 0
    @alu.flgHCarry = 0
  end
  
  # メモリ比較（加算）
  def inst11_CPI
    @alu.regTMP.value = get_ref8(@regs.regHL)
    @alu.cpA
    @regs.inc(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgParity = @regs.regBC.value.zero? ? 0 : 1
  end
  
  # メモリ比較（減算）
  def inst11_CPD
    @alu.regTMP.value = get_ref8(@regs.regHL)
    @alu.cpA
    @regs.dec(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgParity = @regs.regBC.value.zero? ? 0 : 1
  end
  
  # I/O入力転送（加算）
  def inst11_INI
    set_ref8(@regs.regHL, @port[@regs.regC.value])
    @regs.inc(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgNegate = 1
    @alu.flgZero   = @regs.regBC.value.zero? ? 1 : 0
  end
  
  # I/O入力転送（減算）
  def inst11_IND
    set_ref8(@regs.regHL, @port[@regs.regC.value])
    @regs.dec(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgNegate = 1
    @alu.flgZero   = @regs.regBC.value.zero? ? 1 : 0
  end
  
  # I/O出力転送（加算）
  def inst11_OUTI
    @port[@regs.regC.value] = get_ref8(@regs.regHL)
    @regs.inc(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgNegate = 1
    @alu.flgZero   = @regs.regBC.value.zero? ? 1 : 0
  end
  
  # I/O出力転送（減算）
  def inst11_OUTD
    @port[@regs.regC.value] = get_ref8(@regs.regHL)
    @regs.dec(@regs.regHL)
    @regs.dec(@regs.regBC)
    @alu.flgNegate = 1
    @alu.flgZero   = @regs.regBC.value.zero? ? 1 : 0
  end
end