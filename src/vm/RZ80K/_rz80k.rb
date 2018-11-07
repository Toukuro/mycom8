require "../memory/memory"
# require "../memory/bankedmemory"
# require "../memory/pagedmemory"
require "../io/chrvram"
require "../cpu/rz80cpu"
require "./escseq"

# 疑似 MZ-80K　（VM版に移行のため破棄予定）
class Rz80K
    def initialize
        # フラット 64KB RAM
        @ram     = Memory.new(16)
        
        # バンク式 256KB RAM (4Page * 4Bank)
        #page_conf = [{BankedMemory => [2]}] * 4
        #@ram       = PagedMemory.new(16, 2, page_conf)

        # I/Oのマッピング
        #@mnrom = Rz80MonitorROM.new
        @cvram = CharacterVRAM.new
        #@iomem = Rz80IO.new

        #@ram.bind_io(@mnrom, 0x0000)
        #@ram.bind_io(cvram, 0xC000)
        @ram.bind_io(@cvram, 0xD000)
        #@ram.bind_io(@iomem, 0xE000)

        @cpu = Rz80CPU.new(@ram)

        @cvram.refresh
        @cvram.scroll_up
        @cvram.scroll_up
    end

    def power_on()
      @cpu.run
    end

    def power_off()
      @cpu.stop
    end

    def reset()
      @cpu.run
    end

    def tape_play()
    end

    def tape_rec()
    end
end

if $0 == __FILE__ then
  @rz = Rz80K.new
end