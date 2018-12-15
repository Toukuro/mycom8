Imports PXCommon
Imports System.Net.Sockets
Imports System.Text

''' <summary>
''' VDCP Server
''' </summary>
Public Class VdcpServer
    Inherits ServerClient.SimpleServer

#Region "定数定義"

    Public Const DefaultPortNo As Integer = 28068

#End Region

#Region "イベント定義"

    Public Delegate Sub DeviceReqEventHandler(sender As Object, e As DeviceReqEventArgs)
    Public Event DeviceReadRequest As DeviceReqEventHandler
    Public Event DeviceWriteRequest As DeviceReqEventHandler

    Public Delegate Sub ControlReqEventHandler(sender As Object, e As ControlReqEventArgs)
    Public Event ControlRequest As ControlReqEventHandler

#End Region

#Region "インスタンス変数定義"

#End Region

#Region "コンストラクタ"

    ''' <summary>
    ''' コンストラクタ
    ''' </summary>
    Public Sub New(Optional iServer As String = Nothing, Optional iPortNo As Integer = DefaultPortNo)
        MyBase.New(iServer, iPortNo)
    End Sub

#End Region

#Region "プロパティ"

    ''' <summary></summary>
    Public Property Encoding As Encoding = Encoding.ASCII

    Public Property DevClass As Byte = 0

    Public Property DevId As Byte = 0

#End Region

    ''' <summary>
    ''' 制御レスポンスの送信
    ''' </summary>
    Public Function SendCtrlResponse(iData As String) As Integer
        Dim pktData As New StringBuilder
        With pktData
            .Append("D-")
            .Append(_DevClass.ToString("X2"))
            .Append(_DevId.ToString("X2"))
            .Append(iData)
            .AppendLine()
        End With

        _logger.Detail("Send control response. [{0:XX}:{1:XX}, {2}]", _DevClass, _DevId, iData)
        Dim sndData() As Byte = _Encoding.GetBytes(pktData.ToString)
        Return Send(sndData)
    End Function

    ''' <summary>
    ''' デバイスレスポンスの送信
    ''' </summary>
    ''' <param name="iAddr"></param>
    ''' <param name="iData"></param>
    Public Function SendDevResponse(iAddr As UShort, iData As Byte) As Integer
        Dim pktData As New StringBuilder
        With pktData
            .Append("D-")
            .Append(_DevClass.ToString("X2"))
            .Append(_DevId.ToString("X2"))
            .Append(iAddr.ToString("X4"))
            .Append(iData.ToString("X2"))
            .AppendLine()
        End With

        _logger.Detail("Send device response. [{0:XX}:{1:XX}, {2:XXXX} {3:XX}]", _DevClass, _DevId, iAddr, iData)
        Dim sndData() As Byte = _Encoding.GetBytes(pktData.ToString)
        Return Send(sndData)
    End Function

    ''' <summary>
    ''' 非同期受信のコールバック
    ''' </summary>
    ''' <param name="asyncResult"></param>
    ''' <returns></returns>
    Protected Overrides Function AsyncReadCallback(asyncResult As IAsyncResult) As Integer
        Dim dataLen As Integer = MyBase.AsyncReadCallback(asyncResult)

        dataLen = _readData.IndexOf(vbCr) + 1
        If dataLen <= 0 Then
            Return dataLen
        End If

        Dim pktData() As Byte = _readData.GetRange(0, dataLen).ToArray()
        _readData.RemoveRange(0, dataLen)

        If dataLen < 7 Then
            Return dataLen
        End If

        Dim pktStr As String = _Encoding.GetString(pktData)
        Dim ctrlDiv As String = pktStr.Substring(0, 1)
        Dim accsDiv As String = pktStr.Substring(1, 1)

        Byte.TryParse(pktStr.Substring(2, 2), _DevClass)
        Byte.TryParse(pktStr.Substring(4, 2), _DevId)

        Select Case ctrlDiv
            Case "C"
                Dim cmd As String = pktStr.Substring(6)
                Dim e As New ControlReqEventArgs(DevClass, DevId, cmd)
                _logger.Detail("Receive control request. [{0:XX}:{1:XX}, {2}]",
                               _DevClass, _DevId, cmd)
                RaiseEvent ControlRequest(Me, e)

            Case "D"
                Dim addr As UShort = 0
                Dim data As Byte = 0

                UShort.TryParse(pktStr.Substring(6, 4), addr)

                If accsDiv = "W" Then
                    Byte.TryParse(pktStr.Substring(10, 2), data)
                End If

                Dim e As New DeviceReqEventArgs(DevClass, DevId, addr, data)
                _logger.Detail("Send device response. [{0:XX}:{1:XX}, {2:XXXX} {3:XX}]",
                                       _DevClass, _DevId, addr, data)
                RaiseEvent DeviceWriteRequest(Me, e)
        End Select

        Return dataLen
    End Function
End Class
