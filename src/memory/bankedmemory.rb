require "../lib/binary"
require "../memory/memory"

# バンク切り替えメモリクラス
class BankedMemory < Memory

  # コンストラクタ
  def initialize(addr_bits = 16, bank_num = 1)
    super(addr_bits)

    @bank_num = bank_num
    @bank_no  = 0
    @bank_num.times {@data_arry << Memory.new(addr_bits)}
  end

  # attr_reader :bank_no [Fixnum] バンク番号の取得：0～(bank_num - 1)
  attr_reader :bank_no

  # バンク番号の設定
  # @param no [Fixnum]  バンク番号：0～(bank_num - 1)
  def bank_no=(no)
    @bank_no = no if no >= 0 && no < @bank_num
  end

  # メモリ読出し
  # @param addr [Fixnum]  メモリアドレス
  # @return     [Byte]    読出しデータ(byte)
  def mem_read(addr)
    @bankarry[@bank_no][addr]
  end

  # メモリ書込み
  # @param addr [Fixnum]  メモリアドレス
  # @param byte [Byte]    書込みデータ(byte)
  def mem_write(addr, byte)
    @bankarry[@bank_no][addr] = byte
  end
end

# Test
if $0 == __FILE__ then
end