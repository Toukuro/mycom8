Namespace Logger

    Public Class FormatLogger
        Inherits Logger

#Region "定数定義"

#End Region

#Region "インスタンス変数定義"

#End Region

#Region "コンストラクタ"

#End Region

#Region "プロパティ"

#End Region

#Region "パブリックメソッド"

#End Region

#Region "プライベートメソッド"

#End Region

        Public Sub New()
            MyBase.New
        End Sub

        Public Sub New(iAccessor As LogAccessor)
            MyBase.New(iAccessor)
        End Sub

        Public Overloads Function Detail(iMsgFormat As String, ParamArray iData() As Object) As String
            Return Detail(String.Format(iMsgFormat, iData))
        End Function

        Public Overloads Function Information(iMsgFormat As String, ParamArray iData() As Object) As String
            Return Information(String.Format(iMsgFormat, iData))
        End Function

        Public Overloads Function Warning(iMsgFormat As String, ParamArray iData() As Object) As String
            Return Warning(String.Format(iMsgFormat, iData))
        End Function

        Public Overloads Function [Error](iMsgFormat As String, ParamArray iData() As Object) As String
            Return [Error](String.Format(iMsgFormat, iData))
        End Function

        Public Overloads Function Fatal(iMsgFormat As String, ParamArray iData() As Object) As String
            Return Fatal(String.Format(iMsgFormat, iData))
        End Function

        Public Overloads Function Debug(iMsgFormat As String, ParamArray iData() As Object) As String
            Return Debug(String.Format(iMsgFormat, iData))
        End Function

    End Class

End Namespace
