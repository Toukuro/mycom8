require "../lib/vmerror"
require "../lib/cpubase"
require "../lib/memorybase"
require "../lib/devicebase"

#
# 仮想マシン 基底クラス
#
class VMBase
	
	# コンストラクタ
	def initialize()
		@cpu = CPUBase.new
		@mem = MemoryBase.new
		@dev = DeviceBase.new
		@is_started = false
	end 
	
	# 仮想マシンの起動
	def start()
		@is_started = true
	end
	
	# 仮想マシンの停止
	def stop()
		@is_started = false
	end
		
	# 仮想マシンの各要素を取得
	attr_reader(:cpu, :mem, :dev, :is_started)
end