# I/Oアクセス基本仕様Mix-in モジュール
module IOAccess

  # I/Oデバイスをメモリの任意のアドレスに割り当てる。
  # @param dev      [Device]  I/Oデバイス
  # @param addr     [Binary]  メモリアドレス
  # @param bank_no  [Integer] メモリバンクNo.（現在は未使用）  
  def bind_io(dev, addr, bank_no = 0)
    # I/O管理用テーブルの確認（定義されていなければ初期化）
    #unless instance_variable_defined?(:io_arry)
      @dev_arry = [] if @dev_arry.nil?
    #end

    # bind_maskとbind_addrの算出
    #   bind_mask は、I/Oが割り当てられているアドレスを算出するための
    #   ビットマスク。
    #   アドレスビット幅のうち、I/Oビット幅を除いた上位が全て1であるもの。
    #   たとえば、アドレスビット幅が16bitでI/Oビット幅が8bitの場合、
    #   bind_mask は、0xFF00となる。
    addr = @addr_type.new(addr)
    addr_bits = dev.addr_bits
    bind_mask = addr.class.mask << addr_bits
    bind_addr = addr & bind_mask

    @dev_arry << {dev => [bind_mask, bind_addr, bank_no]}  
  end

  # 指定アドレスに割り当てられているI/Oデバイスを取得
  # @param addr [Binary]  メモリアドレス
  # @return [Device] 割り当てられているI/Oデバイス。なければnil。
  # @note もし、同一アドレスに重複するデバイスがあった場合は、
  #       先に登録した方を返す。
  def get_iodevice(addr, bank_no = 0)
    @dev_arry.each {|io_bind|
      io_bind.each {|dev, bind_info|
        bmask = bind_info[0]    # [Binary]  バインドマスク
        baddr = bind_info[1]    # [Binary]  バインドアドレス
        bno   = bind_info[2]    # [Integer] バンクNo
        return dev if (addr & bmask) == baddr && bno == bank_no
      }
    }
    return nil
  end
end