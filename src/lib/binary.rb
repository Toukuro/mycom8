# バイナリデータクラス
class Binary

  @bit_width = 0   # データのビット幅（派生クラスにて設定する）
  @max_value = 0   # このデータ型が取りうる最大値
  @mask      = 0   # ビットマスク

  # バイナリのビット幅
  # @return   [Integer]
  def self.bit_width
    return @bit_width
  end
  
  # バイナリの最大値
  # @return   [Integer]
  def self.max_value
    @max_value = 2 ** @bit_width if @max_value.nil?
    return @max_value
  end 
  
  # バイナリ値を得るためのビットマスク
  # @return   [Integer]
  def self.mask
    @mask = self.max_value - 1 if @mask.nil?
    return @mask
  end 
  
  # クラスの比較
  # @return   [Boolean]
  def self.===(obj)
    obj.kind_of?(self)
  end

  # コンストラクタ
  # @param init_val   [Integer] 初期設定値
  def initialize(init_val = 0)
    # クラス変数 @bit_widthが初期化されていなければエラー
    throw ArgumentError.new if self.class.bit_width.zero?
    
    @value = init_val.to_i & self.class.mask   # 内部値は符号なし整数
  end

  # 符号付整数に変換
  def to_i
    self.sign.zero? ? @value : (@value - self.class.max_value)
  end

  # 符号なし整数に変換
  def to_ui
    @value
  end

  # 指定した基数表現の文字列に変換
  def to_s(base = nil)
    base.nil? ? @value.to_i.to_s : @value.to_s(base)
  end

  # 16進数表現の文字列に変換
  def to_x
    sprintf("%X", self.to_ui)
  end
  
  # 文字コード変換
  def chr
    @value.chr
  end 
  
  # 指定されたエンコードの文字に変換
  def chr(encode = Encoding::ASCII)
    @value.chr(encode)
  end
  
  # バイト単位の値の参照
  # @param  idx   [Integer] 下位バイトからのインデックス（０～）
  # @return       [Integer]
  def [](idx)
    return self if idx < 0
    shift_bits = 8 * idx

    (@value & (0xff << shift_bits)) >> shift_bits
  end 

  # バイト単位の値の設定
  # @param  idx   [Integer] 下位バイトからのインデックス（０～）
  # @param  value [Integer]
  def []=(idx, value)
    return self if idx < 0
    shift_bits = 8 * idx

    value <<= shift_bits
    val_mask = @mask & (0xff << shift_bits)
    @value = (@value & ~val_mask) | (value & val_mask)
  end 

  # 比較：一致
  # @param  obj   [Binary|Integer]
  # @return [boolean]
  def ==(obj)
    self.to_i == obj.to_i
  end

  # 比較：不一致
  # @param  obj   [Binary|Integer]
  # @return [boolean]
  def !=(obj)
    self.to_i != obj.to_i
  end

  # 比較：小なり
  # @param  obj   [Binary|Integer]
  # @return [boolean]
  def <(obj)
    self.to_i < obj.to_i
  end

  # 比較：小なり＋一致
  # @param  obj   [Binary|Integer]
  # @return [boolean]
  def <=(obj)
    self.to_i <= obj.to_i
  end

  # 比較：大なり
  # @param  obj   [Binary|Integer]
  # @return [boolean]
  def >(obj)
    self.to_i > obj.to_i
  end

  # 比較：大なり＋一致
  # @param  obj   [Binary|Integer]
  # @return [boolean]
  def >=(obj)
    self.to_i >= obj.to_i
  end

  # 加算
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def +(obj)
    self.class.new(self.to_i + obj.to_i)
  end

  # 減算
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def -(obj)
    self.class.new(self.to_i - obj.to_i)
  end

  # 乗算
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def *(obj)
    self.class.new(self.to_i * obj.to_i)
  end

  # 除算
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def /(obj)
    self.class.new(self.to_i / obj.to_i)
  end

  # 論理和
  def |(obj)
    self.class.new(self.to_i | obj.to_i)
  end

  # 論理積
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def &(obj)
    self.class.new(self.to_i & obj.to_i)
  end

  # 排他的論理和
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def ^(obj)
    self.class.new(self.to_i ^ obj.to_i)
  end
  
  # 左ビットシフト
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def <<(obj)
    self.class.new(self.to_i << obj.to_i)
  end 
  
  # 右ビットシフト
  # @param  obj   [Binary|Integer]
  # @return       [Binary]
  def >>(obj)
    self.class.new(self.to_i >> obj.to_i)
  end 
  
  # ビット値の取得
  # @param  bit_no  [Integer] ビット位置（LSB=0）
  # @return         [Integer] 0 or 1
  def bit(bit_no)
    @value[bit_no]
  end
  
  # ビット値の設定
  # @param  bit_no  [Integer] ビット位置（LSB=0）
  # @param  value   [Integer] 0 or 1
  def set_bit(bit_no, value)
    val_mask = 1 << bit_no
    if value.zero? then
      # reset
      @value = (@value.to_ui & ~val_mask) & @mask
    else
      # set
      @value = (@value.to_ui | val_mask) & @mask
    end
  end
  
  # ゼロ判定
  def zero?
    @value.zero?
  end 
  
  # 符号値
  # @return       [Integer] 正：0、負：1
  def sign
    @value[self.class.bit_width - 1]
  end
  
  # パリティ
  # @return       [Integer] 偶数：0、奇数：1
  def parity
    work = @value
    shift_bits = 32
    until shift_bits.zero?
      work ^= work >> shift_bits
      shift_bits >>= 1
    end 
    work & 1
  end
end

# ===========================================================================
# Binaryの派生クラス定義

# ビット型クラス
class Bit1 < Binary
  @bit_width = 1
end 
Bit = Bit1

# ダブルビット幅
class Bit2 < Binary
  @bit_width = 2
end 
DBit = Bit2

# ニブル型クラス
class Bit4 < Binary
  @bit_width = 4
end 
Nibble = Bit4

class Bit6 < Binary
  @bit_width = 6
  
  def to_x
    sprintf("%02X", self.to_ui)
  end
end 

# バイト型クラス
class Bit8 < Binary
  @bit_width = 8
  
  def to_x
    sprintf("%02X", self.to_ui)
  end
end
Byte = Bit8

class Bit10 < Binary
  @bit_width = 10
  
  def to_x
    sprintf("%03X", self.to_ui)
  end
end 

# トリニブル型クラス
class Bit12 < Binary
  @bit_width = 12
  
  def to_x
    sprintf("%03X", self.to_ui)
  end
end 
TNibble = Bit12

class Bit14 < Binary
  @bit_width = 14
  
  def to_x
    sprintf("%04X", self.to_ui)
  end
end

# ワード型クラス
class Bit16 < Binary
  @bit_width = 16
  
  def to_x
    sprintf("%04X", self.to_ui)
  end
end
Word = Bit16

# ダブルワード型クラス
class Bit32 < Binary
  @bit_width = 32
  
  def to_x
    sprintf("%08X", self.to_ui)
  end
end
DWord = Bit32

# クワッドワード型クラス
class Bit64 < Binary
  @bit_width = 64
  
  def to_x
    sprintf("%16X", self.to_ui)
  end
end 
QWord = Bit64