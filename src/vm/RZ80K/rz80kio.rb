require "../io/ppi8255"

# Z80 I/O
class Rz80KIO < PPI8255

  KEYPA = PPI8255::PORT_A
  KEYPB = PPI8255::PORT_B
  KEYPC = PPI8255::PORT_C
  KEYCW = PPI8255::PORT_CTRL

	# コンストラクタ
  #def initizalize()
  #  super()
  #end

	# データの読出し
	# @param addr [Word]	デバイスアドレス
	# @return [Byte]	読み出した値
  def mem_read(addr)
    case addr
    when KEYPB
      # キーボードColumn入力 FFh=入力なし
      #   Row出力F8hのとき、20h=右Shift、01h=左Shift
      return 0xff if @port_data[KEYPA] == 0xf8
      return 0xfe
    when KEYPC
    else
      return super(addr)
    end
  end

	# データの書き込み
	# @param addr [Word]	デバイスアドレス
	# @param byte [Byte]	書き込む値
  def mem_write(addr, byte)
    case addr
    when KEYPA
      # キーボードRow出力
    when KEYPC
    when KEYCW
    else
      super(addr, byte)
    end
  end
end