Public Class vdcpServer

    Protected _proxy As PortProxy = Nothing

    Private Const DFLT_BUFFLEN As Integer = 1000    'デフォルトのバイトバッファー長

    Protected _readBuffer() As Byte                 '非同期受信用のバイトバッファー
    Protected _readData As String = String.Empty    '非同期受信したバイトバッファーからUTF-8で変換した文字列

    Public Event ReadRequest(e As DevRequestEventArgs)
    Public Event WriteRequest(e As DevRequestEventArgs)

    ''' <summary>
    ''' コンストラクタ
    ''' </summary>
    ''' <param name="iProxy"></param>
    ''' <remarks></remarks>
    Public Sub New(iProxy As PortProxy)
        _proxy = iProxy
        _readBuffer = Array.CreateInstance(GetType(Byte), DFLT_BUFFLEN)
    End Sub

    Public Sub SendResponse()

    End Sub

    Public Sub StartListen()

    End Sub

    ''' <summary>
    ''' 非同期読込を開始する
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>
    ''' 読み込まれたデータは、メンバ変数<c>readData</c>に蓄積する。
    ''' データ受信時に<c>AsyncReadCallback</c>が呼び出されるので、そこで参照可能。
    ''' </remarks>
    Public Function AsyncRead() As IAsyncResult
        Return _proxy.BeginRead(_readBuffer, AddressOf _AsyncReadCallback)
    End Function

    ''' <summary>
    ''' 非同期読込のコールバック（内部用）
    ''' </summary>
    ''' <param name="asyncResult"></param>
    ''' <remarks></remarks>
    Private Sub _AsyncReadCallback(asyncResult As IAsyncResult)
        Dim port As PortProxy = asyncResult.AsyncState
        If AsyncReadCallback(asyncResult) > 0 Then
            AsyncRead()
        Else
            port.Close()
        End If
    End Sub

    ''' <summary>
    ''' 非同期読込のコールバック（派生クラスでの個別処理用）
    ''' </summary>
    ''' <param name="asyncResult"></param>
    ''' <remarks>
    ''' ０長データを受信した場合、通信終了と見なしてポートをクローズする。
    ''' 再度非同期受信を行う場合は通信状態を確認後、Open→AsyncReadを実行されたし。
    ''' </remarks>
    Protected Overridable Function AsyncReadCallback(asyncResult As IAsyncResult) As Integer
        Dim port As PortProxy = asyncResult.AsyncState
        Dim readLen As Integer = port.EndRead(asyncResult)

        If readLen > 0 Then
            _readData += PrintCommand.CmdEncoding.GetString(_readBuffer, 0, readLen)
        End If

        Return readLen
    End Function

End Class
