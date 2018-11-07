require "../lib/devicebase"

# PPI8255クラス
#		i8255のエミュレーション
class PPI8255 < DeviceBase
	
	# 入出力モード
	IOMODE_BASIC  = 0
	IOMODE_STROBE = 1
	IOMODE_BIDIR  = 2
	
	# 入出力方向
	IODIR_OUTPUT = 0
	IODIR_INPUT  = 1
	
	# ポートアドレス
	PORT_A = 0x00
	PORT_B = 0x01
	PORT_C = 0x02
	PORT_CTRL = 0x03
	
	# コンストラクタ
	def initialize()
		super(Bit2, Byte)		# AddrBit=2bit, DataBit=8bit
		@groupA_mode = IOMODE_BASIC
		@gropuA_portA_dir = IODIR_OUTPUT
		@groupA_portC_dir = IODIR_OUTPUT
		@groupB_mode = IOMODE_BASIC
		@groupB_portB_dir = IODIR_OUTPUT
		@groupB_portC_dir = IODIR_OUTPUT
		@port_data = Array.new(Bit2.max_value) {Byte.new}
	end
	
	# データの読出し
	# @param addr [Word]	デバイスアドレス
	# @return [Byte]	読み出した値
	def read(addr)
		case addr.to_ui
		when 0b00		# PortA
			@port_data[PORT_A] = Byte.new(portA_read()) if @gropuA_portA_dir == IODIR_INPUT
			return @port_data[PORT_A]
		when 0b01		# PortB
			@port_data[PORT_B] = Byte.new(portB_read()) if @groupB_portB_dir == IODIR_INPUT
			return @port_data[PORT_B]
		when 0b10		# PortC(hnib=groupA, lnib=groupB)
			data = @port_data[PORT_C].to_ui
			data = (portCA_read() << 4) | (data & 0x0f)   if @groupA_portC_dir == IODIR_INPUT
			data = (data & 0xf0) | (portCB_read() & 0x0f) if @groupB_portC_dir == IODIR_INPUT
			@port_data[PORT_C] = Byte.new(data)
			return @port_data[PORT_C]
		when 0b11		# Control
			return @port_data[PORT_CTRL]
		end
	end
	
	# データの書き込み
	# @param addr [Word]	デバイスアドレス
	# @param byte [Byte]	書き込む値
	def write(addr, byte)
		case addr.to_ui
		when 0b00		# PortA
			@port_data[PORT_A] = byte
			portA_write(@port_data[PORT_A].to_ui) if @gropuA_portA_dir == IODIR_OUTPUT
			
		when 0b01		# PortB
			@port_data[PORT_B] = byte
			portB_write(@port_data[PORT_B].to_ui) if @gropuB_portB_dir == IODIR_OUTPUT
			
		when 0b10		# PortC(hnib=groupA, lnib=groupB)
			@port_data[PORT_C] = byte
			portCA_write(@port_data[PORT_C].hnib) if @groupA_portC_dir == IODIR_OUTPUT
			portCB_write(@port_data[PORT_C].lnib)	if @groupB_portC_dir == IODIR_OUTPUT
			
		when 0b11		# Control
			@port_data[PORT_CTRL] = byte
			if byte.bit(8).nonzero? then
				# D7:1 mode set
				# D6-5: GroupA Mode selection
				@groupA_mode = (byte >> 5) & 0x3
				# D4: GroupA PortA, In/Out setting
				@gropuA_portA_dir = byte.bit(4)
				# D3: GroupA PortC upper, In/Out setting
				@groupA_portC_dir = byte.bit(3)
				# D2: GroupB Mode selection
				@groupB_mode = byte.bit(2)
				# D1: GroupB PortB, In/Out setting
				@groupB_portB_dir = byte.bit(1)
				# D0: GroupB PortC lower, In/Out setting
				@groupB_portC_dir = byte.bit(0)
			else
				# D7:0 Bit set/reset
				# D3-1: bit no of PortC
				bit_no = (byte >> 1) & 0x7
				@port_data[PORT_C].set_bit(bit_no, byte.bit(0)) 
				portCA_write(@port_data[PORT_C].hnib) if @groupA_portC_dir == IODIR_OUTPUT
				portCB_write(@port_data[PORT_C].lnib)	if @groupB_portC_dir == IODIR_OUTPUT
			end
		end
	end
	
	# ポートAの読込み
	# @return	[Integer]	読み出した値
	def portA_read()
		return 0
	end
	
	# ポートAへの書き込み
	# @param value [Integer]	書き込む値
	def portA_write(value)
	end
	
	# ポートBの読込み
	# @return	[Integer]	読み出した値
	def portB_read()
		return 0
	end
	
	# ポートBへの書き込み
	# @param value [Integer]	書き込む値
	def portB_write(value)
	end
	
	# ポートC(グループA)の読込み
	# @return	[Integer]	読み出した値
	def portCA_read()
		return 0
	end
	
	# ポートC(グループA)への書き込み
	# @param value [Integer]	書き込む値
	def portCA_write(value)
	end
	
	# ポートC(グループB)の読込み
	# @return	[Integer]	読み出した値
	def portCB_read()
		return 0
	end
	
	# ポートC(グループB)への書き込み
	# @param value [Integer]	書き込む値
	def portCB_write(value)
	end
end