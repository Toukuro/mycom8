Imports System.Net.Sockets

''' <summary>
''' 
''' </summary>
Public Class SimpleServer

#Region "定数定義"

    Private Const DFLT_BUFFLEN As Integer = 1000    'デフォルトのバイトバッファー長

#End Region

#Region "インスタンス変数定義"

    Private _readBuffer() As Byte                 '非同期受信用のバイトバッファー
    Protected _readData As New List(Of Byte)        '受信データ

    Private _listener As TcpListener = Nothing
    Private _client As TcpClient = Nothing

#End Region

#Region "コンストラクタ"

    ''' <summary>
    ''' コンストラクタ
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub New()
        _readBuffer = Array.CreateInstance(GetType(Byte), DFLT_BUFFLEN)
    End Sub

#End Region

#Region "サーバスタート"

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="iPortNo"></param>
    Public Sub StartListen(iPortNo As Integer)
        '自身のIPアドレスを取得

        'TcpListenerの生成

        '待ち受け
        While _client Is Nothing
            If _listener.Pending Then
                _client = _listener.AcceptTcpClient
            Else
                Threading.Thread.Sleep(1000)
            End If
        End While
    End Sub

#End Region

#Region "送受信処理"

    ''' <summary>
    ''' 同期受信
    ''' </summary>
    ''' <param name="iBuffer"></param>
    ''' <param name="iMaxLength"></param>
    ''' <returns></returns>
    Function Read(iBuffer() As Byte, iMaxLength As Integer) As Integer
        If _client Is Nothing Then
            Throw New CommException("Connection with the client is not established.")
        End If

        Try
            Dim stream As NetworkStream = _client.GetStream
            Return stream.Read(iBuffer, 0, iMaxLength)
        Catch ex As Exception
            Throw New CommException("Read failed.", ex)
        End Try
    End Function

    ''' <summary>
    ''' 送信
    ''' </summary>
    ''' <param name="iData"></param>
    ''' <returns></returns>
    Function Send(iData() As Byte) As Integer
        If _client Is Nothing Then
            Throw New CommException("Connection with the client is not established.")
        End If

        Try
            Dim stream As NetworkStream = _client.GetStream
            Dim length As Integer = iData.Length
            stream.Write(iData, 0, length)

            Return length
        Catch ex As Exception
            Throw New CommException("Send failed.", ex)
        End Try
    End Function

#End Region

#Region "非同期受信"

    ''' <summary>
    ''' 非同期読込を開始する
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>
    ''' 読み込まれたデータは、メンバ変数<c>readData</c>に蓄積する。
    ''' データ受信時に<c>AsyncReadCallback</c>が呼び出されるので、そこで参照可能。
    ''' </remarks>
    Public Function AsyncRead() As IAsyncResult
        If _client Is Nothing Then
            Throw New CommException("Connection with the client is not established.")
        End If

        Dim stream As NetworkStream = _client.GetStream
        Return stream.BeginRead(_readBuffer, 0, _readBuffer.Length, AddressOf _AsyncReadCallback, stream)
    End Function

    ''' <summary>
    ''' 非同期読込のコールバック（内部用）
    ''' </summary>
    ''' <param name="asyncResult"></param>
    ''' <remarks></remarks>
    Private Sub _AsyncReadCallback(asyncResult As IAsyncResult)
        Dim stream As NetworkStream = asyncResult.AsyncState

        If AsyncReadCallback(asyncResult) > 0 Then
            AsyncRead()
        Else
            stream.Close()
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
        Dim stream As NetworkStream = asyncResult.AsyncState
        Dim readLen As Integer = stream.EndRead(asyncResult)

        If readLen > 0 Then
            For i As Integer = 0 To readLen - 1
                _readData.Add(_readBuffer(i))
            Next
        End If

        Return readLen
    End Function

#End Region
End Class
