Imports VDCP

Public Class VTermForm

    Private WithEvents _vdcpServer As VDCP.VdcpServer
    Private _KeyMap As New Hashtable        'KeyCode→Buttonの変換用
    Private _KeyMapShift As New Hashtable

    ''' <summary>キーの押下状態を示すデータ</summary>
    Private _KeyState(10) As Byte

    Private Sub VTermForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        InitKeyMap()
        SetKeyButtonEvent()
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
    End Sub

    Private Sub SetKeyButtonEvent()
        For Each ctrl As Control In pnlKeyBoard.Controls
            If TypeOf ctrl Is Button Then
                AddHandler ctrl.Click, AddressOf btnKey_Click
            End If
        Next
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
        Dim tagValue As Byte = 0

        Byte.TryParse(btn.Tag, tagValue)

        Dim devAddr As UShort = CInt(tagValue / &H10)
        Dim bitNo As Byte = tagValue And &HF

        Dim devData As Byte = 2 ^ bitNo

        If _vdcpServer IsNot Nothing AndAlso True Then

        End If
    End Sub

    Private Sub KeySet(iAddr As UShort, iKey As Byte)

    End Sub

    Private Sub KeyReset(iAddr As UShort, iKey As Byte)

    End Sub
#End Region

#Region "VDCPサーバのイベント"

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    Private Sub _vdcpServer_DeviceReadRequest(sender As Object, e As DeviceReqEventArgs) Handles _vdcpServer.DeviceReadRequest

    End Sub

#End Region
End Class
