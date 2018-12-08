Imports System.Reflection
Imports System.Text
Imports System.Threading

Namespace Logger

    ''' <summary>
    ''' ログ出力クラス
    ''' </summary>
    ''' <remarks>
    ''' <para>(C) 2017 Experis ManpowerGroup</para>
    ''' <para>Author: K.Adachi</para>
    ''' <para>$Id: Logger.vb 33 2017-05-25 08:51:54Z koji_adachi $</para>
    ''' </remarks>
    Public Class Logger

        ''' <summary>
        ''' ログの出力区分を示す定数
        ''' </summary>
        Public Enum LogLevelEnum
            ''' <summary>ログ出力なし</summary>
            NONE
            ''' <summary>致命的エラー</summary>
            FATAL
            ''' <summary>エラー</summary>
            [ERROR]
            ''' <summary>警告</summary>
            WARNING
            ''' <summary>情報</summary>
            INFORMATION
            ''' <summary>詳細</summary>
            DETAIL
            ''' <summary>デバッグ</summary>
            DEBUG
            ''' <summary>すべて</summary>
            ALL
        End Enum

        Public Level As LogLevelEnum = LogLevelEnum.ALL

        'ログフォーマットのキーワード
        Private Const KWD_TimeStamp = "{TimeStamp}"     'タイムスタンプ（YYYY/MM/DD HH:MM:SS.FFF）
        Private Const KWD_ThreadId = "{ThreadId}"       'スレッドID
        Private Const KWD_Level = "{Level}"             'ログレベル
        Private Const KWD_Caller = "{Caller}"           '呼び出し元（クラス名．メソッド名）
        Private Const KWD_Message = "{Message}"         'ログメッセージ

        ''' <summary>デフォルトのログフォーマット</summary>
        Private Const DefaultFormat = KWD_TimeStamp & " " & _
                                      KWD_ThreadId & " [" & KWD_Level & "] " & KWD_Caller & " " & _
                                      KWD_Message

        Private _accessor As LogAccessor = Nothing   'ログ出力用アクセサ
        Private _logFormat As String = DefaultFormat    'ログフォーマット

        ''' <summary>
        ''' コンストラクタ
        ''' </summary>
        ''' <remarks>
        ''' アクセサが指定されない場合は、<c>NullLogAccessor</c>を設定する。
        ''' </remarks>
        Public Sub New()
            _accessor = New NullLogAccessor
        End Sub

        ''' <summary>
        ''' コンストラクタ
        ''' </summary>
        ''' <param name="iAccessor"></param>
        ''' <remarks></remarks>
        Public Sub New(iAccessor As LogAccessor)
            _accessor = iAccessor
        End Sub

        ''' <summary>
        ''' 使用中のアクセサを返却する
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public ReadOnly Property Accessor As LogAccessor
            Get
                Return _accessor
            End Get
        End Property

        ''' <summary>
        ''' ログフォーマットの参照と設定
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Property LogFormat As String
            Get
                Return _logFormat
            End Get
            Set(value As String)
                _logFormat = IIf(String.IsNullOrEmpty(value), DefaultFormat, value)
            End Set
        End Property

        ''' <summary>
        ''' 「詳細」ログの出力
        ''' </summary>
        ''' <param name="iMessage"></param>
        ''' <param name="iCallLevel"></param>
        Public Overridable Sub Detail(iMessage As String, Optional iCallLevel As Integer = 1)
            Me.Write(LogLevelEnum.DETAIL, iMessage, 1 + iCallLevel)
        End Sub

        ''' <summary>
        ''' 「情報」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <param name="iCallLevel">呼び出しレベル</param>
        ''' <remarks></remarks>
        Public Overridable Sub Information(iMessage As String, Optional iCallLevel As Integer = 1)
            Me.Write(LogLevelEnum.INFORMATION, iMessage, 1 + iCallLevel)
        End Sub

        ''' <summary>
        ''' 「警告」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <param name="iCallLevel">呼び出しレベル</param>
        ''' <remarks></remarks>
        Public Overridable Sub Warning(iMessage As String, Optional iCallLevel As Integer = 1)
            Me.Write(LogLevelEnum.WARNING, iMessage, 1 + iCallLevel)
        End Sub

        ''' <summary>
        ''' 「エラー」ログの出力
        ''' </summary>
        ''' <param name="iMessage"></param>
        ''' <param name="iCallLevel"></param>
        Public Overridable Sub [Error](iMessage As String, Optional iCallLevel As Integer = 1)
            Me.Write(LogLevelEnum.ERROR, iMessage, 1 + iCallLevel)
        End Sub

        ''' <summary>
        ''' 「致命的エラー」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <param name="iCallLevel">呼び出しレベル</param>
        ''' <remarks></remarks>
        Public Overridable Sub Fatal(iMessage As String, Optional iCallLevel As Integer = 1)
            Me.Write(LogLevelEnum.FATAL, iMessage, 1 + iCallLevel)
        End Sub

        ''' <summary>
        ''' 「デバッグ」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <param name="iCallLevel">呼び出しレベル</param>
        ''' <remarks></remarks>
        Public Overridable Sub Debug(iMessage As String, Optional iCallLevel As Integer = 1)
            Me.Write(LogLevelEnum.DEBUG, iMessage, 1 + iCallLevel)
        End Sub

        ''' <summary>
        ''' 汎用のログ出力メソッド
        ''' </summary>
        ''' <param name="iLevel">ログレベル</param>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <param name="iCallLevel">呼び出しレベル</param>
        ''' <remarks></remarks>
        Public Sub Write(iLevel As LogLevelEnum, iMessage As String, Optional iCallLevel As Integer = 1)
            If iLevel > Level Then
                Return
            End If

            SyncLock _accessor.LockObj
                'タイムスタンプ
                Dim tstamp As String = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss.fff")

                'スレッドID
                Dim threadId As Integer = Thread.CurrentThread.ManagedThreadId

                'ログ区分の設定
                Dim logType As String = String.Empty
                Select Case iLevel
                    Case LogLevelEnum.DETAIL
                        logType = "DETAIL"
                    Case LogLevelEnum.INFORMATION
                        logType = "INFO"
                    Case LogLevelEnum.WARNING
                        logType = "WARN"
                    Case LogLevelEnum.FATAL
                        logType = "FATAL"
                    Case LogLevelEnum.DEBUG
                        logType = "DEBUG"
                End Select

                '呼び出し元取得
                Dim caller As String = GetCaller(1 + iCallLevel)

                '出力文字列の生成
                Dim sb As New StringBuilder(_logFormat)
                With sb
                    .Replace(KWD_TimeStamp, tstamp)
                    .Replace(KWD_ThreadId, threadId)
                    .Replace(KWD_Level, logType)
                    .Replace(KWD_Caller, caller)
                    .Replace(KWD_Message, iMessage)
                End With

                _accessor.Open()
                _accessor.Write(sb.ToString)
                _accessor.Close()
            End SyncLock
        End Sub

        ''' <summary>
        ''' 呼び出し元のクラス名とメソッド名を取得する
        ''' </summary>
        ''' <param name="iCallLevel"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Function GetCaller(iCallLevel As Integer)
            Dim st As New StackTrace(False)
            Dim mb As MethodBase = st.GetFrame(iCallLevel).GetMethod
            Dim rt As Type = mb.ReflectedType

            Return String.Format("{0}.{1}", rt.Name, mb.Name)
        End Function
    End Class

End Namespace