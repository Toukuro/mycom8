Imports System.IO

Namespace Logger

    ''' <summary>
    ''' ログ出力用ファイルアクセサ
    ''' </summary>
    ''' <remarks>
    ''' <para>(C) 2017 Experis ManpowerGroup</para>
    ''' <para>Author: K.Adachi</para>
    ''' <para>$Id: FileLogAccessor.vb 33 2017-05-25 08:51:54Z koji_adachi $</para>
    ''' </remarks>
    Public Class FileLogAccessor
        Inherits LogAccessor

        Public Const INIT_DATE_FORMAT As String = "-yyyyMMdd"

        Private Shared _DefaultDateFormat As String = INIT_DATE_FORMAT

        Protected Shared _fileNameList As New ArrayList

        Protected _pathName As String = "Log\"
        Protected _baseName As String = String.Empty
        Protected _extName As String = ".log"
        Protected _withDate As Boolean = True

        Protected _stream As System.IO.StreamWriter = Nothing

#Region "コンストラクタ"

        ''' <summary>
        ''' コンストラクタ（デフォルト）
        ''' </summary>
        ''' <remarks></remarks>
        Public Sub New()
            Dim asm As Reflection.Assembly = Me.GetType.Assembly
            _baseName = asm.GetName.Name
            _lockObj = GetLockObj(GetFileName())

            If _withDate Then
                _DateFormat = _DefaultDateFormat
            End If
        End Sub

        ''' <summary>
        ''' コンストラクタ（ファイル名指定）
        ''' </summary>
        ''' <param name="iBaseName">基準ファイル名（パス、拡張子なし）</param>
        ''' <param name="iWithDate">日付を基準ファイル名に付加する</param>
        ''' <remarks></remarks>
        Public Sub New(iBaseName As String, Optional iWithDate As Boolean = True)
            _baseName = iBaseName
            _withDate = iWithDate
            _lockObj = GetLockObj(GetFileName())

            If _withDate Then
                _DateFormat = _DefaultDateFormat
            End If
        End Sub

        ''' <summary>
        ''' コンストラクタ（完全指定）
        ''' </summary>
        ''' <param name="iPathName">パス名</param>
        ''' <param name="iBaseName">基準ファイル名</param>
        ''' <param name="iExtName">拡張子</param>
        ''' <param name="iWithDate">日付を基準ファイル名に付加する</param>
        ''' <remarks></remarks>
        Public Sub New(iPathName As String, iBaseName As String, Optional iExtName As String = ".log", Optional iWithDate As Boolean = True)
            _pathName = iPathName
            _baseName = iBaseName
            _extName = iExtName
            _withDate = iWithDate
            _lockObj = GetLockObj(GetFileName())

            If _withDate Then
                _DateFormat = _DefaultDateFormat
            End If
        End Sub

#End Region

#Region "プロパティ"

        ''' <summary>
        ''' ファイル名に日付を付加するときのデフォルト日付フォーマット
        ''' </summary>
        ''' <returns></returns>
        Public Shared Property DefaultDateFormat As String
            Get
                Return _DefaultDateFormat
            End Get
            Set(value As String)
                If String.IsNullOrEmpty(value) Then
                    _DefaultDateFormat = INIT_DATE_FORMAT
                Else
                    _DefaultDateFormat = value
                End If
            End Set
        End Property

        ''' <summary>
        ''' ファイル名に日付を付加するときの日付フォーマット
        ''' </summary>
        ''' <returns></returns>
        Public Property DateFormat As String = String.Empty

#End Region

#Region "メソッド"

        ''' <summary>
        ''' アクセサファイルのオープン
        ''' </summary>
        ''' <remarks></remarks>
        Public Overrides Sub Open()
            Dim fname As String = Path.GetFullPath(GetFileName())
            _lockObj = GetLockObj(fname)

            Dim pname As String = Path.GetDirectoryName(fname)

            If Not Directory.Exists(pname) Then
                Directory.CreateDirectory(pname)
            End If

            Try
                _stream = New StreamWriter(New FileStream(fname, FileMode.Append))

            Catch ex As Exception
                Throw
            End Try

        End Sub

        ''' <summary>
        ''' アクセサファイルをクローズ
        ''' </summary>
        ''' <remarks></remarks>
        Public Overrides Sub Close()
            If _stream IsNot Nothing Then
                _stream.Close()
            End If
        End Sub

        ''' <summary>
        ''' アクセサにメッセージを出力
        ''' </summary>
        ''' <param name="iMessage"></param>
        ''' <remarks></remarks>
        Public Overrides Sub Write(iMessage As String)
            If _stream IsNot Nothing Then
                _stream.WriteLine(iMessage)
            End If
        End Sub

#End Region

#Region "プライベートメソッド"

        ''' <summary>
        ''' ログファイル名の取得
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Function GetFileName() As String
            Dim dtToday As DateTime = DateTime.Today
            Dim fname As String = Path.Combine(_pathName, _baseName)

            If _withDate Then
                fname &= DateTime.Today.ToString(_dateFormat)
            End If

            fname &= _extName

            Return fname
        End Function

        ''' <summary>
        ''' ファイル名を基にスレッド排他用のオブジェクトを設定する
        ''' </summary>
        ''' <param name="iFileName"></param>
        ''' <remarks>
        ''' ・<c>_fileNameList</c>でログファイル名の一意性を保証する。
        ''' ・引数で指定されるファイル名は同一ファイル名でもオブジェクトは
        ''' 　異なる可能性がある。
        ''' ・常に<c>_fileNameList</c>に設定された要素(ファイル名)を
        ''' 　<c>_lockObj</c>に設定することで、スレッド排他がログファイル毎に
        ''' 　なることを保証する。
        ''' <para>TODO:不要になったエントリをどうやって削除するか？</para>
        ''' </remarks>
        Private Function GetLockObj(iFileName As String) As Object
            '登録済みのファイル名を検索する。
            Dim idx As Integer = _fileNameList.IndexOf(iFileName)

            '未登録であった場合は、引数のファイル名を登録する。
            If idx < 0 Then
                idx = _fileNameList.Add(iFileName)
            End If

            '_fileNameListの要素を_lockObjに設定する。
            Return _fileNameList(idx)
        End Function

#End Region
    End Class

End Namespace