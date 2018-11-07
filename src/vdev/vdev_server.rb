require "socket"
require "../lib/escseq"
require "io/console"

# 仮想デバイスサーバ
class VdevServer
    
  PORT_NO = 16800

  #
  def initialize(port_no = PORT_NO)
    @port_no = port_no
    @tcp_sv  = nil
    @tcp_cl  = nil
    @send_th = nil
  end

  #
  def start()
    @tcp_sv = TCPServer.open(@port_no)
        
    @tcp_cl = @tcp_sv.accept
    
    @send_th = Thread.start(@tcp_cl) {|tcp| send_loop(tcp)}
    receive_loop(@tcp_cl)
    
    @tcp_cl.close
        
    @tcp_sv.close
    @tcp_sv = nil
  end     
  
  #
  def receive_loop(tcp)
    $stdout.set_encoding("CP932")
    
    puts "--- start receive_loop"
    while buff = tcp.gets
      buff.chomp!
      fields = buff.split

      case fields[0]
      when 'END'
        break
      when 'CLEAR'
        mode = EscSeq::MODE_ALL
        EscSeq.clear_screen(mode)
      when 'LOCATE'   # LOCATE row col str
        EscSeq.move_pos(fields[1], fields[2], fields[3])
      when 'UP'       # UP cnt str
        EscSeq.move_up(fields[1], fields[2])
      when 'DOWN'     # DOWN cnt str
        EscSeq.move_down(fields[1], fields[2])
      when 'LEFT'     # LEFT cnt str
        EscSeq.move_left(fields[1], fields[2])
      when 'RIGHT'    # RIGHT cnt str
        EscSeq.move_right(fields[1], fields[2])
      when 'ABOVE'    # ABOVE cnt str
        EscSeq.move_above(fields[1], fields[2])
      when 'BELLOW'   # BELLOW cnt str
        EscSeq.move_bellow(fields[1], fields[2])
      when 'SPACE'
        cnt = fields[1].to_i
        print ' ' * cnt
      else
        print buff
      end
    end
  end
  
  #
  def send_loop(tcp)
    puts "--- start send_loop"
    # リアルタイムキー入力
    while buff = $stdin.getch
      code = ''
      buff.bytes.each {|c| code += sprintf("%02X", c)}
      
      tcp.puts "KEY #{code}"
    end
  end
  
end

# Test
if $0 == __FILE__ then
  begin
    EscSeq.clear_screen(EscSeq::MODE_ALL)
    
    vsv = VdevServer.new
    vsv.start
    
  # rescue => exception
      
  end
end
