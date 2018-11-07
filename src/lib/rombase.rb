require "../lib/binary"
require "../lib/devicebase"

# ROMデバイス基本クラス
class ROMBase < DeviceBase

  # コンストラクタ
  # @param addr_type  [Class] アドレスの型（Binaryの派生クラス）
  # @param data_type  [Class] データの型（Binaryの派生クラス）
  def initialize(addr_type = Word, data_type = Byte)
    super(addr_type, data_type)
    @rom_arry = []
  end

  # ROMの書き込み
  # @param fname      [String]  ROMに書き込むデータファイル名
  def write_byfile(fname)
    unless fname.nil? then
      addr = @addr_type.new
      
      size = 0
      File.open(fname, "rb") {|f|
        until f.eof?
          @rom_arry[addr.to_ui] = @data_type.new(f.readbyte)
          # puts "ROMBase#write_byfile: addr = #{addr.inspect}"
          break if addr == @addr_type.max_value
          addr += 1
          size += 1
        end
      }
    end
    return size   # ROMに書き込んだサイズ
  end

  # メモリ読出し
  # @param addr [Binary]  メモリアドレス
  # @return     [Binary]  読出しデータ
  def read(addr)
    addr = @addr_type.new(addr)
    @rom_arry[addr.to_ui] || @data_type.new(0)
  end

  # メモリ書込み
  # @param  addr [Binary]  メモリアドレス
  # @param  byte [Binary]  書込みデータ
  def write(addr, byte)
    # ROMなので書き込めない
  end
end