require "../lib/combinedregister"
require "../cpu/rz80/register8"

# 16bitレジスタ クラス 
class Register16 < CombinedRegister
  
  # コンストラクタ
  def initialize()
    super(Register8, 2)
  end

  # 上位レジスタ
  # @return       [Register8]
  def hreg
    @regs[1]
  end 

  # 下位レジスタ
  # @return       [Register8]
  def lreg
    @regs[0]
  end 

  # レジスタ値の参照
  # @return [Word]  16bitレジスタ値
  def value
    return Word.new(super)
  end

  # レジスタ値を整数で返却
  # @return [Integer]
  def to_i
    self.value.to_i
  end
  
  # レジスタ値を符号なし整数で返却
  # @return [Integer]
  def to_ui
    self.value.to_ui
  end 
  
  # レジスタ値を指定した基数で返却
  # @return [String]
  def to_s(base = nil)
    base.nil? ? self.value.to_s : self.value.to_s(base)
  end 
end

# Test
if $0 == __FILE__ then
  reg = Register16.new
  reg.value = 0x1234
  puts "reg.value = #{reg.value.to_s(16)}"
  puts "reg.hbyte.value = #{reg.hbyte.value.to_s(16)}"
  puts "reg.lbyte.value = #{reg.lbyte.value.to_s(16)}"

  reg.hbyte.value = 0x56
  puts "reg.hbyte.value = #{reg.hbyte.value.to_s(16)}"
  puts "reg.value = #{reg.value.to_s(16)}"

  reg.lbyte.value = 0x78
  puts "reg.lbyte.value = #{reg.lbyte.value.to_s(16)}"
  puts "reg.value = #{reg.value.to_s(16)}"

  reg.value = 0x00ff
  puts "reg.value = #{reg.value.to_s(16)}"
  reg.inc
  puts "reg.value = #{reg.value.to_s(16)}"
  reg.dec
  puts "reg.value = #{reg.value.to_s(16)}"
end