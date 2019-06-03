require "socket"

# VDCPクライアント
class VdcpClient

  DFLT_PORT_NO = 28068

  #
  def initialize(port_no = DFLT_PORT_NO)
    @port_no = port_no
    @tcp_cl  = nil
    @recv_th = nil
  end

  #
  def connect()
    @tcp_cl = TCPSocket.open("localhost", @port_no)
  end

  def disconnect()
    return if @tcp_cl.nil?
    @tcp_cl.close
    @tcp_cl = nil
  end

  def device_read_request(dev_class, dev_id, addr)
    buff = sprintf("DR%02X%02X%04X", dev_class, dev_id, addr)
    @tcp_cl.puts buff

    buff = @tcp_cl.gets.chomp
    rcv_class = buff[2]
    rcv_id    = buff[3]
    rcv_addr  = buff[4,4]
    rcv_data  = buff[8,2]
    return Byte.new(rcv_data.hex)
  end

  def device_write_request(dev_class, dev_id, addr, data)
    buff = sprintf("DW%02X%02X%04X0X02", dev_class, dev_id, addr, data)
    @tcp_cl.puts buff

    buff = @tcp_cl.gets.chomp
    rcv_class = buff[2]
    rcv_id    = buff[3]
    rcv_addr  = buff[4,4]
    rcv_data  = buff[8,2]
  end

  def control_request(cmd)
    buff = sprintf("DR%02X%02X%04X", dev_class, dev_id, addr)
    @tcp_cl.puts buff

    buff = @tcp_cl.gets.chomp
    rcv_class = buff[2]
    rcv_id    = buff[3]
    response  = buff.substr(4)
    return response
  end

  # control response
  .Append("D-")
  .Append(_DevClass.ToString("X2"))
  .Append(_DevId.ToString("X2"))
  .Append(iData)
  .AppendLine()

  # device response
  .Append("D-")
  .Append(_DevClass.ToString("X2"))
  .Append(_DevId.ToString("X2"))
  .Append(iAddr.ToString("X4"))
  .Append(iData.ToString("X2"))
  .AppendLine()

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
