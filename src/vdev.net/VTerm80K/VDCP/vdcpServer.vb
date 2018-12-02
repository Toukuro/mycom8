Imports System.Net.Sockets

Public Class VdcpServer
    Inherits PXCommon.SimpleServer

#Region "イベント定義"

    Public Delegate Sub DeviceReqEventHandler(sender As Object, e As DeviceReqEventArgs)
    Public Event DeviceReadRequest As DeviceReqEventHandler
    Public Event DeviceWriteRequest As DeviceReqEventHandler

    Public Delegate Sub ControlReqEventHandler(sender As Object, e As ControlReqEventArgs)
    Public Event ControlRequest As ControlReqEventHandler

#End Region


    Public Sub SendResponse()

    End Sub


    Protected Overrides Function AsyncReadCallback(asyncResult As IAsyncResult) As Integer
        MyBase.AsyncReadCallback(asyncResult)

        If _readData.Count > 0 Then
            Dim delimIdx As Integer = _readData.IndexOf(vbCr)

        End If
        Return 0
    End Function
End Class
