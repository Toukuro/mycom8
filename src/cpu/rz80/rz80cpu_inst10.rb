# 10 xxx xxx 系命令処理モジュール
module Rz80CPUInst10

  # 10 命令クラスの処理（8bit演算命令）
  # @param opr1 [Integer] オペランド１（演算種別）
  # @param opr2 [Integer] オペランド２（対象レジスタ）
  def inst10(opr1, opr2)
    # 対象レジスタの値をALUのTMPレジスタに設定
    if opr2 == Rz80CPU::REF8_HL then
      @alu.regTMP.value = get_ref8(@regs.regHL) # r = (HL)
    else
      @alu.regTMP.value = opr_reg8(opr2).value  # r = A,B,C,D,E,H,L
    end

    # 演算処理
    case opr1
    when OPR8_ADD   # 10 000 rrr    ADD   A, r
      @alu.addA
    when OPR8_ADC   # 10 001 rrr    ADC   A, r
      @alu.adcA
    when OPR8_SUB   # 10 010 rrr    SUB   A, r
      @alu.subA
    when OPR8_SBC   # 10 011 rrr    SBC   A, r
      @alu.sbcA
    when OPR8_AND   # 10 100 rrr    AND   r
      @alu.andA
    when OPR8_XOR   # 10 101 rrr    XOR   r
      @alu.xorA
    when OPR8_OR    # 10 110 rrr    OR    r
      @alu.orA
    when OPR8_CP    # 10 111 rrr    CP    r
      @alu.cpA
    end
  end

end