require "../lib/binary"
require "../memory/memory"

# ページ管理メモリクラス
class PagedMemory

  # コンストラクタ
  # @param addr_bits [Fixnum] (16)  アドレスビット幅
  # @param page_bits [Fixnum] (2)   ページビット幅（アドレスビット幅の上位より）
  # @param page_conf [Array]        ページ定義。下記@note参照
  #
  # @note ページ定義について
  #   配列にて、0ページ目から順に何を割り当てるか、メモリクラス名を
  #   指定する。
  #   BankedMemory（および他のビット幅以外の引数が必要なもの）については
  #   配列の要素をHashとし、キーにクラス名、バリューに引数の配列を指定する。
  #   アドレスビット幅は本クラスで算出した値を指定するので、引数配列には指定しない。
  #
  #   例１）4ページをデフォルトの引数で構成する場合。
  #     [Memory, BankedMemory, BankedMemory, Memory]
  #   例２）2ページ目を２バンク、3ページ目を4バンクとする場合。
  #     [Memory, {BankedMemory => [2]}, {BankedMemory => [4]}, Memory]
  #
  def initialize(addr_bits = 16, page_bits = 2, page_conf = [])
    super(addr_bits)

    @page_num  = 2 ** page_bits                     # 構成ページ数
    @page_addr_bits = addr_bits - page_bits         # １ページ当たりのアドレスビット数
    @page_mask = (@page_num - 1) << @page_addr_bits # ページビットマスク

    @page_num.times {|page_no|
      conf = page_conf[page_no]

      if conf.nil then
        page_mem = Memory.new(@page_addr_bits)
      elsif conf.instance_of?(Hash) then
        conf.each {|klass, args|
          page_mem = klass.new(@page_addr_bits, *args)
        }
      else
        page_mem = conf.new(@page_addr_bits)
      end

      @data_arry << page_mem
    }
  end

  # @attr_reader  :page_num [Fixnum]  構成ページ数
  attr_reader :page_num

  # ページの取得
  def page(page_no)
    if page_no >= 0 && page_no < @page_num then
      return @data_arry[page_no]
    else
      return nil
    end
  end

  # メモリ読出し
  # @param addr [Fixnum]  メモリアドレス
  # @return     [Byte]    読出しデータ(byte)
  def mem_read(addr)
    pgno, pgaddr = addr_decode(addr)
    @data_arry[pgno][pgaddr]
  end
  protected :mem_read

  # メモリ書込み
  # @param addr [Fixnum]  メモリアドレス
  # @param byte [Byte]    書込みデータ(byte)
  def mem_write(addr, byte)
    pgno, pgaddr = addr_decode(addr)
    @data_arry[pgno][pgaddr] = byte
  end
  protected :mem_write

  # メモリアドレスをページ番号と相対アドレスに変換
  # @param addr [Fixnum] 16bitアドレス
  # @return [Fixnum]  ページ番号
  # @return [Fixnum]  相対アドレス
  def addr_decode(addr)
    page_addr = addr & !@page_mask
    page_no   = addr >> @page_addr_bits

    return page_no, page_addr
  end
  private :addr_decode
end

# Test
if $0 == __FILE__ then
end