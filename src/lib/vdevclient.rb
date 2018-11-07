require "socket"

# 仮想デバイスクライアント
class VdevClient

  PORT_NO = 16800
  
  # コンストラクタ
  def initialize(port_no = PORT_NO)
    @port_no = port_no
    @tcp_cl = nil
    @recv_th = nil
  end

  # 仮想デバイスサーバを起動する
  def start_server(path = nil)
    path = "vdevserver.rb" if path.nil?
    path = File.absolute_path(path)
    puts "starting vdevserver at [#{path}]"
    # system('start ../vdev/vdevsv.bat')
    #system("start ruby -I #{VMROOT_PATH} #{path}")
    system("start #{path}")
  end
  
  # 仮想デバイスサーバに接続する
  def connect()
    @tcp_cl = TCPSocket.open("localhost", @port_no)
  end

  # 仮想デバイスサーバから接続解除する
  def disconnect()
    return if @tcp_cl.nil?
    @tcp_cl.close
    @tcp_cl = nil
  end

  # 受信スレッド開始
  def start_receive()
    @recv_th = Thread.start(@tcp_cl) {|tcp|
      while buff = tcp.gets
        buff.chomp!
        receive_data(buff)
      end 
    }
  end 

  # データ受信
  def receive_data(data)
    puts data
  end

  # データ送信
  def send_data(data)
    @tcp_cl.puts data
  end 
end

if $0 == __FILE__ then
  begin
    vcl = VdevClient.new
    vcl.start_server
    sleep 2
    
    vcl.connect
    vcl.start_receive  
    
    while true
      print 'VCL> '
      buff = gets.chomp!
      vcl.send(buff)
      break if buff == 'END'
    end
  
    vcl.disconnect
  
  #rescue => exception
      
  end
end
