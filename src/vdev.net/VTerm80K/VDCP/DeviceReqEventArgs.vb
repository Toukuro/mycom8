''' <summary>
''' 
''' </summary>
Public Class DeviceReqEventArgs
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
    ''' リクエストアドレス
    ''' </summary>
    ''' <returns></returns>
    Public ReadOnly Property Addr As UShort

    ''' <summary>
    ''' Write要求時のリクエストデータ
    ''' </summary>
    ''' <returns></returns>
    Public ReadOnly Property Data As Byte

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iDevClass"></param>
    ''' <param name="iDevId"></param>
    ''' <param name="iAddr"></param>
    ''' <param name="iData"></param>
    Public Sub New(iDevClass As Byte, iDevId As Byte, iAddr As UShort, iData As Byte)
        _DevClass = iDevClass
        _DevId = iDevId
        _Addr = iAddr
        _Data = iData
    End Sub
End Class
