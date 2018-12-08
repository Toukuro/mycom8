''' <summary>
''' 
''' </summary>
Public Class ControlReqEventArgs
    Inherits EventArgs

    ''' <summary>
    ''' デバイスクラス
    ''' </summary>
    ''' <returns></returns>
    Public ReadOnly Property DevClass As Byte

    ''' <summary>
    ''' デバイスID
    ''' </summary>
    ''' <returns></returns>
    Public ReadOnly Property DevId As Byte

    ''' <summary>
    ''' 制御コマンド文字列
    ''' </summary>
    ''' <returns></returns>
    Public ReadOnly Property CommandString As String

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iDevClass"></param>
    ''' <param name="iDevId"></param>
    ''' <param name="iCommand"></param>
    Public Sub New(iDevClass As Byte, iDevId As Byte, iCommand As String)
        _DevClass = iDevClass
        _DevId = iDevId
        _CommandString = iCommand
    End Sub
End Class
