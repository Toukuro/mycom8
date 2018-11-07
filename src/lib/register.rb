require "../lib/binary"

# レジスタ基本クラス
class Register

  # コンストラクタ
  # @param  init_val  [Integer] 初期値。Integerのほか、to_iが使えるオブジェクト
  # @param  data_type [Class] データの型（Binaryの派生クラス）
  def initialize(init_val = 0, data_type = Byte)
    @data_type = data_type
    @value = @data_type.new(init_val)
  end
  
  # レジスタの値を返却
  # @return [Binary]
  attr_reader :value

  # レジスタ値の設定
  # @param val [Register|Binary|Integer]
  def value=(val)
    @value = @data_type.new(val.to_i)
  end
  
  # レジスタ値を整数で返却
  # @return     [Integer]
  def to_i
    @value.to_i
  end 
  
  # レジスタ値を符号なし整数で返却
  # @return     [Integer]
  def to_ui
    @value.to_ui
  end 
end

#
# Test
#
if $0 == __FILE__ then
  r1 = Register.new(0x12)
  puts "r1.value = 0x#{r1.value.to_s(16)}"
  r1.value = 0x123
  puts "r1.value = 0x#{r1.value.to_s(16)}"
  r1.inc
  puts "r1.value = 0x#{r1.value.to_s(16)}"

  var = r1 + 0x11
  puts "var = 0x#{var.to_s(16)}"

  var = r1 + 0xff
  puts "var = 0x#{var.to_s(16)}"

  r2 = Register.new(0xff)
  var = r1 + r2
  puts "var = 0x#{var.to_s(16)}"
end