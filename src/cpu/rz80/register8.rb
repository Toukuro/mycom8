require "../lib/register"

# 8bitレジスタクラス
class Register8 < Register

  # コンストラクタ
  # @param  init_val  [Integer] 初期値。Integerのほか、to_iが使えるオブジェクト
  def initialize(init_val = 0)
    super(init_val, Byte)
  end

  # 上位ニブルの取得
  def hnib
    (@value.to_ui >> 4) & 0xf
  end 
  
  # 上位にブルの設定
  def hnib=(val)
    @value = ((val & 0x0f) << 4) | (@value.to_ui & 0x0f)
  end
  
  # 下位ニブルの取得
  def lhib
    @value.to_ui & 0xf
  end 

  # 下位ニブルの設定
  def lnib=(val)
    @value = (@value.to_ui & 0xf0) | (val & 0x0f)
  end
end