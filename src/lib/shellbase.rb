require "kconv"

# コマンドライン処理のフレームワーク
#
class ShellBase
	# コンストラクタ
	#
	def initialize(exit_cmd = nil)
		@cmd_dict = CommandDict.new
		@prompt = '> '
		@exit_cmd = exit_cmd || Command.new('exit', nil, 'exit this shell.')
		@cmd_dict.add(@exit_cmd)
		@cmd_dict.add('help', 
			lambda {|argv| @cmd_dict.usage},
			'display this usage list.'
		)

		regist_commands
	end
	
	# 全コマンドの登録処理
	#
	def regist_commands
		#add_command('command-name',
		#	lambda{|argv| proc for command},
		#	'usage for command'
		#)
	end

	# 単一コマンド追加
	#
	def add_command(cmd_or_name, proc = nil, desc = nil, usage = nil)
		@cmd_dict.add(cmd_or_name, proc, desc, usage)
	end
	
	# コマンド実行
	# @param cmd_or_name	[Command|String]
	# @param argv					[String[]]
	def exec_command(cmd_or_name, argv = nil)
		cmd = nil
		case cmd_or_name
		when Command
			cmd = cmd_or_name
		else
			cmdargv = cmd_or_name.split(' ')
			cmd = @cmd_dict.get(cmdargv[0])
			argv = cmdargv[1 .. -1] + (argv || [])
		end
		
		if cmd.nil? then
			puts "'#{cmd_or_name}' is invalid command."
			return nil
		end
		
		return cmd.exec(argv)
	end
	
	# 対話処理
	#
	def interaction
		while true
			print @prompt
			cmdargv = (STDIN.gets.chomp!).split(' ')
			
			ret = exec_command(cmdargv[0], cmdargv[1 .. -1])
			unless ret.nil? then
				#puts "ret=[#{ret}] @exit=[#{@exit_cmd}]"
				if ret == @exit_cmd.name then
					break
				elsif !ret.empty? then
					puts ret
				end
			end
		end
	end
	
	# コマンド辞書
	#
	class CommandDict
		
		def initialize
			@cmd_dict = {}
		end

		def usage
			cmd_name_len = 0
			@cmd_dict.each {|name, cmd|
				len = name.size + cmd.usage.size
				cmd_name_len = len if cmd_name_len < len
			}

			keys = @cmd_dict.keys.sort
			cmd_name_fmt = "%-#{cmd_name_len}s  %s\n"

			keys.each {|name| printf(cmd_name_fmt, 
				"#{name} #{@cmd_dict[name].usage}", @cmd_dict[name].desc)}
			return nil
		end
		
		# コマンド追加
		# @param cmd_or_name
		# @param proc
		# @param decs
		# @param usage
		def add(cmd_or_name, proc = nil, desc = nil, usage = nil)
			case cmd_or_name
			when Command
				# puts "add by Command [#{cmd_or_name.name}]"
				@cmd_dict[cmd_or_name.name] = cmd_or_name
			when String
				# puts "add by String [#{cmd_or_name}]"
				@cmd_dict[cmd_or_name] = Command.new(cmd_or_name, proc, desc, usage)
			end
		end
		
		# コマンド取得
		#
		def get(name)
			return nil unless @cmd_dict.include?(name)
			@cmd_dict[name]
		end
	end
	
	# コマンドクラス
	#
	class Command
		# コンストラクタ
		#
		def initialize(name, proc = nil, desc = nil, usage = nil)
			@name  = name					# コマンド名
			@proc  = proc					# コマンドの処理 lambda{|argv| ...}
			@desc  = desc  || ''  # コマンドの説明
			@usage = usage || ''	# コマンドの書式
		end
		
		# メンバ参照
		attr_reader(:name, :proc, :desc, :usage)
		
		# コマンド名の比較
		#
		def ==(cmd)
			(cmd.name == @name)
		end
		
		# コマンドの実行
		# @param param	[String[]]	コマンド引数。0番目は自身のコマンド名
		def exec(param)
			param ||= []
			if String === param then
				param = param.split(' ')
			end
			
			return @proc.nil? ? @name : @proc.call(param)
		end
	end
end

# Test
if $0 == __FILE__ then
	class TestShell < ShellBase
		def initialize
			super
			
			CommandDict.add('echo', lambda{|argv| argv.each {|arg| print "#{arg} "}; puts},
			                        'echo command line')
		end
	end
	
	shell = TestShell.new
	cmd = ShellBase::Command.new('test', lambda{|argv| puts 'Test'}, 'test command')
	shell.add_command(cmd)
	shell.interaction
end