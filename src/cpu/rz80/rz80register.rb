require "../cpu/rz80/register16"

# RZ80汎用レジスタクラス
class Rz80Register

  # コンストラクタ
  def initialize
    @WZ = [Register16.new, Register16.new]  # WZ register
    @BC = [Register16.new, Register16.new]  # BC register
    @DE = [Register16.new, Register16.new]  # DE register
    @HL = [Register16.new, Register16.new]  # HL register

    @IX = Register16.new  # X Index register
    @IY = Register16.new  # Y Index register 
    @SP = Register16.new  # Stack Pointer
    @PC = Register16.new  # Program Counter

    @I  = Register.new    # Instruction register
    @R  = Register.new    # Refresh register

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

  ## 16bitアクセス
  def regWZ
    @WZ[@channel]
  end
  
  # BCレジスタの参照
  # @return [Register16]  
  def regBC
    @BC[@channel]
  end

  # DEレジスタの参照
  # @return [Register16]  
  def regDE
    @DE[@channel]
  end

  # HLレジスタの参照
  # @return [Register16]  
  def regHL
    @HL[@channel]
  end

  # IXレジスタの参照
  def regIX
    @IX
  end

  # IYレジスタの参照
  def regIY
    @IY
  end

  # SPレジスタの参照
  def regSP
    @SP
  end

  # PCレジスタの参照
  def regPC
    @PC
  end
  
  # 8bitアクセス
  def regW
    @WZ[@channel].hreg
  end 
  
  def regZ
    @WZ[@channel].lreg
  end
  
  # Bレジスタの参照
  # @return [Register]  Bレジスタ
  def regB
    @BC[@channel].hreg
  end

  # Cレジスタの参照
  # @return [Register]  Cレジスタ
  def regC
    @BC[@channel].lreg
  end

  # Dレジスタの参照
  # @return [Register]  Dレジスタ
  def regD
    @DE[@channel].hreg
  end

  # Eレジスタの参照
  # @return [Register]  Eレジスタ
  def regE
    @DE[@channel].lreg
  end

  # Hレジスタの参照
  # @return [Register]  Hレジスタ
  def regH
    @HL[@channel].hreg
  end
  
  # Lレジスタの参照
  # @return [Register]  Lレジスタ
  def regL
    @HL[@channel].lreg
  end

  def regIXH
    @IX.hreg
  end 

  def regIXL
    @IX.lreg
  end 

  def regIYH
    @IY.hreg
  end

  def regIYL
    @IY.lreg
  end 

  # I(割り込み)レジスタの参照
  # @return [Register]  割り込みレジスタ
  def regI
    @I
  end

  # R(リフレッシュカウンタ)レジスタの参照
  # @return [Register]  リフレッシュカウンタ
  def regR
    @R
  end

  # ---------------------------------------------------------------------------
  # 16bitレジスタ演算
  
  def add(reg16, val)
    reg16.value = reg16.value + val if Register16 === reg16
  end 

  def sub(reg16, val)
    reg16.value = reg16.value - val if Register16 === reg16
  end 

  def inc(reg16)
    self.add(reg16, 1)
  end

  def dec(reg16)
    self.sub(reg16, 1)
  end 

  # ---------------------------------------------------------------------------
  # 汎用レジスタのダンプ出力
  def dump
    printf("BC : %04X  BC': %04X\n", 
      @BC[@channel].to_ui, @BC[1 - @channel].to_ui)
    printf("DE : %04X  DE': %04X\n", 
      @DE[@channel].to_ui, @DE[1 - @channel].to_ui)
    printf("HL : %04X  HL': %04X\n", 
      @HL[@channel].to_ui, @HL[1 - @channel].to_ui)
    printf("IX : %04X  SP : %04X\n", @IX.to_ui, @SP.to_ui)
    printf("IY : %04X  PC : %04X\n", @IY.to_ui, @PC.to_ui)
    puts
  end
end

# Test
if $0 == __FILE__ then
  regs = RZ80Register.new
  
  # set
  regs.BC.value = 0x1122
  regs.DE.value = 0x3344
  regs.HL.value = 0x5566
  regs.IX.value = 0xD000
  regs.IY.value = 0xE000
  regs.SP.value = 0x8000
  regs.PC.value = 0x1000
  regs.dump

  regs.ex
  regs.C.value = 0x12
  regs.E.value = 0x34
  regs.L.value = 0x56
  regs.dump

  regs.ex
  regs.dump
end