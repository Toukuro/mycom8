# wincons.rb  for windows   TEXCELL
# '16.08 Ver.2.31 '05.03 Ver.1.0
require 'fiddle/import'

STD_INPUT_HANDLE = -10
STD_OUTPUT_HANDLE = -11
BLACK = 0
BLUE = 1
RED = 4
PURPLE = 5
GREEN = 2
AQUA = 3
YELLOW = 6
WHITE = 7
INTENSITY = 8

CP_ACP = 0
CP_UTF8 = 65001

ENABLE_PROCESSED_INPUT = 0x0001
ENABLE_LINE_INPUT = 0x0002
ENABLE_ECHO_INPUT = 0x0004
ENABLE_WINDOW_INPUT = 0x0008
ENABLE_MOUSE_INPUT = 0x0010

FROM_LEFT_1ST_BUTTON_PRESSED = 0x0001
FROM_LEFT_2ND_BUTTON_PRESSED = 0x0004
FROM_LEFT_3RD_BUTTON_PRESSED = 0x0008
FROM_LEFT_4TH_BUTTON_PRESSED = 0x0010
RIGHTMOST_BUTTON_PRESSED = 0x0002

CAPSLOCK_ON = 0x0080
ENHANCED_KEY = 0x0100
LEFT_ALT_PRESSED = 0x0002
LEFT_CTRL_PRESSED = 0x0008
NUMLOCK_ON = 0x0020
RIGHT_ALT_PRESSED = 0x0001
RIGHT_CTRL_PRESSED = 0x0004
SCROLLLOCK_ON = 0x0040
SHIFT_PRESSED = 0x0010

DOUBLE_CLICK = 0x0002
MOUSE_HWHEELED = 0x0008
MOUSE_MOVED = 0x0001
MOUSE_WHEELED = 0x0004

SW_HIDE = 0
SW_SHOWNORMAL = 1
SW_NORMAL = 1
SW_SHOWMINIMIZED = 2
SW_SHOWMAXIMIZED = 3
SW_MAXIMIZE = 3
SW_SHOWNOACTIVATE = 4
SW_SHOW = 5
SW_MINIMIZE = 6
SW_SHOWMINNOACTIVE = 7
SW_SHOWNA = 8
SW_RESTORE = 9
SW_SHOWDEFAULT = 10
SW_FORCEMINIMIZE = 1
SW_MAX = 11

PS_SOLID = 0
PS_DASH = 1
PS_DOT = 2
PS_DASHDOT = 3
PS_DASHDOTDOT = 4
PS_NULL = 5
PS_INSIDEFRAME = 6

TRANSPARENT = 1
OPAQUE = 2

