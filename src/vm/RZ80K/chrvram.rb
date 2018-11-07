require "../lib/devicebase"
require "../lib/escseq"

# キャラクタVRAMクラス
class CharacterVRAM < DeviceBase

  #### 定数定義
  # 画面サイズ
  DISP_WIDTH  = 40
  DISP_HEIGHT = 25

  # コンストラクタ
  def initialize(vdev_client = nil)
    super(Bit10, Byte)   # 10bit = 1KByte
    @vram_size = DISP_WIDTH * DISP_HEIGHT
    @vram = Array.new(Bit10.max_value)
    @vdev = vdev_client

  end

  # VRAMからの読出し
  # @param addr [Word]  VRAMアドレス（0x0000～）
  # @return [Byte]  MZディスプレイコード
  def read(addr)
    addr = @addr_type.new(addr.to_i)
    @vram[addr.to_ui] || 0
  end

  # VRAMへの書込み
  # @param addr [Word]  VRAMアドレス（0x0000～）
  # @param byte [Byte]  MZディスプレイコード
  def write(addr, byte)
    addr = @addr_type.new(addr.to_i)
    @vram[addr.to_ui] = @data_type.new(byte.to_i)
    @vdev.send_data(sprintf("%04X %02X", addr.to_i, byte.to_i))
  end

  # 現在のVRAMの内容を再表示する
  def refresh
    DISP_HEIGHT.times {|y|
      str  = getline(y)
      putstring(0, y, str)
    }
  end

  # 1行スクロールアップする  
  def scroll_up
    bottomfirst_addr = xyencode(0, DISP_HEIGHT - 1)
    0.upto(@vram_size - 1) {|addr|
      disp = (addr >= bottomfirst_addr) ? 0 : mem_read(addr + DISP_WIDTH)
      mem_write(addr, disp)
    }
    refresh
  end

  # 1行スクロールダウンする
  def scroll_down
    toplast_addr = xyencode(DISP_WIDTH - 1, 0)
    (@vram_size - 1).downto(0) {|addr|
      disp = (addr <= toplast_addr) ? 0 : mem_read(addr - DISP_WIDTH)
      mem_write(addr, disp)
    }
    refresh
  end

  # 指定位置への文字列出力
  def putstring(x, y, str)
    row = y + 1
    col = x * 2 + 1
    #EscSeq.move_pos(row, col, str)
    # @vdev.send_data("LOCATE #{row} #{col} #{str}")
  end


  # 指定行の表示可能な文字列を取得する
  def getline(y)
    addr = xyencode(0, y)
    str  = ''
    DISP_WIDTH.times {|x|
      str << disp2chr(mem_read(addr + x))
    }
    return str
  end
end