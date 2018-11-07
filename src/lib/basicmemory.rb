require "../lib/memorybase"

# 基本メモリクラス
class BasicMemory < MemoryBase
	
	# 指定したアドレスからファイルの内容をロードする
	# @param	addr	[Binary]
	# @param	fname	[String]
	def load(addr, fname)
    addr = @addr_type.new(addr)
    size = 0
    
    begin
      File.open(fname, "rb") {|f|
        until f.eof?
          self[addr] = @data_type.new(f.readbyte)
          break if addr == @addr_type.max_value
          addr += 1
          size += 1
        end
      }
    rescue Errno::ENOENT => ex
      puts "can't open file. [#{fname}]"
    end
    return size
	end 
	
	# 指定したアドレスから指定サイズに内容をファイルにセーブする
	# @param	addr	[Binary]
	# @param	size	[Integer]
	# @param	fname	[String]
	def save(addr, size, fname)
    addr = @addr_type.new(addr)
    File.open(fname, "wb") {|f|
      while (size > 0)
        f.write self[addr].chr
        addr += 1
        size -= 1
      end
    }
	end 
	
	# 指定したアドレスから指定サイズの内容をダンプ表示する
	# @param	addr	[Binary]
	# @param	size	[Integer]
	def dump(addr, size = 256)
    addr = @addr_type.new(addr)
    
    dmp_str = asc_str = ""
    0.upto(size - 1) {|offset|
      if offset % 16 == 0 then
        puts "#{dmp_str}[#{asc_str}]\n" unless dmp_str.empty?
        dmp_str = sprintf("%04X  ", addr + offset)
        asc_str = ""
      elsif offset % 8 == 0 then
        dmp_str << " "
        asc_str << " "
      end
      
      data = self[addr + offset]
      # puts "data = #{data}"
      dmp_str << sprintf("%02X ", data.to_ui)
      if (0x20..0x7E).include?(data) then
        asc_str << data.chr
      else
        asc_str << "."
      end
    }
    puts "#{dmp_str}[#{asc_str}]\n" unless dmp_str.empty?
	end 

	# 指定したアドレスから値を書き込む
	# @param	addr	[Binary]
	# @param	data	[Binary]
	def change(addr, data)
		puts "'write' is not supported."
	end 
	
	# 指定したページのバンクを表示する
	def get_bank(page)
		puts "'getbank' is not supported."
	end 
	
	# 指定したページのバンクを変更する
	def set_bank(page, bank)
		puts "'setbank' is not supported."
	end 

end

# Test
if $0 == __FILE__ then
end