module MCKernel32
   extend Fiddle::Importer
   dlload "kernel32"
   typealias("WORD", "unsigned short")
   typealias("DWORD", "unsigned int")
   typealias("BOOL", "int")
   typealias("WCHAR", "unsigned short")
   typealias("SHORT", "short")
   typealias("UINT", "unsigned int")
   KEYEVENTRECORD = struct(
      ["WORD eventType",
       "BOOL bKeyDown",
       "WORD wRepeatCount",
       "WORD wVirtualKeyCode",
       "WORD wVirtualScanCode",
       "char AsChar1",
       "char AsChar2",
       "DWORD dwControlKeyState"]
   )
   MOUSEEVENTRECORD = struct(
      ["WORD  eventType",
       "DWORD iMousePos",
       "DWORD dwButtonState",
       "DWORD dwControlKeyState",
       "DWORD dwEventFlags"]
   )
   CONSOLESCREENBUFFERINFO = struct(
      ["SHORT dwSizeX",
       "SHORT dwSizeY",
       "SHORT dwCursorPositionX",
       "SHORT dwCursorPositionY",
       "WORD  wAttributes",
       "SHORT srWinLeft",
       "SHORT srWinTop",
       "SHORT srWinRight",
       "SHORT srWinBottom",
       "SHORT dwMaximumWindowSizeX",
       "SHORT dwMaximumWindowSizeY"]
   )
   CONSOLECURSORINFO = struct(
      ["DWORD dwSize",
       "BOOL bVisible"]
   )
   extern "int MultiByteToWideChar(unsigned int,DWORD,char*,int,char*,int)",:stdcall
   extern "int WideCharToMultiByte(unsigned int,DWORD,char*,int,char*,int,char*,char*)",:stdcall
   extern "int GetStdHandle(DWORD)",:stdcall
   extern "BOOL GetConsoleMode(int,void*)",:stdcall
   extern "BOOL SetConsoleMode(int,DWORD)",:stdcall
   extern "BOOL WriteConsoleW(int,char*,DWORD,int*,void*)",:stdcall
   extern "BOOL PeekConsoleInputW(int,void*,DWORD,int*)",:stdcall
   extern "BOOL ReadConsoleInputW(int,void*,DWORD,int*)",:stdcall
   extern "BOOL SetConsoleTextAttribute(int,WORD)",:stdcall
   extern "BOOL SetConsoleCursorPosition(int,unsigned int)",:stdcall
   extern "BOOL GetConsoleScreenBufferInfo(int,void*)",:stdcall
   extern "BOOL FillConsoleOutputCharacterW(int,WORD,DWORD,int,int*)",:stdcall
   extern "BOOL FillConsoleOutputAttribute(int,WORD,DWORD,int,int*)",:stdcall
   extern "BOOL SetConsoleScreenBufferSize(int,int)",:stdcall
   extern "BOOL SetConsoleWindowInfo(int,BOOL,void*)",:stdcall
   extern "BOOL ReadConsoleW(int,void*,DWORD,void*,void*)",:stdcall
   extern "DWORD GetConsoleTitleW(void*,DWORD)",:stdcall
   extern "BOOL SetConsoleTitleW(void*)",:stdcall
   extern "BOOL GetConsoleCursorInfo(int,void*)",:stdcall
   extern "BOOL SetConsoleCursorInfo(int,void*)",:stdcall
   extern "BOOL Beep(DWORD,DWORD)",:stdcall
end

module MCUser32
   extend Fiddle::Importer
   dlload "user32"
   typealias("BOOL", "int")
   extern "int FindWindow(void*,void*)",:stdcall
   extern "BOOL ShowWindow(int,int)",:stdcall
   extern "int GetDC(int)",:stdcall
   extern "int ReleaseDC(int,int)",:stdcall
end

module MCGdi32
   extend Fiddle::Importer
   dlload "gdi32"
   typealias("DWORD", "unsigned int")
   typealias("BOOL", "int")
   extern "int CreatePen(int,int,DWORD)",:stdcall
   extern "int CreateSolidBrush(int)",:stdcall
   extern "int SelectObject(int, int)",:stdcall
   extern "BOOL DeleteObject(int)",:stdcall
   extern "BOOL MoveToEx(int, int, int, void*)",:stdcall
   extern "BOOL LineTo(int, int, int)",:stdcall
   extern "BOOL Rectangle(int, int, int, int, int)",:stdcall
   extern "BOOL Ellipse(int, int, int, int, int)",:stdcall
   extern "int SetTextColor(int, int)",:stdcall
   extern "int SetBkColor(int, int)",:stdcall
   extern "int SetBkMode(int, int)",:stdcall
   extern "BOOL TextOutW(int, int, int, void*, int)",:stdcall
end

