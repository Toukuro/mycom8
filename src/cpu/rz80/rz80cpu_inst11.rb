# 11 xxx xxx 系命令処理モジュール
module Rz80CPUInst11

  # Operand2 Type
  OPR2_RET    = 0b000
  OPR2_POP    = 0b001
  OPR2_JP     = 0b010
  OPR2_IOEX   = 0b011
  OPR2_CALL   = 0b100
  OPR2_PUSH   = 0b101
  OPR2_ALTH8  = 0b110
  OPR2_RST    = 0b111
  
  # 11 命令クラスの処理
  # @param opr1 [Integer] オペランド１（演算種別）
  # @param opr2 [Integer] オペランド２（対象レジスタ）
  def inst11(opr1, opr2)
    #puts "inst11(#{opr1}, #{opr2})"
    case opr2
    when OPR2_RET       # 11 xxx 000
      inst11_ret(opr1)
    when OPR2_POP       # 11 xxx 001
      inst11_pop(opr1)
    when OPR2_JP        # 11 xxx 010
      inst11_jp(opr1)
    when OPR2_IOEX      # 11 xxx 011
      inst11_ioex(opr1)
    when OPR2_CALL      # 11 xxx 100
      inst11_call(opr1)
    when OPR2_PUSH      # 11 xxx 101
      inst11_push(opr1)
    when OPR2_ALTH8     # 11 xxx 110
      inst11_alth8(opr1)
    when OPR2_RST       # 11 xxx 111
      @regs.regPC.value = opr1 * 8
    end
  end

  # 11 命令クラス（11 xxx 000）
  # @param opr1 [Integer] オペランド１
  def inst11_ret(opr1)
    #puts "inst11_ret(#{opr1})"
    case opr1
    when 0b000    # 11 000 000    RET   NZ
      if @alu.flgZero.zero? then
        @regs.regPC.value = pop16()
      end
    when 0b001    # 11 001 000    RET   Z
      if @alu.flgZero.nonzero? then
        @regs.regPC.value = pop16()
      end 
    when 0b010    # 11 010 000    RET   NC
      if @alu.flgCarry.zero? then
        @regs.regPC.value = pop16()
      end 
    when 0b011    # 11 011 000    RET   C
      if @alu.flgCarry.nonzero? then
        @regs.regPC.value = pop16()
      end 
    when 0b100    # 11 100 000    RET   PO
      if @alu.flgParity.zero? then
        @regs.regPC.value = pop16()
      end 
    when 0b101    # 11 101 000    RET   PE
      if @alu.flgParity.nonzero? then
        @regs.regPC.value = pop16()
      end 
    when 0b110    # 11 110 000    RET   P
      if @alu.flgSign.zero? then
        @regs.regPC.value = pop16()
      end 
    when 0b111    # 11 111 000    RET   M
      if @alu.flgSign.nonzero? then
        @regs.regPC.value = pop16()
      end 
    end
  end 
  
  # 11 命令クラス（11 xxx 001）
  # @param opr1 [Integer] オペランド１
  def inst11_pop(opr1)
    #puts "inst11_Pop(#{opr1})"
    case opr1
    when 0b000    # 11 000 001    POP   BC
      @regs.regBC.value = pop16()
    when 0b001    # 11 001 001    RET
      @regs.regPC.value = pop16()
    when 0b010    # 11 010 001    POP   DE
      @regs.regDE.value = pop16()
    when 0b011    # 11 011 001    EXX
      @alu.ex
      @regs.ex
    when 0b100    # 11 100 001    POP   HL
      @regs.regHL.value = pop16()
    when 0b101    # 11 101 001    JP    (HL)
      @regs.regPC.value = get_ref16(@regs.regHL)
    when 0b110    # 11 110 001    POP   AF
      @alu.regF.value = pop8()
      @alu.regA.value = pop8()
    when 0b111    # 11 111 001    LD    SP, HL
      @regs.regSP.value = @regs.regHL.value
    end 
  end 
  
  # 11 命令クラス（11 xxx 010）
  # @param opr1 [Integer] オペランド１
  def inst11_jp(opr1)
    #puts "inst11_jp(#{opr1})"
    @AD.lreg.value = fetch()
    @AD.hreg.value = fetch()
    
    case opr1
    when 0b000    # 11 000 010    JP    NZ
      if @alu.flgZero.zero? then
        @regs.regPC.value = @AD.value
      end
    when 0b001    # 11 001 010    JP    Z
      if @alu.flgZero.nonzero? then
        @regs.regPC.value = @AD.value
      end 
    when 0b010    # 11 010 010    JP    NC
      if @alu.flgCarry.zero? then
        @regs.regPC.value = @AD.value
      end 
    when 0b011    # 11 011 010    JP    C
      if @alu.flgCarry.nonzero? then
        @regs.regPC.value = @AD.value
      end 
    when 0b100    # 11 100 010    JP    PO
      if @alu.flgParity.zero? then
        @regs.regPC.value = @AD.value
      end 
    when 0b101    # 11 101 010    JP    PE
      if @alu.flgParity.nonzero? then
        @regs.regPC.value = @AD.value
      end 
    when 0b110    # 11 110 010    JP    P
      if @alu.flgSign.zero? then
        @regs.regPC.value = @AD.value
      end 
    when 0b111    # 11 111 010    JP    M
      if @alu.flgSign.nonzero? then
        @regs.regPC.value = @AD.value
      end 
    end
  end 
  
  # 11 命令クラス（11 xxx 011）
  # @param opr1 [Integer] オペランド１
  def inst11_ioex(opr1)
    #puts "inst11_ioex(#{opr1})"
    case opr1
    when 0b000    # 11 000 011    JP    nn
      @AD.lreg.value = fetch()
      @AD.hreg.value = fetch()
      @regs.regPC.value = @AD.value
    when 0b001    # 11 001 011    -> CB xx
      fetch()
      inst11_CBxx(inst_div, inst_opr1, inst_opr2)
    when 0b010    # 11 010 011    OUT   (p), A
      @AD.lreg.value = fetch()
      @port[@AD.lreg.value] = @alu.regA.value      
    when 0b011    # 11 011 011    IN    A, (p)
      @AD.lreg.value = fetch()
      @alu.regA.value = @port[@AD.lreg.value]
    when 0b100    # 11 100 011    EX    (SP), HL
      @AD.value = get_ref16(@regs.regSP)
      set_ref16(@regs.regSP, @regs.regHL.value)
      @regs.regHL.value = @AD.value
    when 0b101    # 11 101 011    EX    DE, HL
      @AD.value = @regs.regDE.value
      @regs.regDE.value = @regs.regHL.value
      @regs.regHL.value = @AD.value
    when 0b110    # 11 110 011    DI
      @isIntEnable = false
    when 0b111    # 11 111 011    EI
      @isIntEnable = true
    end
  end 
  
  # 11 命令クラス（11 xxx 100）
  # @param opr1 [Integer] オペランド１
  def inst11_call(opr1)
    #puts "inst11_call(#{opr1})"
    @AD.lreg.value = fetch()
    @AD.hreg.value = fetch()

    case opr1
    when 0b000    # 11 000 100    CALL    NZ, nn
      if @alu.flgZero.zero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end 
    when 0b001    # 11 001 100    CALL    Z, nn
      if @alu.flgZero.nonzero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end 
    when 0b010    # 11 010 100    CALL    NC, nn
      if @alu.flgCarry.zero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end 
    when 0b011    # 11 011 100    CALL    C, nn
      if @alu.flgCarry.nonzero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end       
    when 0b100    # 11 100 100    CALL    PO, nn
      if @alu.flgParity.zero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end 
    when 0b101    # 11 101 100    CALL    PE, nn
      if @alu.flgParity.nonzero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end 
    when 0b110    # 11 110 100    CALL    P, nn
      if @alu.flgSign.zero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end 
    when 0b111    # 11 111 100    CALL    M, nn
      if @alu.flgSign.nonzero? then
        push16(@regs.regPC.value)
        @regs.regPC.value = @AD.value
      end 
    end
  end 
  
  # 11 命令クラス（11 xxx 101）
  # @param opr1 [Integer] オペランド１
  def inst11_push(opr1)
    #puts "inst11_push(#{opr1})"
    case opr1
    when 0b000    # 11 000 101    PUSH    BC
      push16(@regs.regBC.value)
    when 0b001    # 11 001 101    CALL    nn
      @AD.lreg.value = fetch()
      @AD.hreg.value = fetch()
      push16(@regs.regPC.value)
      @regs.regPC.value = @AD.value
    when 0b010    # 11 010 101    PUSH    DE
      push16(@regs.regDE.value)
    when 0b011    # 11 011 101    -> DD xx
      fetch()
      case inst_div
      when INSTDIV_00
        inst11_DD00(inst_opr1, inst_opr2)
      when INSTDIV_01
        inst11_DD01(inst_opr1, inst_opr2)
      when INSTDIV_10
        inst11_DD10(inst_opr1, inst_opr2)
      when INSTDIV_11
        inst11_DD11(inst_opr1, inst_opr2)
      end
    when 0b100    # 11 100 101    PUSH    HL
      push16(@regs.regHL.value)
    when 0b101    # 11 101 101    -> ED xx
      fetch()
      case inst_div
      when INSTDIV_01
        inst11_ED01(inst_opr1, inst_opr2)
      when INSTDIV_10
        inst11_ED10(inst_opr1, inst_opr2)
      else
        raise VmCpuInstructionError
      end
      inst11_EDxx(inst_div, inst_opr1, isnt_opr2)
    when 0b110    # 11 110 101    PUSH    AF
      push8(@alu.regA.value)
      push8(@alu.regF.value)
    when 0b111    # 11 111 101    -> FD xx
      fetch()
      case inst_div
      when INSTDIV_00
        inst11_FD00(inst_opr1, inst_opr2)
      when INSTDIV_01
        inst11_FD01(inst_opr1, inst_opr2)
      when INSTDIV_10
        inst11_FD10(inst_opr1, inst_opr2)
      when INSTDIV_11
        inst11_FD11(inst_opr1, inst_opr2)
      end
    end
  end 
  
  # 11 命令クラス（11 xxx 110）
  # @param opr1 [Integer] オペランド１
  def inst11_alth8(opr1)
    #puts "inst11_alth8(#{opr1})"
    @alu.regTMP.value = fetch()

    case opr1
    when 0b000    # 11 000 110    ADD     A, n
      @alu.addA
    when 0b001    # 11 001 110    ADC     A, n
      @alu.adcA
    when 0b010    # 11 010 110    SUB     n
      @alu.subA
    when 0b011    # 11 011 110    SBC     A, n
      @alu.sbcA
    when 0b100    # 11 100 110    AND     n
      @alu.andA
    when 0b101    # 11 101 110    XOR     n
      @alu.xorA
    when 0b110    # 11 110 110    OR      n
      @alu.orA
    when 0b111    # 11 111 110    CP      n
      @alu.cpA
    end
  end 
  
  # ===========================================================================
  # 11 命令クラス（CB 11 xxx rrr）
  # @param div    [Integer]
  # @param opr1   [Integer] オペランド１
  # @param opr2   [Integer] オペランド２
  # @param pre_cd [Integer] 先行する命令コード
  def inst11_CBxx(div, opr1, opr2)
    #puts "inst11_CBxx(#{div}, #{opr1}, #{opr2}, #{@fetched[0]})"

    case @fetched[0]
    when 0xdd       # DD CB xx
      disp = fetch()
      @alu.regTMP.value = get_ref8ix(disp)
      reg8 = @alu.regTMP
    when 0xfd       # FD CB xx
      disp = fetch()
      @alu.regTMP.value = get_ref8iy(disp)
      reg8 = @alu.regTMP
    when 0xcb       # CB xx
      reg8 = get_reg8(opr2)
    else
      raise VmCpuInstructionError
    end

    case div
    when 0b00       # CB 00 xxx xxx
      case opr1
      when 0b000    # CB 00 000 rrr   RLC     r
        @alu.rlc(reg8)
      when 0b001    # CB 00 001 rrr   RRC     r
        @alu.rrc(reg8)
      when 0b010    # CB 00 010 rrr   RL      r
        @alu.rl(reg8)
      when 0b011    # CB 00 011 rrr   RR      r
        @alu.rr(reg8)
      when 0b100    # CB 00 100 rrr   SLA     r
        @alu.sla(reg8)
      when 0b101    # CB 00 101 rrr   SRA     r
        @alu.sra(reg8)
      when 0b110    # CB 00 110 rrr   SLL     r
        @alu.sll(reg8)
      when 0b111    # CB 00 111 rrr   SRL     r
        @alu.srl(reg8)
      end
    when 0b01       # CB 01 nnn rrr   BIT     n, r     
      @alu.bit(opr1, reg8)
    when 0b10       # CB 10 nnn rrr   RES     n, r
      @alu.res(opr1, reg8)
    when 0b11       # CB 11 nnn rrr   SET     n, r
      @alu.set(opr1, reg8)
    end

    case @fetched[0]
    when 0xdd
      set_ref8ix(disp, reg8.value)
    when 0xfd
      set_ref8iy(disp, reg8.value)
    end
  end 

end