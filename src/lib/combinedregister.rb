require "../lib/binary"
require "../lib/register"

# 複合レジスタ基本クラス
class CombinedRegister

  def initialize(reg_type = Register, count)
    @reg_type = reg_type
    @regs = []
    count.times {@regs << @reg_type.new(0)}
  end 

  # @return       [Register]
  def [](nth)
    @regs[nth]
  end 

  # @return       [Integer]
  def value
    val = 0
    (@regs.length - 1).downto(0) {|n|
      val <<= @regs[n].value.class.bit_width
      val += @regs[n].to_ui
    }
    return val
  end 

  # @param  val   [Integer]
  # @return       [Integer]
  def value=(val)
    val2 = val.to_ui
    @regs.length.times {|n|
      @regs[n].value = val2
      val2 >>= @regs[n].value.class.bit_width
    }
    return val
  end 

end 