#
#	仮想CPU 基底クラス
#
class CPUBase

  # 指定アドレスから、処理を実行する
  def go(addr = nil)
		puts "'go' is not supported."
  end
  
  # 指定アドレスから、1命令のみ処理を実行する
  def step(addr = nil)
		puts "'step' is not supported."
  end
   
  # 全レジスタの内容を表示する
  def regs()
		puts "'regs' is not supported."
  end 
  
  # 指定したレジスタの値を表示する
  # TODO:レジスタの表現方法をどうするか？（名称？）
  def get_reg(reg_name)
		puts "'getreg' is not supported."
  end 
  
  # 指定したレジスタに値を設定する
  def set_reg(reg_name, value)
		puts "'setreg' is not supported."
  end 
end