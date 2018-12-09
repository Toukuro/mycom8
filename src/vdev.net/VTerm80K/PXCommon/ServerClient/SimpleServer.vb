Imports System.Net
Imports System.Net.Sockets

Namespace ServerClient

    ''' <summary>
    ''' 同時に１つのクライアントからの要求を処理する簡易サーバー
    ''' </summary>
    Public Class SimpleServer

#Region "定数定義"

        Private Const DFLT_SERVER As String = "localhost"
        Private Const DFLT_PORTNO As Integer = 12800
        Private Const DFLT_BUFFLEN As Integer = 1000    'デフォルトのバイトバッファー長

#End Region

#Region "インスタンス変数定義"

        Protected _readData As New List(Of Byte)        '受信データ

        Private _server As String = DFLT_SERVER
        Private _portNo As Integer = DFLT_PORTNO
        Private _ipAddr As IPAddress = Nothing
        Private _listener As TcpListener = Nothing
        Private _client As TcpClient = Nothing
        Private _readBuffer() As Byte                   '非同期受信用のバイトバッファー

        Protected _logger As New Logger.FormatLogger()

#End Region

#Region "コンストラクタ"

        ''' <summary>
        ''' コンストラクタ
        ''' </summary>
        ''' <remarks></remarks>
        Public Sub New()
            _readBuffer = Array.CreateInstance(GetType(Byte), DFLT_BUFFLEN)
        End Sub

        Public Sub New(iServer As String, iPortNo As Integer)
            If Not String.IsNullOrEmpty(iServer) Then
                _server = iServer
            End If
            If iPortNo > 0 Then
                _portNo = iPortNo
            End If
            _readBuffer = Array.CreateInstance(GetType(Byte), DFLT_BUFFLEN)
        End Sub

#End Region

#Region "プロパティ"

        Public ReadOnly Property Server As String
            Get
                Return _server
            End Get
        End Property

        ''' <summary>
        ''' 現在のポート番号を返却
        ''' </summary>
        ''' <returns></returns>
        Public ReadOnly Property PortNo As Integer
            Get
                Return _portNo
            End Get
        End Property

        Public ReadOnly Property IpAddres As String
            Get
                If _ipAddr Is Nothing Then
                    Return Nothing
                End If

                Return _ipAddr.ToString
            End Get
        End Property

        Public ReadOnly Property ClientIpAddress As String
            Get
                Return _client.Client.RemoteEndPoint.ToString
            End Get
        End Property

        Private Function IpToString(iIpAddr As IPAddress) As String
            Dim ipBytes() As Byte = _ipAddr.GetAddressBytes
            Dim ipStr As String = ""
            For Each octet As Byte In ipBytes
                If String.IsNullOrEmpty(ipStr) Then
                    ipStr = String.Concat(ipStr, octet.ToString())
                Else
                    ipStr = String.Concat(ipStr, ".", octet.ToString)
                End If
            Next
            Return ipStr
        End Function
        Public Property LogAccessor As Logger.LogAccessor
            Get
                Return _logger.Accessor
            End Get
            Set(value As Logger.LogAccessor)
                _logger = New Logger.FormatLogger(value)
            End Set
        End Property

#End Region

#Region "サーバスタート"

        ''' <summary>
        ''' 
        ''' </summary>
        Public Sub StartListen()
            '自身のIPアドレスを取得
            Try
                Dim ipSet() As IPAddress = Dns.GetHostAddresses(_server)
                _ipAddr = ipSet(0)
                For Each ip As IPAddress In ipSet
                    If ip.AddressFamily = AddressFamily.InterNetwork Then
                        _ipAddr = ip
                    End If
                Next

            Catch ex As Exception
                Dim msg As String = String.Format("IP address can not be acquired. (server=[{0}])", _server)
                Throw New CommException(msg, ex)
            End Try

            'TcpListenerの生成
            Try
                _listener = New TcpListener(_ipAddr, _portNo)
            Catch ex As Exception
                Throw New CommException("Can not start listening.", ex)
            End Try
            _logger.Detail("Listen started.")

            '待ち受け
            While _client Is Nothing
                If _listener.Pending Then
                    _client = _listener.AcceptTcpClient
                    _logger.Detail("Client connected. (client=[{0}])", Me.IpAddres)
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
                Dim msg As String = _logger.Error("Read failed.")
                Throw New CommException(msg, ex)
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

            _logger.Detail("AsyncRead start.")
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
                _logger.Detail("stream closed.")
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
            _logger.Detail("data received. (length={0} bytes)", readLen)

            Return readLen
        End Function

#End Region
    End Class

End Namespace
