''' <summary>
''' 
''' </summary>
Public Class DeviceReqEventArgs
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
    ''' リクエストアドレス
    ''' </summary>
    ''' <returns></returns>
    Public Property Addr As UShort

    ''' <summary>
    ''' Write要求時のリクエストデータ
    ''' </summary>
    ''' <returns></returns>
    Public Property Data As Byte

End Class
