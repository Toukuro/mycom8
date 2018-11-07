require "../lib/binary"
require "../lib/devicebase"

# 仮想メモリ空間 基底クラス
class MemoryBase < DeviceBase

	# コンストラクタ
  # @param addr_type  [Class] アドレスの型（Binaryの派生クラス）
  # @param data_type  [Class] データの型（Binaryの派生クラス）
  def initialize(addr_type = Word, data_type = Byte)
    super(addr_type, data_type)
		@data_arry = []					# データ、ページ、バンク等の格納領域
	end 

  # メモリ読出し
  # @param addr [Binary]  メモリアドレス
  # @return     [Binary]  読出しデータ
  def [](addr)
		dev = self
		klass = self.class
    if klass.method_defined?(:get_iodevice) then
      bank_no = (klass.method_defined?(:bank_no)) ? self.bank_no : 0
      dev = get_iodevice(addr, bank_no) || dev
    end
    dev.read(addr)
  end

  # メモリ書込み
  # @param  addr [Binary]  メモリアドレス
  # @param  byte [Binary]  書込みデータ
  def []=(addr, byte)
    dev = self
		klass = self.class
    if klass.method_defined?(:get_iodevice) then
      bank_no = (klass.method_defined?(:bank_no)) ? self.bank_no : 0
      dev = get_iodevice(addr, bank_no) || dev
    end
    dev.write(addr, byte)
  end

  # メモリ読出し
  # @param addr [Binary]  メモリアドレス
  # @return     [Binary]	読出しデータ
  def read(addr)
    @data_arry[addr.to_ui] || @data_type.new(0)
  end

  # メモリ書込み
  # @param addr [Binary]  メモリアドレス
  # @param byte [Binary]	書込みデータ
  def write(addr, byte)
    # puts "memorybase#write(#{addr.to_s(16)}, #{byte.to_s(16)})"
    @data_arry[addr.to_ui] = @data_type.new(byte.to_i)
  end

end