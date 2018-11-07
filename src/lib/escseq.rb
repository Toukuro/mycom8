# コンソールエスケープシーケンス制御
class EscSeq
  # クリアモード
  MODE_AFTER  = 0   # カーソルより後ろ
  MODE_BEFORE = 1   # カーソルより前
  MODE_ALL    = 2   # すべて

  # カーソルを上に移動
  # @param rows [Fixnum]  移動行数
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_up(rows, str = nil)
    print "\e[#{rows}A#{str || ''}"
    return self
  end

  # カーソルを下に移動
  # @param rows [Fixnum]  移動行数
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_down(rows, str = nil)
    print "\e[#{rows}B#{str || ''}"
    return self
  end

  # カーソルを右に移動
  # @param cols [Fixnum]  移動桁数
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_right(cols, str = nil)
    print "\e[#{cols}C#{str || ''}"
    return self
  end

  # カーソルを左に移動
  # @param cols [Fixnum]  移動桁数
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_left(cols, str = nil)
    print "\e[#{cols}D#{str || ''}"
    return self
  end

  # カーソルを指定行数下の先頭に移動
  # @param rows [Fixnum]  移動行数
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_bellow(rows, str = nil)
    print "\e[#{rows}E#{str || ''}"
    return self
  end

  # カーソルを指定行数上の先頭に移動
  # @param rows [Fixnum]  移動行数
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_above(rows, str = nil)
    print "\e[#{rows}F#{str || ''}"
    return self
  end

  # カーソルを指定桁に移動
  # @param col  [Fixnum]  移動桁位置
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_tab(col, str = nil)
    print "\e[#{col}G#{str || ''}"
    return self
  end

  # カーソルを指定の行・列に移動
  # @param row  [Fixnum]  移動行位置（１～）
  # @param col  [Fixnum]  移動桁位置（１～）
  # @param str  [Fixnum]  追加出力する文字列
  def self.move_pos(row, col, str = nil)
    print "\e[#{row};#{col}H#{str || ''}"
    return self
  end

  # 画面クリア
  # @param mode [Fixnum]  クリアモード
  def self.clear_screen(mode = MODE_ALL)
    print "\e[#{mode}J"
    return self
  end

  # 行クリア
  # @param mode [Fixnum]  クリアモード
  def self.clear_line(mode = MODE_ALL)
    print "\e[#{mode}K"
    return self
  end

  # 順方向スクロール
  # @param rows [Fixnum]  行数
  def self.scroll_next(rows)
    print "\e[#{rows}S"
    return self
  end

  # 逆方向スクロール
  # @param rows [Fixnum]  行数
  def self.scroll_prev(rows)
    print "\e[#{rows}T"
    return self
  end

  # 属性指定
  # @param n    [Fixnum]  属性値
  # @param str  [Fixnum]  追加出力する文字列
  def self.sgr(n, str = nil)
    print "\e[#{n}m#{str || ''}"
    return self
  end
end