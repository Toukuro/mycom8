# ページ毎にバンク切り替え可能な16bitアドレスメモリ
require "./memory"

# バンク対応16bitアドレスメモリクラス
class Ram16 < Memory
  
  # コンストラクタ
  # @option page_num [Fixnum] (4) 分割ページ数
  # @option bank_num [Fixnum] (1) バンク数
  def initialize(page_num = 4, bank_num = 1)
    super(16)
    @memarry   = nil
    @page_num  = 2 ** Math.log2(page_num).to_i
    @page_size = @addr_size / page_num
    @bank_num  = bank_num
    clear
  end
  
  # メモリの全クリア
  def clear
    return if @page_num.nil?

    @pages = []
    0.upto(@page_num - 1) {|pn|
      if @pages[pn].nil? then
        @pages[pn] = MemBank.new(@page_size, @bank_num)
      else
        @pages[pn].clear
      end
    }
  end

  # @attr_reader :pages [MemBank[]] MemBankの配列
  attr_reader(:pages)
  
  # メモリ読出し
  # @param addr [Fixnum]  16bitメモリアドレス
  # @return     [Fixnum]  8bitデータ
  def [](addr)
    pg_num, pg_addr = decode(addr)
    return @pages[pg_num][pg_addr] || 0
  end
  
  # メモリ書込み
  # @param addr [Fixnum]  16bitメモリアドレス
  # @param byte [Fixnum]  8bitデータ
  def []=(addr, byte)
    pg_num, pg_addr = decode(addr)
    @pages[pg_num][pg_addr] = byte & @byte_mask
  end
  
  private
  # 16bitメモリアドレスをページ番号と相対アドレスに変換
  # @param addr [Fixnum] 16bitアドレス
  # @return [Fixnum]  ページ番号
  # @return [Fixnum]  相対アドレス
  def decode(addr)
    addr &= @addr_mask
    return (addr / @page_size), (addr % @page_size)
  end
end

# バンク制御用クラス
class MemBank

  # コンストラクタ
  # @param size [Fixnum]      メモリサイズ
  # @option num [Fixnum] (1)  初期バンク数
  def initialize(size, num = 1)
    @bank_size = size
    @bank_num  = num
    clear
  end
  
  # バンクメモリの全クリア
  def clear
    @bank_no  = 0
    @bank_mem = []
    0.upto(@bank_num - 1) {|bn| @bank_mem[bn] = []}
  end

  # attr_reader :bank_no [Fixnum] バンク番号の取得（0～バンク数-1）
  attr_reader(:bank_no)
  
  # バンク番号の設定
  #   もし初期バンク数を超えたバンク番号が指定された場合は、自動的に
  #   保持バンク数が拡張される。
  # @param no [Fixnum] バンク番号（0～）
  def bank_no=(no)
    @bank_num = no + 1 if @bank_num <= no 
    @bank_no  = no
  end
  
  # メモリ読出し
  # @param addr [Fixnum]  ページ内相対メモリアドレス
  # @return     [Fixnum]  8bitデータ  
  def [](addr)
    @bank_mem[@bank_no] = [] if @bank_mem[@bank_no].nil?
    return @bank_mem[@bank_no][addr] || 0
  end
  
  # メモリ書込み
  # @param addr [Fixnum]  ページ内相対メモリアドレス
  # @param byte [Fixnum]  8bitデータ
  def []=(addr, byte)
    @bank_mem[@bank_no][addr] = byte
  end
end

#
# Test
#
if $0 == __FILE__ then
  mem = Ram16.new(4, 2)
  size = 0x1000
  
  puts "\nTest1: write and read."
  0.upto(size - 1) {|addr| mem[addr] = addr % 256}
  puts "page 0: bank no=#{mem.pages[0].bank_no}"
  mem.dump(0x0000, size)
  
  puts "\nTest2: bank change."
  mem.pages[0].bank_no = 1
  0.upto(0x1ff) {|addr| mem[addr] = 0xff}
  puts "page 0: bank no=#{mem.pages[0].bank_no}"
  mem.dump(0x0000, 0x200)
  
  mem.pages[0].bank_no = 0
  puts "page 0: bank no=#{mem.pages[0].bank_no}"
  mem.dump(0x0000, 0x200)

end