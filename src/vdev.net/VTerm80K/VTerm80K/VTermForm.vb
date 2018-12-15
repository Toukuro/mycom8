Imports PXCommon
Imports VDCP
Imports System.Threading
Imports System.IO

Public Class VTermForm

#Region "定数定義"

    Private Const SCREEN_WIDTH As Integer = 40
    Private Const SCREEN_HEIGHT As Integer = 25
    Private Const FONT_WIDTH As Integer = 16
    Private Const FONT_HEIGHT As Integer = 16

    Private Const KBDIO_SIZE As Integer = 10

#End Region

#Region "メンバー変数"

#Region "VDCPサーバ関連"

    Private WithEvents _vdcpServer As VdcpServer

#End Region

#Region "キーボード制御関連"

    Private _KeyMap As New Hashtable        'KeyCode→Buttonの変換用
    Private _KeyMapShift As New Hashtable
    Private _PressedShiftKey As Button = Nothing
    Private _KanaKey As Button = Nothing

    ''' <summary>キーの押下状態を示すデータ</summary>
    Private _KeyIOMem(KBDIO_SIZE) As Byte

#End Region

#Region "ディスプレイ制御関連"

    Private _VramMem(SCREEN_WIDTH * SCREEN_HEIGHT) As Byte
    Private _ScreenImage As Bitmap
    Private _FontBitmap As Bitmap
    Private _testVramAddr As UShort = 0
    Private _testCode As Byte = 0

#End Region

    Private _logger As Logger.FormatLogger
    Private _lockObj As New Object

#End Region

#Region "フォームイベント"

    Private Sub VTermForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        _logger = New Logger.FormatLogger(New Logger.FileLogAccessor(Me.GetType.Name))
        InitKeyMap()
        SetKeyButtonEvent()
    End Sub

    Private Sub VTermForm_Shown(sender As Object, e As EventArgs) Handles Me.Shown

        _FontBitmap = New Bitmap(My.Resources.MZ80Font, 256, 256)
        Dim gfx As Graphics = pnlDisplay.CreateGraphics
        _ScreenImage = New Bitmap(640, 400, gfx)
        pnlDisplay.DrawToBitmap(_ScreenImage, New Rectangle(0, 0, 640, 400))

        _vdcpServer = New VdcpServer()
        _vdcpServer.StartListen()
        _vdcpServer.AsyncRead()
    End Sub

    Private Sub VTermForm_KeyUp(sender As Object, e As KeyEventArgs) Handles Me.KeyUp
        If _KeyMap.Contains(e.KeyCode) Then
            Dim btnKey As Button = _KeyMap(e.KeyCode)
            btnKey.Select()
            btnKey.PerformClick()
        End If
    End Sub

    Private Sub btnKey_Click(sender As Object, e As EventArgs)
        Dim btn As Button = sender
        Dim tagValue As Byte = Val("&h" & btn.Tag)

        Dim devAddr As UShort = tagValue / &H10
        Dim bitNo As Byte = tagValue And &HF

        SetKeyBit(devAddr, bitNo)
        Dim cbackup As Color = btn.BackColor
        If (devAddr = 8 And bitNo <= 5) Or (devAddr = 9 And bitNo <= 4) Then
            btn.BackColor = FormSettings.Default.ControlKeyPressColor
        Else
            btn.BackColor = FormSettings.Default.NormalKeyPressColor
        End If

        Thread.Sleep(My.Settings.KeyPressTime)

        ResetKeyBit(devAddr, bitNo)
        btn.BackColor = cbackup
    End Sub

    Private Sub pnlDisplay_Paint(sender As Object, e As PaintEventArgs) Handles pnlDisplay.Paint
        e.Graphics.DrawImage(_ScreenImage, 0, 0)
    End Sub

#End Region

#Region "初期化"

    Private Sub InitKeyMap()
        _KeyMap(Keys.D1) = btnKey1
        _KeyMap(Keys.D2) = btnKey2
        _KeyMap(Keys.D3) = btnKey3
        _KeyMap(Keys.D4) = btnKey4
        _KeyMap(Keys.D5) = btnKey5
        _KeyMap(Keys.D6) = btnKey6
        _KeyMap(Keys.D7) = btnKey7
        _KeyMap(Keys.D8) = btnKey8
        _KeyMap(Keys.D9) = btnKey9
        _KeyMap(Keys.D0) = btnKey0

        _KeyMap(Keys.A) = btnKeyA
        _KeyMap(Keys.B) = btnKeyB
        _KeyMap(Keys.C) = btnKeyC
        _KeyMap(Keys.D) = btnKeyD
        _KeyMap(Keys.E) = btnKeyE
        _KeyMap(Keys.F) = btnKeyF
        _KeyMap(Keys.G) = btnKeyG
        _KeyMap(Keys.H) = btnKeyH
        _KeyMap(Keys.I) = btnKeyI
        _KeyMap(Keys.J) = btnKeyJ
        _KeyMap(Keys.K) = btnKeyK
        _KeyMap(Keys.L) = btnKeyL
        _KeyMap(Keys.M) = btnKeyM
        _KeyMap(Keys.N) = btnKeyN
        _KeyMap(Keys.O) = btnKeyO
        _KeyMap(Keys.P) = btnKeyP
        _KeyMap(Keys.Q) = btnKeyQ
        _KeyMap(Keys.R) = btnKeyR
        _KeyMap(Keys.S) = btnKeyS
        _KeyMap(Keys.T) = btnKeyT
        _KeyMap(Keys.U) = btnKeyU
        _KeyMap(Keys.V) = btnKeyV
        _KeyMap(Keys.W) = btnKeyW
        _KeyMap(Keys.X) = btnKeyX
        _KeyMap(Keys.Y) = btnKeyY
        _KeyMap(Keys.Z) = btnKeyZ
        _KeyMap(Keys.Subtract) = btnKeyMinus

        _KeyMap(Keys.Space) = btnKeySpace
        _KeyMap(Keys.Enter) = btnKeyCR
        _KeyMap(Keys.Delete) = btnKeyInstDel

        _logger.Information("KeyMap Initialized.")
    End Sub

    Private Sub SetKeyButtonEvent()
        For Each ctrl As Control In pnlKeyBoard.Controls
            If TypeOf ctrl Is Button Then
                AddHandler ctrl.Click, AddressOf btnKey_Click
            End If
        Next
        _logger.Information("KeyButton Event Added.")
    End Sub

#End Region

#Region "キーボードの処理"

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iAddr"></param>
    ''' <param name="iBitNo"></param>
    Private Sub SetKeyBit(iAddr As UShort, iBitNo As Byte)
        _KeyIOMem(iAddr) = _KeyIOMem(iAddr) Or 2 ^ iBitNo
    End Sub

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iAddr"></param>
    ''' <param name="iBitNo"></param>
    Private Sub ResetKeyBit(iAddr As UShort, iBitNo As Byte)
        _KeyIOMem(iAddr) = _KeyIOMem(iAddr) And Not (2 ^ iBitNo)
    End Sub

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iaddr"></param>
    ''' <returns></returns>
    Private Function ReadKeyBit(iaddr As UShort) As Byte
        Return _KeyIOMem(iaddr)
    End Function

