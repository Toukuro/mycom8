Imports System.Reflection
Imports System.Text
Imports System.Threading

Namespace Logger

    ''' <summary>
    ''' ログ出力クラス
    ''' </summary>
    ''' <remarks>
    ''' <para>(C) Michikusa Ware 2018</para>
    ''' <para>Author: K.Adachi</para>
    ''' </remarks>
    Public Class Logger

#Region "定数定義"

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

#End Region

#Region "インスタンス変数定義"

        ''' <summary>ログ出力レベル</summary>
        Public Level As LogLevelEnum = LogLevelEnum.ALL

        'ログフォーマットのキーワード
        Private Const KWD_TimeStamp = "{TimeStamp}"     'タイムスタンプ（YYYY/MM/DD HH:MM:SS.FFF）
        Private Const KWD_ThreadId = "{ThreadId}"       'スレッドID
        Private Const KWD_Level = "{Level}"             'ログレベル
        Private Const KWD_Caller = "{Caller}"           '呼び出し元（クラス名．メソッド名）
        Private Const KWD_Message = "{Message}"         'ログメッセージ

        ''' <summary>デフォルトのログフォーマット</summary>
        Private Const DefaultFormat = KWD_TimeStamp & " " &
                                      KWD_ThreadId & " [" & KWD_Level & "] " & KWD_Caller & " " &
                                      KWD_Message

        Private _accessor As LogAccessor = Nothing   'ログ出力用アクセサ
        Private _logFormat As String = DefaultFormat    'ログフォーマット

        Protected _StackLevelAdjust As Integer = 1

#End Region

#Region "コンストラクタ"

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

#End Region

#Region "プロパティ"

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

#End Region

#Region "パブリックメソッド"

        ''' <summary>
        ''' 「詳細」ログの出力
        ''' </summary>
        ''' <param name="iMessage"></param>
        Public Overridable Function Detail(iMessage As String) As String
            Return Me.Write(LogLevelEnum.DETAIL, iMessage)
        End Function

        ''' <summary>
        ''' 「情報」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <remarks></remarks>
        Public Overridable Function Information(iMessage As String) As String
            Return Me.Write(LogLevelEnum.INFORMATION, iMessage)
        End Function

        ''' <summary>
        ''' 「警告」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <remarks></remarks>
        Public Overridable Function Warning(iMessage As String) As String
            Return Me.Write(LogLevelEnum.WARNING, iMessage)
        End Function

        ''' <summary>
        ''' 「エラー」ログの出力
        ''' </summary>
        ''' <param name="iMessage"></param>
        Public Overridable Function [Error](iMessage As String) As String
            Return Me.Write(LogLevelEnum.ERROR, iMessage)
        End Function

        ''' <summary>
        ''' 「致命的エラー」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <remarks></remarks>
        Public Overridable Function Fatal(iMessage As String) As String
            Return Me.Write(LogLevelEnum.FATAL, iMessage)
        End Function

        ''' <summary>
        ''' 「デバッグ」ログの出力
        ''' </summary>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <remarks></remarks>
        Public Overridable Function Debug(iMessage As String) As String
            Return Me.Write(LogLevelEnum.DEBUG, iMessage)
        End Function

        ''' <summary>
        ''' 汎用のログ出力メソッド
        ''' </summary>
        ''' <param name="iLevel">ログレベル</param>
        ''' <param name="iMessage">ログメッセージ</param>
        ''' <remarks></remarks>
        Public Function Write(iLevel As LogLevelEnum, iMessage As String) As String
            If iLevel > Level Then
                Return iMessage
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
                Dim caller As String = GetCaller()

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

            Return iMessage
        End Function

#End Region

#Region "プライベートメソッド"

        ''' <summary>
        ''' 呼び出し元のクラス名とメソッド名を取得する
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Function GetCaller()
            Dim st As New StackTrace(False)
            Dim mb As MethodBase

            Dim level As Integer = 0
            Do
                level += 1
                mb = st.GetFrame(level).GetMethod
            Loop While mb.DeclaringType.Equals(Me.GetType)

            Dim rt As Type = mb.ReflectedType

            Return String.Format("{0}.{1}", rt.Name, mb.Name)
        End Function

#End Region
    End Class

End Namespace