Namespace Logger

    ''' <summary>
    ''' ログ出力用アクセサ基本クラス
    ''' </summary>
    ''' <remarks>
    ''' ここでのアクセサとは、ログの出力先を制御するものを示す。
    ''' <para>(C) 2017 Experis ManpowerGroup</para>
    ''' <para>Author: K.Adachi</para>
    ''' <para>$Id: LogAccessor.vb 33 2017-05-25 08:51:54Z koji_adachi $</para>
    ''' </remarks>
    Public MustInherit Class LogAccessor

        ''' <summary>スレッド排他制御用オブジェクト</summary>
        ''' <remarks>
        ''' 派生クラスにて適切なオブジェクトを設定すること。
        ''' 例１）インスタンスレベルでの排他を行う場合：インスタンス変数レベルのオブジェクトを設定する。
        ''' 例２）クラスレベルでの排他制御を行う場合：クラス変数レベルのオブジェクトを設定する。
        ''' </remarks>
        Protected _lockObj As New Object

        Public ReadOnly Property LockObj As Object
            Get
                Return _lockObj
            End Get
        End Property

        ''' <summary>
        ''' アクセサのオープン
        ''' </summary>
        ''' <remarks></remarks>
        Public Overridable Sub Open()

        End Sub

        ''' <summary>
        ''' アクセサのクローズ
        ''' </summary>
        ''' <remarks></remarks>
        Public Overridable Sub Close()

        End Sub

        ''' <summary>
        ''' アクセサへの出力
        ''' </summary>
        ''' <param name="iMessage"></param>
        ''' <remarks></remarks>
        Public Overridable Sub Write(iMessage As String)

        End Sub
    End Class

End Namespace