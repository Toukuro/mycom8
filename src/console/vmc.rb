require "../lib/shellbase"
#
# Virtual Machine Console
#
class VMConsole

	# 初期化
	def initialize
		@vm = nil
		@topsh = TopShell.new(self)
	end

	attr_accessor(:vm)
	
	# コマンドの解析と実行
	def exec_command(cmd = nil)
		if cmd.nil? then
			@topsh.interaction
		else
			@topsh.exec_command(cmd)
		end
	end
end

class ShellBase
	# protected メソッド
	protected
	
	# 16進数文字列を桁数に応じたBinary型に変換
	# @param str	[String]	16進数表現の文字列
	def hex2bin(str)
		if (0..2).include?(str.size) then
			return Byte.new(str.hex)
		elsif (3..4).include?(str.size) then
			return Word.new(str.hex)
		elsif (5..8).include?(str.size) then
			return DWord.new(str.hex)
		else
			return QWord.new(str.hex)
		end
	end
end

# Top Shell
#
class TopShell < ShellBase
	def initialize(vcons)
		super()
		@prompt = 'TOP=> '
		@vcons = vcons
		@vmsh  = VmShell.new(vcons)
		@cpush = CpuShell.new(vcons)
		@memsh = MemShell.new(vcons)
		@iosh  = IoShell.new(vcons)
		@devsh = DevShell.new(vcons)
	end
	
	attr_accessor(:vm)

	def regist_commands
		#
		add_command('vm',
			lambda {|argv|
				if argv.empty? then
					@vmsh.interaction
				else
					@vmsh.exec_command(argv[0], argv[1 .. -1])
				end
			},
			'VM操作コマンド',
			'[attach|start|stop]'
		)
		#
		add_command('cpu',
			lambda {|argv|
				if argv.empty? then
					@cpush.interaction
				else
					@cpush.exec_command(argv[0], argv[1 .. -1])
				end
			},
			'CPU操作コマンド',
			'[go|step|regs|getreg|setreg]'
		)
		#
		add_command('mem',
			lambda {|argv|
				if argv.empty? then
					@memsh.interaction
				else
					@memsh.exec_command(argv[0], argv[1 .. -1])
				end
			},
			'メモリ操作コマンド',
			'[load|save|dump|write]'
		)
		#
		add_command('io',
			lambda {|argv| 
				if argv.empty? then
					@iosh.interaction
				else
					@iosh.exec_command(argv[0], argv[1 .. -1])
				end
			},
			'I/O操作コマンド',
			'[map|read|write]'
		)
		#
		add_command('dev',
			lambda {|argv| 
				if argv.empty? then
					@devsh.interaction
				else
					@devsh.exec_command(argv[0], argv[1 .. -1])
				end
			},
			'デバイス操作コマンド',
			'[read|write]'
		)
	end
end

# VM操作Shell
#
class VmShell < ShellBase
	def initialize(vcons)
		super()
		@prompt = 'VM=> '
		@vcons = vcons
	end

	def regist_commands
		add_command('attach',
			lambda {|argv|
				vm_name = vm_path = argv[0]
				vm_path = argv[1] unless argv[1].nil?
				relative_path = "../vm/#{vm_path}/#{vm_name}"
				puts "relative_path=[#{relative_path}]"
				require_relative(relative_path)
				
				vm_klass = Module.const_get(vm_name)
				@vcons.vm = vm_klass.new
				puts "vm #{vm_name} attached."
			},
			'仮想マシンのインスタンスを生成します。',
			'<vm-name>'
		)
		add_command('start',
			lambda {|argv| 
				if @vm.nil? then
					puts "vm not attached."
					return is_exit
				end 
				@vcons.vm.start
				puts "vm started."
			},
			'仮想マシンのインスタンスを実行します。'
		)
		add_command('stop',
			lambda {|argv|
				@vcons.vm.stop
				@vcons.vm = nil
				puts "vm stoped."
			},
			'仮想マシンのインスタンスを停止します。'
		)
	end
end

