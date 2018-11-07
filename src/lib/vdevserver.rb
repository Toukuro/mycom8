require "socket"

# 仮想デバイスサーバ
class VdevServer
    
  PORT_NO = 16800

  # コンストラクタ
  # @param port_no  [Fixnum]  待ちうけポート番号
  def initialize(port_no = PORT_NO)
    @port_no = port_no
    @tcp_sv  = nil
    @tcp_cl  = nil
    @send_th = nil
  end

  # サーバスタート
  def start()
    @tcp_sv = TCPServer.open(@port_no)        
    @tcp_cl = @tcp_sv.accept

    # 送信系スレッドの起動
    @send_th = Thread.start(@tcp_cl) {|tcp| send_loop(tcp)}

    # 受信系ループ
    receive_loop(@tcp_cl)
    
    # セッション切断
    self.close()
  end     
  
  def close()
    @tcp_cl.close
    @tcp_sv.close
    @tcp_sv = nil
  end

  # 受信系ループ
  # @param tcp [TcpSocket]
  def receive_loop(tcp)
    puts "vdevserver: receive_loop start."
    # データ受信
    while buff = tcp.gets
      buff.chomp!
      is_exit = receive_data(buff)
      break if is_exit
    end
    puts "vdevserver: receive_loop exited."
  end
  
  # 送信系スレッドループ
  # @param tcp [TcpSocket]
  def send_loop(tcp)
    while true
      buff = send_data()
      break if buff.nil?

      # データ送信
      tcp.puts buff
    end 
  end

  # 受信データ処理（派生クラスにて実装）
  # @param buff [String]  受信データ
  # @return [void]
  def receive_data(buff)
    return true
  end 

  # 送信データ取得（派生クラスにて実装）
  # @return [String]  送信データ。nil返却で処理終了
  def send_data()
    return nil
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
