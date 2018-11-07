require "lib/vmbase"
require "lib/vdevclient"
require "cpu/rz80/rz80cpu"
require "memory/linearmemory"
require "vm/RZ80K/RZ80MonitorROM"
require "vm/RZ80K/msgtestrom"
require "vm/RZ80K/chrvram"
require "vm/RZ80K/rz80kio"

# 仮想マシン RZ-80K
class RZ80K < VMBase

  def initialize
    super

    # フラット 64KB RAM
    @mem = LinearMemory.new(Word, Byte)

    # バンク式 256KB RAM (4Page * 4Bank)
    #page_conf = [{BankedMemory => [2]}] * 4
    #@mem       = PagedMemory.new(16, 2, page_conf)

    # 仮想デバイスの準備
    @vdev = VdevClient.new

    # I/Oのマッピング
    #   モニターROM
    monitor = RZ80MonitorROM.new
    @mem.bind_io(monitor, 0x0000)
    #testRom = MsgTestROM.new
    #@mem.bind_io(testRom, 0x1000)

    #   BASIC ROM（ぇ!?）
    #basic = KmBasicROM.new
    #@mem.bind_id(basic, 0x1200)
    
    #   ディスプレイVRAM
    vram = CharacterVRAM.new(@vdev)
    @mem.bind_io(vram, 0xD000)

    #   ppi8255
    ppi = Rz80KIO.new
    @mem.bind_io(ppi, 0xE000)
    
    # CPUの設定
    @cpu = Rz80CPU.new(@mem)
  end 

  def start()
    @vdev.start_server("#{VM_PATH}/RZ80K/RZ80Console.bat")
    @vdev.connect
    @vdev.start_receive

  end
  
  def stop()
    if @is_started then
      @vdev.send_data("END")
      @vdev.disconnect
      end 
  end 
end