# CPU操作Shell
#
class CpuShell < ShellBase
	def initialize(vcons)
		super()
		@prompt = 'CPU=> '
		@vcons = vcons
	end

	def regist_commands
		# cpu go [addr]
		add_command('go',
			lambda {|argv| 
				addr = hex2bin(args[0]) unless args[0].nil?
				@vcons.vm.cpu.go(addr)
			},
			'指定したアドレスよりCPUを動作させる',
			'[<addr>]'
		)
		# cpu step [addr]
		add_command('step',
			lambda {|argv|
				addr = hex2bin(args[0]) unless args[0].nil?
				@vcons.vm.cpu.step(addr)
			},
			'指定したアドレスより１命令のみCPUを動作させる',
			'[<addr>]'
		)
		# cpu regs
		add_command('regs',
			lambda {|argv| 
				@vcons.vm.cpu.regs()
			},
			'すべてのレジスタの内容を表示する'
		)
		# cpu getreg <reg-name>
		add_command('getreg',
			lambda {|argv| 
				return if args[0].nil?
				@vcons.vm.cpu.get_reg(args[0])
				},
			'指定したレジスタの内容を表示する',
			'<reg-name>'
		)
		# cpu setreg <reg-name> <value>
		add_command('setreg',
			lambda {|argv| 
				return if args[0].nil?
				data = args[1].hex  unless args[1].nil?
				unless @vcons.vm.cpu.set_reg(args[0], data).nil? then
					@vcons.vm.cpu.get_reg(args[0])
				end 
				},
			'レジスタに値を設定する',
			'<reg-name> <value>'
		)
	end
end

# メモリ操作Shell
#
class MemShell < ShellBase
	def initialize(vcons)
		super()
		@prompt = 'MEM=> '
		@vcons = vcons
	end

	def regist_commands
		# mem load <addr> <file-name>
		add_command('load',
			lambda {|argv| 
				size = @vm.mem.load(hex2bin(args[0]), args[1])
				puts "#{size} byte loaded."
				},
			'メモリの指定アドレスからデータをロードする',
			'<addr> <file-name>'
		)
		# mem save <addr> <size> <file-name>
		add_command('save',
			lambda {|argv|
				@vm.mem.save(hex2bin(args[0]), args[1].to_i, args[2])
			},
			'メモリの指定アドレスからデータをセーブする',
			'<addr> <size> <file-name>'
		)
		# mem dump <addr> [size=1KB]
		add_command('dump',
			lambda {|argv| 
				@vm.mem.dump(hex2bin(args[0]), (args[1] || 1024).to_i)
			},
			'メモリの指定アドレスからメモリ内容をダンプ表示する',
			'<addr> [<size=256>]'
		)
		# mem write <addr>
		add_command('write',
			lambda {|argv| 
				addr = hex2bin(argv[0])
				puts "Type 'exit' to complete the entry"
				while true do
					print sprintf("%04X: ", addr)
	
					data = STDIN.gets.chomp
					break if data == "exit"
					redo  if data.empty?
	
					@vm.mem.write(addr, hex2bin(data))
					addr += 1
				end 
				},
			'メモリの指定アドレスからデータを直接更新する',
			'<addr>'
		)
	end
end

# I/O操作Shell
#
class IoShell < ShellBase
	def initialize(vcons)
		super()
		@prompt = 'IO=> '
		@vcons = vcons
	end

	def regist_commands
		add_command('map',
			lambda {|argv| 
			},
			''
		)
		add_command('read',
			lambda {|argv| 
			},
			''
		)
		add_command('write',
			lambda {|argv| 
			},
			''
		)
	end
end

# デバイス操作Shell
#
class DevShell < ShellBase
	def initialize(vcons)
		super()
		@prompt = 'DEV=> '
		@vcons = vcons
	end

	def regist_commands
		add_command('read',
			lambda {|argv| 
			},
			''
		)
		add_command('write',
			lambda {|argv| 
			},
			''
		)
	end
end

if $0 == __FILE__ then
	begin
		VMROOT_PATH = File.absolute_path("..")
		VM_PATH  = "#{VMROOT_PATH}/vm"
		CPU_PATH = "#{VMROOT_PATH}/cpu"

		$LOAD_PATH.push(VMROOT_PATH)

		# puts "ARGV=#{ARGV.to_s}"
		if ARGV[0] == 'irb' then
			cmd = "irb -I #{VMROOT_PATH}"
			puts cmd
			system(cmd)
		else
			vmcons = VMConsole.new		
			vmcons.exec_command("vm attach #{ARGV[0]}") unless ARGV[0].nil?
			vmcons.exec_command()
		end
		
#  rescue 
		
  end
end