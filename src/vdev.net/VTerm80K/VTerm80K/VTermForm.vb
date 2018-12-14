Imports PXCommon
Imports VDCP
Imports System.Threading
Imports System.IO

Public Class VTermForm

    Private Const SCREEN_WIDTH As Integer = 40
    Private Const SCREEN_HEIGHT As Integer = 25

    Private Const KBDIO_SIZE As Integer = 10

    Private WithEvents _vdcpServer As VdcpServer

    Private _KeyMap As New Hashtable        'KeyCode→Buttonの変換用
    Private _KeyMapShift As New Hashtable
    Private _PressedShiftKey As Button = Nothing
    Private _KanaKey As Button = Nothing

    ''' <summary>キーの押下状態を示すデータ</summary>
    Private _KeyIOData(KBDIO_SIZE) As Byte

    Private _VramData(SCREEN_WIDTH * SCREEN_HEIGHT) As Byte
    Private _ScreenImage As Bitmap
    Private _FontBitmap As Bitmap = My.Resources.MZ80Font
    Private _testVramAddr As UShort = 0
    Private _testCode As Byte = 0

    Private _logger As Logger.FormatLogger
    Private _lockObj As New Object

    Private Sub VTermForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        _logger = New Logger.FormatLogger(New Logger.FileLogAccessor(Me.GetType.Name))
        InitKeyMap()
        SetKeyButtonEvent()

        Dim gfx As Graphics = pnlDisplay.CreateGraphics
        _ScreenImage = New Bitmap(640, 400, gfx)
        pnlDisplay.DrawToBitmap(_ScreenImage, New Rectangle(0, 0, 640, 400))
    End Sub

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

#Region "キーボードの処理"

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

        KeySet(devAddr, bitNo)
        Dim cbackup As Color = btn.BackColor
        If (devAddr = 8 And bitNo <= 5) Or (devAddr = 9 And bitNo <= 4) Then
            btn.BackColor = FormSettings.Default.ControlKeyPressColor
        Else
            btn.BackColor = FormSettings.Default.NormalKeyPressColor
        End If

        Thread.Sleep(My.Settings.KeyPressTime)

        KeyReset(devAddr, bitNo)
        WriteVram(_testVramAddr, _testCode)
        _testVramAddr += 1
        _testCode += 1

        btn.BackColor = cbackup
    End Sub

#Region "Keyboard I/O データへのアクセス"

    Private Sub KeySet(iAddr As UShort, iBitNo As Byte)
        _KeyIOData(iAddr) = _KeyIOData(iAddr) Or 2 ^ iBitNo
    End Sub

    Private Sub KeyReset(iAddr As UShort, iBitNo As Byte)
        _KeyIOData(iAddr) = _KeyIOData(iAddr) And Not (2 ^ iBitNo)
    End Sub

    Private Function KeyRead(iaddr As UShort) As Byte
        Return _KeyIOData(iaddr)
    End Function

#End Region

#End Region

#Region "ディスプレイの処理"

    'Private Sub LoadFontBitmap(iFileName As String)
    '    Using fs As New FileStream(iFileName, FileMode.Open)
    '        _FontBitmap = Bitmap.FromStream(fs)
    '    End Using
    'End Sub

    Private Sub WriteVram(iAddr As UShort, iCode As Byte)
        Dim scrX As Integer = (iAddr Mod SCREEN_WIDTH) * 16
        Dim scrY As Integer = Math.Floor(iAddr / SCREEN_WIDTH) * 16
        Dim fntX As Integer = Math.Floor(iCode / 16) * 16
        Dim fntY As Integer = (iCode Mod 16) * 16

        'If (iCode Mod 16) > 0 Then
        '    fntY -= 1
        'End If
        'If (iAddr Mod SCREEN_WIDTH) > 0 Then
        '    scrY -= 1
        'End If

        Dim fntRct As New Rectangle(fntX, fntY, 16, 16)
        Dim gfx As Graphics = Graphics.FromImage(_ScreenImage)

        gfx.DrawImage(_FontBitmap, scrX, scrY, fntRct, GraphicsUnit.Pixel)
        pnlDisplay.Refresh()

        _VramData(iAddr) = iCode
    End Sub

    Private Function ReadVram(iAddr As UShort) As Byte
        Return _VramData(iAddr)
    End Function

    Private Sub pnlDisplay_Paint(sender As Object, e As PaintEventArgs) Handles pnlDisplay.Paint
        e.Graphics.DrawImage(_ScreenImage, 0, 0)
    End Sub

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
                _vdcpServer.SendDevResponse(e.Addr, _KeyIOData(e.Addr))
            Case &H1
                'VRAM読み出し
        End Select
    End Sub

    Private Sub _vdcpServer_DeviceWriteRequest(sender As Object, e As DeviceReqEventArgs) Handles _vdcpServer.DeviceWriteRequest
        If e.DevClass = &H1 Then
            'VRAM書き込み
        End If
    End Sub



#End Region
End Class
