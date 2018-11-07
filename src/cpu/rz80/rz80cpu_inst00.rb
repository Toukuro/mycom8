# 00 xxx xxx 系命令処理モジュール
module Rz80CPUInst00
  
  # Operand2 type
  OPR2_JR    = 0b000
  OPR2_LD16n = 0b001
  OPR2_LDREF = 0b010
  OPR2_INC16 = 0b011
  OPR2_INC8  = 0b100
  OPR2_DEC8  = 0b101
  OPR2_LD8n  = 0b110
  OPR2_RTSFT = 0b111

  # ===========================================================================
  # 00 命令クラスの処理
  # @param	opr1	[Integer]	第1オペランド
  # @param	opr2	[Integer] 第2オペランド
  def inst00(opr1, opr2)
    case opr2
    when OPR2_JR      # 00 xxx 000
      inst00_jr(opr1)

    when OPR2_LD16n   # 00 xxx 001
      reg16 = opr_reg16(opr1 >> 1)
      if (opr1 & 0b001).zero? then  # 16bit immediate load
        reg16.lreg.value = fetch()
        reg16.hreg.value = fetch()
      else                          # 16bit add HL += reg16
        @regs.regHL.value += reg16.value
      end

    when OPR2_LDREF   # 00 xxx 010
      inst00_ldref(opr1)

    when OPR2_INC16   # 00 xxx 011
      reg16 = opr_reg16(opr1 >> 1)
      if (opr1 & 0b001).zero? then  # 16bit increment
        @regs.inc(reg16)
      else                          # 16bit decrement
        @regs.dec(reg16)
      end

    when OPR2_INC8    # 00 xxx 100
      if opr1 == Rz80CPU::REF8_HL then      # INC   (HL)
        @alu.regTMP.value = get_ref8(@regs.regHL)
        @alu.inc(@alu.regTMP)
        set_ref8(@regs.regHL, @alu.regTMP.value)
      else                                  # INC   reg8
        @alu.inc(opr_reg8(opr1))
      end

    when OPR2_DEC8    # 00 xxx 101
      if opr1 == Rz80CPU::REF8_HL then       # DEC   (HL)
        @alu.regTMP.value = get_ref8(@regs.regHL)
        @alu.dec(@alu.regTMP)
        set_ref8(@regis.regHL, @alu.regTMP.value)
      else                          # DEC   reg8
        @alu.dec(opr_reg8(opr1))
      end

    when OPR2_LD8n    # 00 xxx 110
      if opr1 == Rz80CPU::REF8_HL then       # LD    (HL), n
        set_ref8(@regs.regHL, fetch())
      else                          # LD    reg8, n
        opr_reg8(opr1).value = fetch()
      end

    when OPR2_RTSFT   # 00 xxx 111
      inst00_rtsft(opr1)

    end
  end

	# 00 xxx 000 : 相対ジャンプ、アキュムレータ交換
  # @param	opr1	[Integer]	第1オペランド
  def inst00_jr(opr1)
    case opr1
    when 0b000    # 00 000 000    NOP
      ;
    when 0b001    # 00 001 000    EX    AF,AF'
      @alu.ex
    when 0b010    # 00 010 000    DJNZ  e
      fetch()
      if @regs.regB.value.nonzero? then
        @regs.regPC.value += @IR.value
        @regs.regB.value -= 1
      end
    when 0b011    # 00 011 000    JR    e
      fetch()
      @regs.regPC.value += @IR.value
    when 0b100    # 00 100 000    JR    NZ, e
      fetch()
      if @alu.flgZero.zero? then
        @regs.regPC.value += @IR.value
      end
    when 0b101    # 00 101 000    JR    Z, e
      fetch()
      if @alu.flgZero.nonzero? then
        @regs.regPC.value += @IR.value
      end
    when 0b110    # 00 111 000    JR    NC, e
      fetch()
      if @alu.flgCarry.zero? then
        @regs.regPC.value += @IR.value
      end
    when 0b111    # 00 111 000    JR    C, e
      fetch()
      if @alu.flgCarry.nonzero? then
        @regs.regPC.value += @IR.value
      end
    end
  end

	# 00 xxx 010 : 8bit/16bitメモリ転送
  # @param	opr1	[Integer]	第1オペランド
  def inst00_ldref(opr1)
    case opr1
    when 0b000    # 00 000 010    LD    (BC), A
      set_ref8(@regs.regBC, @alu.regA.value)
    when 0b001    # 00 001 010    LD    A, (BC)
      @alu.regA = get_ref8(@regs.regBC)
    when 0b010    # 00 010 010    LD    (DE), A
      set_ref8(@regs.regDE, @alu.regA.value)
    when 0b011    # 00 011 010    LD    A, (DE)
      @alu.regA = get_ref8(@regs.regDE)
    when 0b100    # 00 100 010    LD    (nn), HL
      @AD.lreg.value = fetch()
      @AD.hreg.value = fetch()
      set_ref16(@AD, @regs.regHL.value)
    when 0b101    # 00 101 010    LD    HL, (nn)
      @AD.lreg.value = fetch()
      @AD.hreg.value = fetch()        
      @regs.regHL = get_ref16(@AD)
    when 0b110    # 00 110 010    LD    (nn), A
      @AD.lreg.value = fetch()
      @AD.hreg.value = fetch()
      set_ref8(@AD, @alu.regA.value)
    when 0b111    # 00 111 010    LD    A, (nn)
      @AD.lreg.value = fetch()
      @AD.hreg.value = fetch()
      @alu.regA = get_ref8(@AD)
    end
  end

	# 00 xxx 111 : 8bitローテート/シフト
  # @param	opr1	[Integer]	第1オペランド
  def inst00_rtsft(opr1)
    case opr1
    when 0b000    # 00 000 111    RLCA
      @alu.rlcA
    when 0b001    # 00 001 111    RRCA
      @alu.rrcA
    when 0b010    # 00 010 111    RLA
      @alu.rlA
    when 0b011    # 00 011 111    RRA  
      @alu.rrA
    when 0b100    # 00 100 111    DAA
      @alu.daA
    when 0b101    # 00 101 111    CPL
      @alu.cpl
    when 0b110    # 00 110 111    SCF
      @alu.scf
    when 0b111    # 00 111 111    CCF
      @alu.ccf
    end
	end
end