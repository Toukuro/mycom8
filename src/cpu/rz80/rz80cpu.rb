require "lib/cpubase"
require "cpu/rz80/rz80alu"
require "cpu/rz80/rz80register"
require "cpu/rz80/rz80cpu_inst00"
require "cpu/rz80/rz80cpu_inst01"
require "cpu/rz80/rz80cpu_inst10"
require "cpu/rz80/rz80cpu_inst11"
require "cpu/rz80/rz80cpu_inst11dd"
require "cpu/rz80/rz80cpu_inst11ed"
require "cpu/rz80/rz80io"

class Rz80CPU < CPUBase
  
  ####  定数定義
  ##  命令コードのデコード値
  # 命令コード区分
  INSTDIV_00 = 0
  INSTDIV_01 = 1   # 8bit load
  INSTDIV_10 = 2   # 8bit arithmetic
  INSTDIV_11 = 3

  # 命令コードオペランド（8bitレジスタ）
  REG8_B  = 0b000   # Bレジスタ
  REG8_C  = 0b001   # Cレジスタ
  REG8_D  = 0b010   # Dレジスタ
  REG8_E  = 0b011   # Eレジスタ
  REG8_H  = 0b100   # Hレジスタ
  REG8_L  = 0b101   # Lレジスタ
  REF8_HL = 0b110   # HLレジスタ参照
  REG8_A  = 0b111   # Aレジスタ

  # 命令コードオペランド（演算操作）
  OPR8_ADD = 0b000  # 加算
  OPR8_ADC = 0b001  # キャリー加算
  OPR8_SUB = 0b010  # 減算
  OPR8_SBC = 0b011  # キャリー減算
  OPR8_AND = 0b100  # 論理演算 AND
  OPR8_XOR = 0b101  # 論理演算 XOR
  OPR8_OR  = 0b110  # 論理演算 OR
  OPR8_CP  = 0b111  # 論理演算 CP

  # 命令コードオペランド（16bitレジスタ）
  REG16_BC = 0b00
  REG16_DE = 0b01
  REG16_HL = 0b10
  REG16_SP = 0b11

  # 命令コードオペランド（8/16bit参照）
  REF8_BC  = 0b00
  REF8_DE  = 0b01
  REF16_NN = 0b10
  REF8_NN  = 0b11

  # コンストラクタ
  # @param mem  [Memory]  仮想メモリ空間オブジェクト
  def initialize(mem)
    @IR     = Register8.new       # IRレジスタ（命令コード読込用）
    @AD     = Register16.new      # アドレス計算用レジスタ（16ビット作業用）
    @regs   = Rz80Register.new    # 汎用レジスタセット
    @alu    = Rz80ALU.new         # 8bit演算ユニット
    @mem    = mem                 # メモリ
    @port   = Rz80IO.new          # I/Oポート
    @isHalt = false               # 実行停止状態
    @isIntEnable = true           # 割り込み許可
    @fetched = []                 # フェッチしたデータ（情報出力用）
  end
  
  # I/O Port
  attr_reader(:port)

  # ===========================================================================
  # CPUの制御に関するメソッド
  
  # 指定アドレスから、処理を実行する
  # @param addr [Binary]  実行開始アドレス
  def go(addr = nil)
    @regs.regPC.value = addr unless addr.nil?

    @isHalt = false
    until @isHalt
      step()
    end
  end
  
  # 指定アドレスから、1命令のみ処理を実行する
  # @param addr [Binary]  実行開始アドレス
  def step(addr = nil)
    @regs.regPC.value = addr unless addr.nil?
    printf("%04X ", @regs.regPC.value.to_ui)
    @fetched = []
    
    # 命令フェッチ（IRレジスタに設定）
    fetch()

    begin
      case inst_div
      when INSTDIV_00    # 00 xxx xxx
        inst00(inst_opr1, inst_opr2)
      when INSTDIV_01    # 01 xxx xxx
        inst01(inst_opr1, inst_opr2)
      when INSTDIV_10    # 10 xxx xxx
        inst10(inst_opr1, inst_opr2)
      when INSTDIV_11    # 11 xxx xxx
        inst11(inst_opr1, inst_opr2)
      end
    rescue VmCpuInstructionError
      dump = ''
      @fetched.each {|b| dump << " b.to_x"}
      puts "Invalid instruction. [#{dump}]"
    end
  end 

  # 全レジスタの内容を表示する
  def regs()
    @alu.dump
    @regs.dump
  end
  
  # 指定したレジスタの値を表示する
  def get_reg(reg_name)
    case reg_name
    when 'B'
      printf("%s : %02X\n", reg_name, @regs.regB.to_i)
    when 'C'
      printf("%s : %02X\n", reg_name, @regs.regC.to_i)
    when 'D'
      printf("%s : %02X\n", reg_name, @regs.regD.to_i)      
    when 'E'
      printf("%s : %02X\n", reg_name, @regs.regE.to_i)
    when 'H'
      printf("%s : %02X\n", reg_name, @regs.regH.to_i)
    when 'L'
      printf("%s : %02X\n", reg_name, @regs.regL.to_i)
    when 'A'
      printf("%s : %02X\n", reg_name, @alu.regA.to_i)
    when 'F'
      printf("%s : %02X\n", reg_name, @alu.regF.to_i)
    when 'BC'
      printf("%s : %04X\n", reg_name, @regs.regBC.to_i)
    when 'DE'
      printf("%s : %04X\n", reg_name, @regs.regDE.to_i)
    when 'HL'
      printf("%s : %04X\n", reg_name, @regs.regHL.to_i)
    when 'IX'
      printf("%s : %04X\n", reg_name, @regs.regIX.to_i)
    when 'IY'
      printf("%s : %04X\n", reg_name, @regs.regIY.to_i)
    when 'PC'
      printf("%s : %04X\n", reg_name, @regs.regPC.to_i)
    when 'SP'
      printf("%s : %04X\n", reg_name, @regs.regSP.to_i)
    else
      puts "[#{reg_name}] is unknown register."
    end 
  end 
  
  # 指定したレジスタに値を設定する
  def set_reg(reg_name, value)
    case reg_name
    when 'B'
      @regs.regB.value = Byte.new(value.to_i)
    when 'C'
      @regs.regC.value = Byte.new(value.to_i)
    when 'D'
      @regs.regD.value = Byte.new(value.to_i)
    when 'E'
      @regs.regE.value = Byte.new(value.to_i)
    when 'H'
      @regs.regH.value = Byte.new(value.to_i)
    when 'L'
      @regs.regL.value = Byte.new(value.to_i)
    when 'A'
      @alu.regA.value = Byte.new(value.to_i)
    when 'F'
      @alu.regF.value = Byte.new(value.to_i)
    when 'BC'
      @regs.regBC.value = Word.new(value.to_i)
    when 'DE'
      @regs.regDE.value = Word.new(value.to_i)
    when 'HL'
      @regs.regHL.value = Word.new(value.to_i)
    when 'IX'
      @regs.regIX.value = Word.new(value.to_i)
    when 'IY'
      @regs.regIY.value = Word.new(value.to_i)
    when 'PC'
      @regs.regPC.value = Word.new(value.to_i)
    when 'SP'
      @regs.regSP.value = Word.new(value.to_i)
    else
      puts "[#{reg_name}] is unknown register."
      return nil
    end 
  end 
  
  # ===========================================================================
  # CPUの命令実行に関するメソッド
  private 
  
  # 命令処理モジュールのインクルード
  include Rz80CPUInst00
  include Rz80CPUInst01
  include Rz80CPUInst10
  include Rz80CPUInst11
  include Rz80CPUInst11DD
  include Rz80CPUInst11ED
  
  # 処理停止
  def halt
    @isHalt = true
  end

  # 命令コードをフェッチし、IRレジスタにセット
  # @return [Byte]  フェッチした命令コード
  # @note  プログラムカウンタの指すメモリのデータを取得後、
  #        プログラムカウンタに１加算する
  def fetch()
    @IR.value = get_ref8(@regs.regPC)
    @regs.inc(@regs.regPC)
    @fetched << @IR.value
    puts " #{@IR.value.to_x}"
    
    return @IR.value
  end
  
  # IRレジスタから命令区分を取得
  def inst_div
    (@IR.value >> 6) & 0x03
  end 
  
  # IRレジスタから第1オペランドを取得
  def inst_opr1
    (@IR.value >> 3) & 0x07
  end 
  
  # IRレジスタから第2オペランドを取得
  def inst_opr2
    @IR.value & 0x07
  end 

  # ---------------------------------------------------------------------------
  # レジスタおよびメモリ参照の共通メソッド
  
  # オペランド値から対応する8bitレジスタを取得
  # @param opr  [Fixnum]  オペランド値
  # @return     [register]  オペランド値に対応するレジスタ
  def opr_reg8(opr)
    case opr
    when REG8_B     # 000
      @regs.regB
    when REG8_C     # 001
      @regs.regC
    when REG8_D     # 010
      @regs.regD
    when REG8_E     # 011
      @regs.regE
    when REG8_H     # 100
      @regs.regH
    when REG8_L     # 101
      @regs.regL
    when REF8_HL    # 110
      @alu.regTMP
    when REG8_A     # 111
      @alu.regA
    else
      nil
    end
  end

  # オペランド値から対応する16bitレジスタを取得
  # @param opr  [Fixnum]  オペランド値
  def opr_reg16(opr)
    case opr
    when REG16_BC   # 00
      @regs.regBC
    when REG16_DE   # 01
      @regs.regDE
    when REG16_HL   # 10
      @regs.regHL
    when REG16_SP   # 11
      @regs.regSP
    end
  end
  
  # 8bitメモリ読出し
  # @param  reg16 [Register16]  16bitレジスタを示すオブジェクト
  # @return       [Byte]        16bitレジスタが示す1byteのメモリ内容
  def get_ref8(reg16)
    @mem[reg16.value]
  end
  
  # IX+disp からの8bitメモリ読出し
  # 【注意】アドレス計算に@ADレジスタを使用する
  # @param  disp  [Byte]    IXレジスタからの変位
  # @return       [Byte]    (IX+disp)が示す1byteのメモリ内容
  def get_ref8ix(disp)
    return get_ref8idx(@regs.regIX, disp)
  end

  # IY+disp からの8bitメモリ読出し
  # 【注意】アドレス計算に@ADレジスタを使用する
  # @param  disp  [Byte]    IYレジスタからの変位
  # @return       [Byte]    (IY+disp)が示す1byteのメモリ内容
  def get_ref8iy(disp)
    return get_ref8idx(@regs.regIY, disp)
  end

  # IX/IY+disp からの8bitメモリ読出し
  # 【注意】アドレス計算に@ADレジスタを使用する
  # @param  regIdx  [Register16]  IXまたはIYレジスタ
  # @param  disp    [Byte]        IX/IYレジスタからの変位
  # @return         [Byte]        (IX/IY+disp)が示す1byteのメモリ内容
  def get_ref8idx(regIdx, disp)
    @AD.value = regIdx.value + disp.to_i
    return get_ref8(@AD)
  end
  
  # 8bitメモリ書込み
  # @param  reg16 [Register16]  16bitレジスタを示すオブジェクト
  # @param  data  [Byte]        メモリに書き込む1byteのデータ
  def set_ref8(reg16, data)
    @mem[reg16.value] = data
  end

  # IX+disp への8bitメモリ書込み
  # 【注意】アドレス計算に@ADレジスタを使用する
  # @param  disp  [Byte]    IXレジスタからの変位
  # @param  data  [Byte]    メモリ(IX+disp)に書き込む1byteのデータ
  def set_ref8ix(disp, data)
    set_ref8idx(@regs.regIX, disp, data)
  end
  
  # IY+disp への8bitメモリ書込み
  # 【注意】アドレス計算に@ADレジスタを使用する
  # @param  disp  [Byte]    IYレジスタからの変位
  # @param  data  [Byte]    メモリ(IY+disp)に書き込む1byteのデータ
  def set_ref8iy(disp, data)
    set_ref8idx(@regs.regIY, disp, data)
  end
  
  # IX/IY+disp への8bitメモリ書込み
  # 【注意】アドレス計算に@ADレジスタを使用する
  # @param  regIdx  [Register16]  IXまたはIYレジスタ
  # @param  disp    [Byte]        IX/IYレジスタからの変位
  # @return         [Byte]        (IX/IY+disp)が示す1byteのメモリ内容
  def set_ref8idx(regIdx, disp, data)
    @AD.value = regIdx.value + disp.to_i
    set_ref8(@AD, data)
  end
  
  # 16bitメモリ読出し
  # @param  reg16 [Register16]  16bitレジスタを示すオブジェクト
  # @return       [Word]        16bitレジスタが示す2byteのメモリ内容
  def get_ref16(reg16)
    data = Word.new
    data[0] = @mem[reg16.value].to_ui
    data[1] = @mem[reg16.value + 1].to_ui
    return data
  end
  
  # 16bitメモリ書込み
  # @param  reg16 [Register16]  16bitレジスタを示すオブジェクト
  # @param  data  [Word]        メモリに書き込む2byteのデータ
  def set_ref16(reg16, data)
    @mem[reg16.value]     = data[0]
    @mem[reg16.value + 1] = data[1]
  end

  # 1byteデータのスタックへのPush
  # @param  data  [Byte]
  def push8(data)
    @regs.regSP -= 1
    set_ref8(@regs.regSP, data)
  end 
  
  # 1byteデータのスタックからのPop
  # @return       [Byte]
  def pop8()
    data = get_ref8(@regs.regSP)
    @regs.regSP += 1
    return data
  end
  
  # 2byteデータのスタックへのPush
  # @param  data  [Word]
  def push16(data)
    push8(data[1])
    push8(data[0])
  end 
  
  # 2byteデータのスタックからのPop
  # @return       [Word]
  def pop16()
    data = Word.new
    data[0] = pop8()
    data[1] = pop8()
    return data
  end 
end