#End Region

#Region "ディスプレイの処理"

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iAddr"></param>
    ''' <param name="iCode"></param>
    Private Sub WriteVram(iAddr As UShort, iCode As Byte)
        Dim scrX As Integer = (iAddr Mod SCREEN_WIDTH) * (FONT_WIDTH)
        Dim scrY As Integer = Math.Floor(iAddr / SCREEN_WIDTH) * (FONT_HEIGHT)
        Dim fntX As Integer = Math.Floor(iCode / FONT_WIDTH) * FONT_WIDTH
        Dim fntY As Integer = (iCode Mod FONT_HEIGHT) * FONT_HEIGHT

        Dim fntRct As New Rectangle(fntX, fntY, FONT_WIDTH, FONT_HEIGHT)
        Dim gfx As Graphics = Graphics.FromImage(_ScreenImage)

        gfx.DrawImage(_FontBitmap, scrX, scrY, fntRct, GraphicsUnit.Pixel)
        pnlDisplay.Refresh()

        _VramMem(iAddr) = iCode
    End Sub

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iAddr"></param>
    ''' <returns></returns>
    Private Function ReadVram(iAddr As UShort) As Byte
        Return _VramMem(iAddr)
    End Function

#End Region

#Region "VDCPサーバのイベント"

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    Private Sub _vdcpServer_DeviceReadRequest(sender As Object, e As DeviceReqEventArgs) Handles _vdcpServer.DeviceReadRequest
        Select Case e.DevClass
            Case &H0
                'キースキャン
                _vdcpServer.SendDevResponse(e.Addr, ReadKeyBit(e.Addr))
            Case &H1
                'VRAM読み出し
                _vdcpServer.SendDevResponse(e.Addr, ReadVram(e.Addr))
        End Select
    End Sub

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    Private Sub _vdcpServer_DeviceWriteRequest(sender As Object, e As DeviceReqEventArgs) Handles _vdcpServer.DeviceWriteRequest
        If e.DevClass = &H1 Then
            'VRAM書き込み
            WriteVram(e.Addr, e.Data)
        End If
    End Sub

    Private Sub _vdcpServer_ControlRequest(sender As Object, e As ControlReqEventArgs) Handles _vdcpServer.ControlRequest
        If e.CommandString = "END" Then
            Me.Close()
        End If
    End Sub

#End Region
End Class
