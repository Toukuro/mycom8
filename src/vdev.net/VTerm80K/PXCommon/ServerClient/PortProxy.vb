Imports System.IO
Imports System.Text

''' <summary>
''' 入出力ポートプロキシ基本クラス
''' </summary>
''' <remarks>
''' このクラスの派生クラスで、シリアルポートや
''' ネットワークとの橋渡し処理を実装する。
''' </remarks>
Public Class PortProxy

    Protected _realPort As Stream = Nothing              '実際のポートより取得／生成したストリーム
    Protected _isPortOpened As Boolean = False           'ポートのオープン状態
    Protected _asyncResult As IAsyncResult = Nothing
    Protected _portLogger As New Logger("PortLog")

#Region "ポートのオープンとクローズ"

    ''' <summary>
    ''' ポートのオープン
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>
    ''' ストリームがオブジェクト生成を以て、オープンされる場合は
    ''' ここで内部ストリーム<c>realPort</c>を生成する。
    ''' シリアルポートのように、Open/Closeが可能なオブジェクトの場合は、
    ''' 単にオープン処理のみ行う。
    ''' </remarks>
    Public Overridable Function Open() As Boolean
        _isPortOpened = True
        Return True
    End Function

    ''' <summary>
    ''' ポートのクローズ
    ''' </summary>
    ''' <remarks></remarks>
    Public Overridable Sub Close()
        _isPortOpened = False
    End Sub

    ''' <summary>
    ''' ポートのオープン状態の確認
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Overridable ReadOnly Property IsOpened() As Boolean
        Get
            Return _isPortOpened
        End Get
    End Property

#End Region

#Region "データの送受信"

#Region "データ送信（同期）"

    ''' <summary>
    ''' バイト列データの送信
    ''' </summary>
    ''' <param name="iBuffer">バイト列バッファー</param>
    ''' <param name="iLength">送信するデータ長</param>
    ''' <returns>送信完了したデータ長</returns>
    ''' <remarks></remarks>
    Public Overridable Function Send(iBuffer As Byte(), iLength As Integer) As Integer
        Try
            DumpData("SendData", iBuffer, iLength)
            _realPort.Write(iBuffer, 0, iLength)
            Return iLength

        Catch ex As Exception
            gLogger.Fatal(ex.Message & vbCrLf, ex.StackTrace)
            Return 0
        End Try
    End Function

#End Region

#Region "データ受信（非同期）"
    ''' <summary>
    ''' 非同期受信に使用される読込バッファ
    ''' </summary>
    ''' <remarks>
    ''' 受信データのダンプ出力のために、<c>BeginRead</c>で使用されたバッファを保持する。
    ''' </remarks>
    Protected asyncReadBuffer() As Byte

    ''' <summary>
    ''' 非同期読込を開始する
    ''' </summary>
    ''' <param name="iBuffer"></param>
    ''' <param name="asyncCallback"></param>
    ''' <returns></returns>
    ''' <remarks>受信データは常に先頭から設定される想定</remarks>
    Public Function BeginRead(iBuffer() As Byte, asyncCallback As AsyncCallback) As IAsyncResult
        asyncReadBuffer = iBuffer
        _asyncResult = _realPort.BeginRead(iBuffer, 0, iBuffer.Count, asyncCallback, Me)
        Return _asyncResult
    End Function

    ''' <summary>
    ''' 非同期読込を完了する
    ''' </summary>
    ''' <param name="asyncResult"></param>
    ''' <returns></returns>
    ''' <remarks>受信データは常に先頭から設定される想定</remarks>
    Public Function EndRead(asyncResult As IAsyncResult) As Integer
        Try
            Dim rcvLen As Integer = _realPort.EndRead(asyncResult)

            DumpData("RecvData", asyncReadBuffer, rcvLen)
            Return rcvLen

        Catch ex As IOException
            '非同期読込中のポートクローズは例外を無視。（０長読込とする）
            Return 0
        End Try
    End Function
#End Region

#End Region

#Region "ログ出力"

    ''' <summary>
    ''' ダンプデータをログ出力する
    ''' </summary>
    ''' <param name="iMsg">出力メッセージ</param>
    ''' <param name="iData">ダンプデータ</param>
    ''' <param name="iLength">ダンプするデータ長</param>
    ''' <remarks></remarks>
    Protected Sub DumpData(iMsg As String, iData() As Byte, iLength As Integer)
        'Dim addr As Integer = 0
        Dim dumpStr As New StringBuilder

        For addr As Integer = 0 To iLength - 1
            Dim bData As Byte = iData(addr)

            '相対アドレスが16の倍数の時、相対アドレス値を出力
            If (addr Mod 16) = 0 Then
                '既にデータが設定されている場合は、出力しバッファをリセット
                If dumpStr.Length > 0 Then
                    _portLogger.Info(dumpStr.ToString)
                    dumpStr.Length = 0
                    dumpStr.Append(iMsg & ": ")
                End If

                dumpStr.Append(Hex(addr).PadLeft(4, "0"c) & ":")
            ElseIf (addr Mod 8) = 0 Then
                dumpStr.Append(" ")
            End If
            dumpStr.Append(" " & Hex(bData).PadLeft(2, "0"c))
        Next

        'バッファにデータが残っていたら出力
        If dumpStr.Length > 0 Then
            _portLogger.Info(dumpStr.ToString)
        End If
    End Sub
#End Region
End Class
