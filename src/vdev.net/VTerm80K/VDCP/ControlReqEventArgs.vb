''' <summary>
''' 
''' </summary>
Public Class ControlReqEventArgs
    Inherits EventArgs

    ''' <summary>
    ''' デバイスクラス
    ''' </summary>
    ''' <returns></returns>
    Public Property DevClass As Byte

    ''' <summary>
    ''' デバイスID
    ''' </summary>
    ''' <returns></returns>
    Public Property DevId As Byte

    ''' <summary>
    ''' 制御コマンド文字列
    ''' </summary>
    ''' <returns></returns>
    Public Property CommandString As String
End Class
