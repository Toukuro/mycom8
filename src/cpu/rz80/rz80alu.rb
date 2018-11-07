require "../cpu/rz80/rz80register"

class Rz80ALU
  ####  定数定義
  # フラグレジスタのビット定義
  #             SZ-H-PNC
  FLAG_SIGN = 0b10000000
  FLAG_ZERO = 0b01000000
  FLAG_HFCR = 0b00010000
  FLAG_PAOV = 0b00000100
  FLAG_NEGA = 0b00000010
  FLAG_CARY = 0b00000001

  # コンストラクタ  
  def initialize
    @accum = [Register8.new, Register8.new]
    @flag  = [Register8.new, Register8.new]
    @temp  = [Register8.new, Register8.new]
    
    @channel = 0
  end

  # @attr_reader channel [FixedNum] 現在のチャネル番号
  attr_reader(:channel)
  
  # ---------------------------------------------------------------------------
  # レジスタ参照
    
  # レジスタ交換
  def ex
    @channel = 1 - @channel
  end
  
  ## レジスタ参照
  # Aレジスタ（アキュムレータ）
  # return [Register8] Aレジスタオブジェクト
  def regA
    @accum[@channel]
  end

  # Fレジスタ（フラグ）
  # return [Register8] Fレジスタオブジェクト
  def regF 
    @flag[@channel]
  end

  # TMPレジスタ（オペランド用一時レジスタ）
  # return [Register8] TMPレジスタオブジェクト
  def regTMP
    @temp[@channel]
  end
  
  # ---------------------------------------------------------------------------
  # 8bit演算処理
  
  # 加算
  # @return       [Byte]  演算結果
  def addA
    full = regA.to_ui + regTMP.to_ui
    harf = regA.lnib + regTMP.lnib
    
    self.flgCarry  = full & 0x100
    self.flgHCarry = harf & 0x10
    
    new_value = Byte.new(full)
    self.flgSign   = new_value.sign
    self.flgZero   = new_value.zero? ? 1 : 0
    self.flgParity = 1 - new_value.parity
    self.flgNegate = 0
    
    regA.value = new_value
  end
  
  # キャリー加算
  # @return       [Byte]  演算結果
  def adcA
    full = regA.to_ui + regTMP.to_ui + flgCarry
    harf = regA.lnib + regTMP.lnib + flgCarry
    
    self.flgCarry  = full & 0x100
    self.flgHCarry = harf & 0x10

    new_value = Byte.new(full)
    self.flgSign   = new_value.sign
    self.flgZero   = new_value.zero? ? 1 : 0
    self.flgParity = 1 - new_value.parity
    self.flgNegate = 0
    
    regA.value = new_value
  end
  
  # 減算
  # @return       [Byte]  演算結果
  def subA
    full = regA.to_ui - regTMP.to_ui
    harf = regA.lnib - regTMP.lnib
    
    self.flgCarry  = full & 0x100
    self.flgHCarry = harf & 0x10
    
    new_value = Byte.new(full)
    self.flgSign   = new_value.sign
    self.flgZero   = new_value.zero? ? 1 : 0
    self.flgParity = 1 - new_value.parity
    self.flgNegate = 1
    
    return regA.value
  end
  
  # キャリー減算
  # @return       [Byte]  演算結果
  def sbcA
    full = regA.to_ui - regTMP.to_ui + flgCarry
    harf = regA.lnib - regTMP.lnib - flgCarry
    
    self.flgCarry  = full & 0x100
    self.flgHCarry = harf & 0x10

    new_value = Byte.new(full)
    self.flgSign   = new_value.sign
    self.flgZero   = new_value.zero? ? 1 : 0
    self.flgParity = 1 - new_value.parity
    self.flgNegate = 1
    
    return regA.value
  end
    
  # 論理AND
  # @return       [Byte]  演算結果
  def andA
    regA.value &= regTMP.value
    
    self.flgSign   = regA.value.sign
    self.flgZero   = regA.value.zero? ? 1 : 0
    self.flgParity = 1 - regA.value.parity
    self.flgCarry  = 0
    self.flgHCarry = 1
    self.flgNegate = 0
    
    return regA.value
  end

  # 論理XOR
  # @return       [Byte]  演算結果
  def xorA
    regA.value ^= regTMP.value
    
    self.flgSign   = regA.value.sign
    self.flgZero   = regA.value.zero? ? 1 : 0
    self.flgParity = 1 - regA.value.parity
    self.flgCarry  = 0
    self.flgHCarry = 1
    self.flgNegate = 0
    
    return regA.value
  end

  # 論理OR
  # @return       [Byte]  演算結果
  def orA
    regA.value |= regTMP.value
    
    self.flgSign   = regA.value.sign
    self.flgZero   = regA.value.zero? ? 1 : 0
    self.flgParity = 1 - regA.value.parity
    self.flgCarry  = 0
    self.flgHCarry = 1
    self.flgNegate = 0
    
    return regA.value
  end

  # 比較
  # @return       [Byte]  演算結果
  def cpA
    full = regA.to_ui - regTMP.to_ui
    harf = regA.lnib - regTMP.lnib
    
    self.flgCarry   = full & 0x100
    self.flgHCarry  = harf & 0x10
    
    regA.value = Byte.new(full)
    self.flgSign    = regA.value.sign
    self.flgZero    = regA.value.zero? ? 1 : 0
    self.flgParity  = 1 - regA.value.parity
    self.flgNegate  = 1
    
    return regA.value
  end
  
  # インクリメント Aレジスタ
  # @return       [Byte]  演算結果
  def incA
    inc(regA)
  end 
  
  # デクリメント Aレジスタ
  # @return       [Byte]  演算結果
  def decA
    dec(regA)
  end 
  
  # インクリメント（汎用）
  # @param  reg   [Register8]
  # @return       [Byte]  演算結果
  def inc(reg)
    reg.value += 1
    self.flgSign    = reg.value.sign
    self.flgZero    = reg.value.zero? ? 1 : 0
    self.flgParity  = (reg.value == 0x80) ? 1 : 0
    self.flgHCarry  = (reg.value & 0x1f) == 0x10 ? 1 : 0
    self.flgNegate  = 0
    
    return reg.value
  end 
  
  # デクリメント（汎用）
  # @param  reg   [Register8]
  # @return       [Byte]  演算結果
  def dec(reg)
    reg.value -= 1
    self.flgSign    = reg.value.sign
    self.flgZero    = reg.value.zero? ? 1 : 0
    self.flgParity  = (reg.value == 0x7f) ? 1 : 0
    self.flgHCarry  = (reg.value & 0x1f) == 0x10 ? 1 : 0
    self.flgNegate  = 1
    
    return reg.value
  end 
  
  # 左ローテート（キャリー含む：Aレジスタ）
  #   [C] ← regA[7 ← 0] ← [C]
  # @return       [Byte]      演算結果
  def rlA
    regTMP.value = regA.value
    regA.value   = regA.value << 1 | flgCarry
    
    self.flgCarry  = regTMP.value.bit?(7)
    self.flgNegate = 0
    self.flgHCarry = 0
    
    return regA.value
  end 

  # 左ローテート（レジスタ内：Aレジスタ）
  #   [C] ← regA[7 ← 0] ← regA[7]
  # @return       [Byte]      演算結果
  def rlcA
    regTMP.value = regA.value
    regA.value   = regA.value << 1 | regTMP.value.bit?(7)
    
    self.flgCarry  = regTMP.value.bit?(7)
    self.flgNegate = 0
    self.flgHCarry = 0
    
    return regA.value
  end 

  # 右ローテート（キャリー含む：Aレジスタ）
  #   [C] → regA[7 → 0] → [C]
  # @return       [Byte]      演算結果
  def rrA
    regTMP.value = regA.value
    regA.value   = regA.value >> 1 | (self.flgCarry << 7)
    
    self.flgCarry  = regTMP.value.bit?(0)
    self.flgNegate = 0
    self.flgHCarry = 0
    
    return regA.value    
  end 

  # 右ローテート（レジスタ内：Aレジスタ）
  #   regA[0] → regA[7 → 0] → [C]
  # @return       [Byte]      演算結果
  def rrcA
    regTMP.value = regA.value
    regA.value   = regA.value >> 1 | (regTMP.value.bit?(0) << 7)
    
    self.flgCarry  = regTMP.value.bit?(0)
    self.flgNegate = 0
    self.flgHCarry = 0
    
    return reg.value    
  end 

  # 左ローテート（キャリー含む：汎用）
  #   [C] ← reg8[7 ← 0] ← [C]
  # @param  reg   [Register8] 対象レジスタ
  # @return       [Byte]      演算結果
  def rl(reg)
    regTMP.value = reg.value
    reg.value    = reg.value << 1 | flgCarry
    
    self.flgCarry  = regTMP.value.bit?(7)
    self.flgNegate = 0
    self.flgParity = 1 - reg.value.parity
    self.flgHCarry = 0
    self.flgZero   = reg.value.zero? ? 1 : 0
    self.flgSign   = reg.value.sign
    
    return reg.value
  end

  # 右ローテート（キャリー含む：汎用）
  #   [C] → reg8[7 → 0] → [C]
  # @param  reg   [Register8]  対象レジスタ
  # @return       [Byte]      演算結果
  def rr(reg)
    regTMP.value = reg.value
    reg.value    = reg.value >> 1 | (self.flgCarry << 7)
    
    self.flgCarry  = regTMP.value.bit?(0)
    self.flgNegate = 0
    self.flgParity = 1 - reg.value.parity
    self.flgHCarry = 0
    self.flgZero   = reg.value.zero? ? 1 : 0
    self.flgSign   = reg.value.sign
    
    return reg.value    
  end
  
  # 左ローテート（レジスタ内：汎用）
  #   [C] ← reg8[7 ← 0] ← reg8[7]
  # @param  reg   [Register8] 対象レジスタ
  # @return       [Byte]      演算結果
  def rlc(reg)
    regTMP.value = reg.value
    reg.value    = reg.value << 1 | regTMP.value.bit?(7)
    
    self.flgCarry  = regTMP.value.bit?(7)
    self.flgNegate = 0
    self.flgParity = 1 - reg.value.parity
    self.flgHCarry = 0
    self.flgZero   = reg.value.zero? ? 1 : 0
    self.flgSign   = reg.value.sign
    
    return reg.value
  end

  # 右ローテート（レジスタ内：汎用）
  #   reg8[0] → reg8[7 → 0] → [C]
  # @param  reg   [Register8]  対象レジスタ
  # @return       [Byte]      演算結果
  def rrc(reg)
    regTMP.value = reg.value
    reg.value    = reg.value >> 1 | (regTMP.value.bit?(0) << 7)
    
    self.flgCarry  = regTMP.value.bit?(0)
    self.flgNegate = 0
    self.flgParity = 1 - reg.value.parity
    self.flgHCarry = 0
    self.flgZero   = reg.value.zero? ? 1 : 0
    self.flgSign   = reg.value.sign
    
    return reg.value    
  end

  # 左算術シフト
  #   [C] ← reg8[7 ← 0] ← 0
  def sla(reg)
    regTMP.value = reg.value
    reg.value = reg.value << 1
    
    self.flgCarry  = regTMP.value.bit?(7)
    self.flgNegate = 0
    self.flgParity = 1 - reg.value.parity
    self.flgHCarry = 0
    self.flgZero   = reg.value.zero? ? 1 : 0
    self.flgSign   = reg.value.sign
    
    return reg.value    
  end 
  
  # 右算術シフト
  #   reg8[7] → reg8[7 → 0] → [C]
  def sra(reg)
    regTMP.value = reg.value
    reg.value = reg.value >> 1 | (regTMP.value.bit?(7) << 7)
    
    self.flgCarry  = regTMP.value.bit?(0)
    self.flgNegate = 0
    self.flgParity = 1 - reg.value.parity
    self.flgHCarry = 0
    self.flgZero   = reg.value.zero? ? 1 : 0
    self.flgSign   = reg.value.sign
    
    return reg.value    
  end 
  
  # 左論理シフト
  #   [C] ← reg8[7 ← 0] ← 0
  def sll(reg)
    sla(reg)
  end 
  
  # 右論理シフト
  #   0 → reg8[7 → 0] → [C]
  def srl(reg)
    regTMP.value = reg.value
    reg.value = reg.value >> 1
    
    self.flgCarry  = regTMP.value.bit?(0)
    self.flgNegate = 0
    self.flgParity = 1 - reg.value.parity
    self.flgHCarry = 0
    self.flgZero   = reg.value.zero? ? 1 : 0
    self.flgSign   = reg.value.sign
    
    return reg.value    
  end 
  
  # BCD演算補正
  def daA
  end 

  # １の補数
  def cpl
    regA.value = regA.value ^ 0xff
  end 

  # ---------------------------------------------------------------------------
  # フラグ操作
  
  # キャリーフラグの変更
  def ccf
    self.flgCarry = 0 - self.flgCarry
  end 

  # キャリーフラグの設定
  def scf
    self.flgCarry = 1
  end 

  # ビット調査
  def bit(n, reg)
    self.flgNegate = 0
    self.flgHCarry = 1
    self.flgZero   = 1 - reg.value.bit?(n)
  end 
  
  # ビットリセット
  def res(n, reg)
    reg.value &= ~(0x01 << n)
  end 
  
  # ビットセット
  def set(n, reg)
    reg.value |= 0x01 << n
  end
  
  ## フラグレジスタ操作
  # サインフラグ(S)の参照と設定
  # @param  val   [Byte]    0 または 0以外
  # @return       [Integer] 0 or 1
  def flgSign
    get_fbit(FLAG_SIGN)
  end
  def flgSign=(val)
    set_fbit(FLAG_SIGN, val)
  end

  # ゼロフラグ(Z)の参照と設定  
  # @param  val   [Byte]    0 または 0以外
  # @return       [Integer] 0 or 1
  def flgZero
    get_fbit(FLAG_ZERO)
  end
  def flgZero=(val)
    set_fbit(FLAG_ZERO, val)
  end

  # ハーフキャリーフラグ(H)の参照と設定  
  # @param  val   [Byte]    0 または 0以外
  # @return       [Integer] 0 or 1
  def flgHCarry
    get_fbit(FLAG_HFCR)
  end
  def flgHCarry=(val)
    set_fbit(FLAG_HFCR, val)
  end

  # パリティフラグ(P/V)の参照と設定  
  # @param  val   [Byte]    0 または 0以外
  # @return       [Integer] 0 or 1
  def flgParity
    get_fbit(FLAG_PAOV)
  end
  def flgParity=(val)
    set_fbit(FLAG_PAOV, val)
  end
  
  # マイナスフラグ(N)の参照と設定
  # @param  val   [Byte]    0 または 0以外
  # @return       [Integer] 0 or 1
  def flgNegate
    get_fbit(FLAG_NEGA)
  end  
  def flgNegate=(val)
    set_fbit(FLAG_NEGA, val)
  end
  
  # キャリーフラグ(C)の参照と設定
  # @param  val   [Byte]    0 または 0以外
  # @return       [Integer] 0 or 1
  def flgCarry
    get_fbit(FLAG_CARY)
  end
  def flgCarry=(val)
    #puts "flgCarry(#{val.to_s(16)})"
    set_fbit(FLAG_CARY, val)
  end
  
  # ---------------------------------------------------------------------------
  # レジスタのダンプ出力
  def dump(comment = nil)
    printf("%s\n", comment) unless comment.nil?
    printf("________________SZ-H-PNC\n")
    printf("A  : %02X    F  : %08b\n",
      @accum[@channel].value, @flag[@channel].value)
    printf("A' : %02X    F' : %08b\n",
      @accum[1 - @channel].value, @flag[1 - @channel].value)
  end

  ##  プライベートメソッド
  private

  # マスクで指定したビットの値を取得
  # @param  mask  [Integer] フラグビットマスク
  # @return       [Integer] 1:セット、0:リセット
  def get_fbit(mask)
    (regF.value & mask).zero? ? 0 : 1
  end
  
  # マスクで指定したビットの値を設定
  # @param  mask  [Integer] フラグビットマスク
  # @param  val   [Byte]    0 または 0以外
  # @return       [Integer] 0 or 1
  def set_fbit(mask, val)
    #printf("set_fbit(%08b, %x)\n", mask, val)
    if val.zero? then
      regF.value &= ~mask
      return 0
    else
      regF.value |= mask
      return 1
    end
  end
end

# Test
if $0 == __FILE__ then
  alu = RZ80ALU.new
  alu.dump
  
  alu.regA.value = 0x12
  alu.regTMP.value = 0x34
  alu.dump

  alu.addA
  alu.dump

  alu.regTMP.value = 0xC0
  alu.addA
  alu.dump

  alu.regTMP.value = 0
  alu.adcA
  alu.dump

  alu.ex
  alu.dump
end