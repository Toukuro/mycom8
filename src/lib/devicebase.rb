require "../lib/binary"
require "../lib/vmerror"
#
# 仮想デバイス 基底クラス
#
class DeviceBase

  # コンストラクタ
  # @param addr_type  [Class]   I/Oのアドレス幅を表す型
  # @param data_type  [Class]   I/Oのデータ幅を表す型
  def initialize(addr_type = Word, data_type = Byte)
    @addr_type = addr_type
    @data_type = data_type
  end 
  
  # @attr_reader :io_bits [Fixnum]  I/Oで使用するメモリビット幅
  def addr_bits
    @addr_type.bit_width
  end  
  
  # I/Oからのメモリ読出し
  # @param addr [Binary]  I/Oメモリアドレス
  # @return     [Binary]  読出しデータ
  def read(addr)
  end

  # I/Oへのメモリ書込み
  # @param addr [Binary]  I/Oメモリアドレス
  # @param byte [Binary]  書込みデータ
  def write(addr, byte)
  end
end