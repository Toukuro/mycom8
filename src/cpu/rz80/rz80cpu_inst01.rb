# 01 xxx xxx 系命令処理モジュール
module Rz80CPUInst01

  # 01 命令クラスの処理（8bitロード命令）
  # @param opr1 [Integer] オペランド１（転送先レジスタ）
  # @param opr2 [Integer] オペランド２（転送元レジスタ）
  def inst01(opr1, opr2)
    if opr1 == Rz80CPU::REF8_HL then
      if opr2 == Rz80CPU::REF8_HL then  # 01 110 110  HALT
        @isHalt = true
      else                              # 01 110 rrr  LD  (HL), r
        set_ref8(@regs.regHL, opr_reg8(opr2).value)
      end
    elsif opr2 == Rz80CPU::REF8_HL then # 01 rrr 110  LD  r, (HL)
        opr_reg8(opr1).value = get_ref8(@regs.regHL)
    else                                # 01 rrr rrr' LD  r, r'
      opr_reg8(opr1).value = opr_reg8(opr2).value
    end
  end
end