class Console

   def initialize(ccode)

      @imcode = -1
      sa = ccode.to_s.upcase
      if sa == "SHIFT_JIS" || sa == "WINDOWS-31J"
         @imcode = CP_ACP
      elsif sa == "UTF-8"
         @imcode = CP_UTF8
      end
      if @imcode != -1
         @nofread = "\0" * 4;
         @ihtw = MCKernel32.GetStdHandle(STD_OUTPUT_HANDLE)
         @ihtr = MCKernel32.GetStdHandle(STD_INPUT_HANDLE)
         @ikeyrec = MCKernel32::KEYEVENTRECORD.malloc
         @imouserec = MCKernel32::MOUSEEVENTRECORD.malloc
         @cr = nil
         @ikcode = 0
         @ikstate = 0
         @imusx = nil
         @imusy = nil
         @imusButton = 0
         @imusCtrlKey = 0
         @imusEvnt = 0
         @backcolor = 0
         sct = nil
         while true
            sct = getConsoleTitle
            if sct != nil
               break
            end
         end
         szt = "wincons" + Time.now.nsec.to_s
         setConsoleTitle(szt)
         sleep 0.05
         @hConWndHndl = MCUser32.FindWindow(nil,szt)
         setConsoleTitle(sct)
         @grptini = false
      else
         print "ENCODING error\r\n"
      end
    end

   def getConsoleMode

      md = "\0" * 4
      bi = MCKernel32.GetConsoleMode(@ihtr,md)
      imode = md.unpack("I")[0]
      return imode
   end

   def mouseMode(imsmd)

      im = getConsoleMode
      if imsmd == 0
         im &= ~ENABLE_MOUSE_INPUT
      else
         im |= ENABLE_MOUSE_INPUT
      end
      MCKernel32.SetConsoleMode(@ihtr,im)
   end

   def showWindow(ish)

      ba = MCUser32.ShowWindow(@hConWndHndl,ish)
      return ba
   end

   def cls

      cosolesbuffer = MCKernel32::CONSOLESCREENBUFFERINFO.malloc
      bi = MCKernel32.GetConsoleScreenBufferInfo(@ihtw,cosolesbuffer)
      if bi != 0
         nlen = cosolesbuffer.dwSizeX * cosolesbuffer.dwSizeY
         wcoord = 0
         lnw = "\0" * 4
         ch = 0x3000
         watt = WHITE
         bi = MCKernel32.FillConsoleOutputCharacterW(@ihtw,ch,nlen,wcoord,lnw)
         if bi != 0
            bi = MCKernel32.FillConsoleOutputAttribute(@ihtw,watt,nlen,wcoord,lnw)
         end
      end
      return bi
   end

   def screen(width,height)

      slect = [0,0,width,height].pack("S*")
      wco = [width + 1,height + 1].pack("SS")
      iwcoord = wco.unpack("I")[0]
      bi = MCKernel32.SetConsoleScreenBufferSize(@ihtw,iwcoord)
      if bi != 0
         bi = MCKernel32.SetConsoleWindowInfo(@ihtw,1,slect)
      end
      return bi
   end

   def getCursorInfo

      curInfo = MCKernel32::CONSOLECURSORINFO.malloc
      bi = MCKernel32::GetConsoleCursorInfo(@ihtw,curInfo)
      if bi != 0
         return curInfo.dwSize, curInfo.bVisible
      end
      return nil,nil
   end

   def setCursorInfo(size,visible)

      curInfo = MCKernel32::CONSOLECURSORINFO.malloc
      curInfo.dwSize = size
      curInfo.bVisible = visible
      bi = MCKernel32::SetConsoleCursorInfo(@ihtw,curInfo)
      return bi
   end

   def getConsoleTitle

      sr = nil
      ibsize = 512
      lpbuf = "\x0" * ibsize
      ilen = MCKernel32.GetConsoleTitleW(lpbuf,ibsize)
      if ilen > 0
         il = MCKernel32.WideCharToMultiByte(@imcode,0,lpbuf,-1,nil,0,nil,nil)
         if il > 0
            sds = "\0" * il
            bi = MCKernel32.WideCharToMultiByte(@imcode,0,lpbuf,-1,sds,il,nil,nil)
            sr = sds[0,il]
         end
      end
      return sr
   end

   def setConsoleTitle(stitle)

      if @imcode == -1
         return -1
      end
      bi = 0
      isl = stitle.bytesize
      idl = isl * 2 + 1
      sds = "\0" * idl
      il = MCKernel32.MultiByteToWideChar(@imcode,0,stitle,isl,sds,idl)
      bi = MCKernel32.SetConsoleTitleW(sds)
      return bi   
   end

   def locate(x,y)

      wcoord = (y << 16) + x
      bi = MCKernel32.SetConsoleCursorPosition(@ihtw,wcoord);
      return bi
   end

   def color(fcolor,bcolor = -1)

      if bcolor == -1
          bcolor = @backcolor
      else
          @backcolor = bcolor
      end
      acolor = (bcolor << 4) + fcolor
      bi = MCKernel32.SetConsoleTextAttribute(@ihtw,acolor)
      return bi
   end

   def beep(ifreq,iduration)

      bi = MCKernel32.Beep(ifreq,iduration);
      return bi
   end

   def cprint(cmes)

      if @imcode == -1
         return -1
      end
      bi = 0
      isl = cmes.bytesize
      idl = isl * 2 + 1
      sds = "\0" * idl
      il = MCKernel32.MultiByteToWideChar(@imcode,0,cmes,isl,sds,idl)
      bi = MCKernel32.WriteConsoleW(@ihtw,sds,il,@nofread,nil)
      return bi
   end

   def keyinput

      cr = ""
      lpbuf = "\x0" * 256
      wnread = [0].pack("I")
      bi = MCKernel32.ReadConsoleW(@ihtr,lpbuf,128,wnread,0)
      irlen = wnread.unpack("I")[0]
      irlen -= 2
      il = MCKernel32.WideCharToMultiByte(@imcode,0,lpbuf,-1,nil,0,nil,nil)
      if il > 0
         il -= 1
         sds = "\0" * il
         bi = MCKernel32.WideCharToMultiByte(@imcode,0,lpbuf,-1,sds,il,nil,nil)
         cr = sds[0,il - 2]
      else
         bi = 0
      end
      return cr
   end

   def inputRec

      @ikeyrec.eventType = 0
      @nofread = "\0" * 4
      bi = MCKernel32.PeekConsoleInputW(@ihtr,@ikeyrec,1,@nofread)
      if @imcode >= 0 && bi != 0
         inlen = @nofread.unpack("I")
         if inlen[0] != 0
            if @ikeyrec.eventType == 1
               bi = MCKernel32.ReadConsoleInputW(@ihtr,@ikeyrec,1,@nofread)
               if bi != 0
                  if @ikeyrec.eventType == 1 && @ikeyrec.bKeyDown == 1
                     if @ikeyrec.AsChar2 == 0
                        @cr = "\0"
                        cptr = Fiddle::Pointer[@cr]
                        cptr[0] = @ikeyrec.AsChar1
                     else
                        cw = "\0" * 2
                        cptr = Fiddle::Pointer[cw]
                        cptr[0] = @ikeyrec.AsChar1
                        cptr[1] = @ikeyrec.AsChar2
                        il = MCKernel32.WideCharToMultiByte(@imcode,0,cw,-1,nil,0,nil,nil)
                        if il > 0
                           sds = "\0" * (il - 1)
                           bi = MCKernel32.WideCharToMultiByte(@imcode,0,cw,-1,sds,4,nil,nil)
                           @cr = sds
                        else
                           bi = 0
                        end
                     end
                     @ikcode = @ikeyrec.wVirtualKeyCode
                     @ikstate = @ikeyrec.dwControlKeyState
                  end
               end
            elsif @ikeyrec.eventType == 2
               bi = MCKernel32.ReadConsoleInputW(@ihtr,@imouserec,1,@nofread)
               if bi != 0
                  @imusx = @imouserec.iMousePos & 0xff
                  @imusy = @imouserec.iMousePos >> 16
                  @imusButton = @imouserec.dwButtonState
                  @imusCtrlKey = @imouserec.dwControlKeyState
                  @imusEvnt = @imouserec.dwEventFlags
               end
            else
               bi = MCKernel32.ReadConsoleInputW(@ihtr,@ikeyrec,1,@nofread)
            end
         end
      end
      return bi
   end
   private :inputRec

   def inkey

      bi = -1
      if @cr == nil
         bi = inputRec
      end
      crr = @cr; ikcoder = @ikcode; ikstater = @ikstate
      @cr = nil; @ikcode = 0; @ikstate = 0
      return crr,ikcoder,ikstater,bi
   end

   def mouse

      bi = -1
      if @imusx == nil || @imusy == nil
         bi = inputRec
      end
      imusxr = @imusx; imusyr = @imusy; imusButtonr = @imusButton
      imusCtrlKeyr = @imusCtrlKey; imusEvntr = @imusEvnt
      @imusx = nil; @imusy = nil; @imusButton = 0
      @imusCtrlKey = 0; @imusEvnt = 0
      return imusxr, imusyr, imusButtonr, imusCtrlKeyr, imusEvntr, bi
   end

   def gOpen

      @dhdc = MCUser32.GetDC(@hConWndHndl)
      hNPen = MCGdi32.CreatePen(PS_SOLID, 1, 0xffffff)
      @hoPen = MCGdi32.SelectObject(@dhdc, hNPen)
      hBrush = MCGdi32.CreateSolidBrush(0xffffff)
      @hoBrush = MCGdi32.SelectObject(@dhdc, hBrush)
      @cfcol = 0
      @cbcol = gRGB(0xff,0xff,0xff)
      @cbkmd = OPAQUE
      @grptini = true
   end

   def gClose

      hPen = MCGdi32.SelectObject(@dhdc, @hoPen)
      MCGdi32.DeleteObject(hPen)
      hBrush = MCGdi32.SelectObject(@dhdc, @hoBrush)
      MCGdi32.DeleteObject(hBrush)
      MCUser32.ReleaseDC(@hConWndHndl, @dhdc)
      @grptini = false
   end

   def gRGB(ired, igreen, iblue)

      ir = ((iblue & 0xff) << 16) | ((igreen & 0xff) << 8) | (ired & 0xff)
      return ir
   end

   def gPen(ipStyle, iWidth, iColor)

      if @grptini == false; return; end
      hNPen = MCGdi32.CreatePen(ipStyle, iWidth, iColor)
      hPen = MCGdi32.SelectObject(@dhdc, hNPen)
      MCGdi32.DeleteObject(hPen)
   end

   def gBrush(iColor)

      if @grptini == false; return; end
      hnBrush = MCGdi32.CreateSolidBrush(iColor)
      hBrush = MCGdi32.SelectObject(@dhdc, hnBrush)
      MCGdi32.DeleteObject(hBrush)
   end

   def Line(ix1,iy1,ix2,iy2)

      if @grptini == false; return 0; end
      ba = MCGdi32.MoveToEx(@dhdc, ix1, iy1, nil)
      if ba != 0
         ba = MCGdi32.LineTo(@dhdc, ix2, iy2)
      end
      return ba
   end

   def Rectangle(ix1,iy1,ix2,iy2)

      if @grptini == false; return 0; end
      ba = MCGdi32.Rectangle(@dhdc,ix1,iy1,ix2,iy2)
      return ba
   end

   def Ellipse(ix1,iy1,ix2,iy2)

      if @grptini == false; return 0; end
      ba = MCGdi32.Ellipse(@dhdc,ix1,iy1,ix2,iy2)
      return ba
   end

   def SetTextColor(iColor)

      if iColor < 0 || iColor > 0xffffff
         return 0
      end
      @cfcol = iColor
      return 1
   end

   def SetBkColor(iColor)

      if iColor < 0 || iColor > 0xffffff
         return 0
      end
      @cbcol = iColor
      return 1
   end

   def SetBkMode(ibkmode)

      if ibkmode != TRANSPARENT && ibkmode != OPAQUE
         return 0
      end
      @cbkmd = ibkmode
      return 1
   end

   def TextOut(ix, iy, smes)

      if @imcode == -1
         return -1
      end
      isl = smes.bytesize
      idl = isl * 2 + 1
      sds = "\0" * idl
      il = MCKernel32.MultiByteToWideChar(@imcode,0,smes,isl,sds,idl)
      dhdc0 = MCUser32.GetDC(@hConWndHndl)
      MCGdi32.SetTextColor(dhdc0,@cfcol)
      MCGdi32.SetBkColor(dhdc0,@cbcol)
      MCGdi32.SetBkMode(dhdc0,@cbkmd)
      bi = MCGdi32.TextOutW(dhdc0,ix,iy,sds,il)
      MCUser32.ReleaseDC(@hConWndHndl, dhdc0)
      return bi
   end

   attr_reader :hConWndHndl

end
