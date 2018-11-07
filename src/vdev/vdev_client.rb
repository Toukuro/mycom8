require "socket"

# 仮想デバイスクライアント
class VdevClient

  PORT_NO = 16800
  
  #
  def initialize(port_no = PORT_NO)
    @port_no = port_no
    @tcp_cl = nil
    @recv_th = nil
  end

  #
  def start_server()
    # system('start ../vdev/vdevsv.bat')
    system('start ruby ../vdev/vdev_server.rb')
  end
  
  #
  def connect()
    @tcp_cl = TCPSocket.open("localhost", @port_no)
  end

  #
  def disconnect()
    return if @tcp_cl.nil?
    @tcp_cl.close
    @tcp_cl = nil
  end

  #
  def start_receive()
    @recv_th = Thread.start(@tcp_cl) {|tcp|
      while buff = tcp.gets
        buff.chomp!
        received(buff)
      end 
    }
  end 

  #
  def receive_data(data)
    puts data
  end

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
