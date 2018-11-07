require "../lib/binary"
require "../lib/devicebase"
require "../lib/ioaccess"

# 仮想I/O 基底クラス
class IOPortBase < DeviceBase
	
  # IOAccessをMix-in
  include IOAccess

	# 読出し
  # @param addr [Binary]  メモリアドレス
  # @return     [Binary]  読出しデータ
  def [](addr)
		dev = get_iodevice(addr)
    dev.read(addr) unless dev.nil?
  end

  # 書込み
  # @param  addr [Binary]  メモリアドレス
  # @param  data [Binary]  書込みデータ
  def []=(addr, data)
		dev = get_iodevice(addr)
    dev.write(addr, data) unless dev.nil?
  end

end