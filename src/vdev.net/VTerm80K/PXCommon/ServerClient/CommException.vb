''' <summary>
''' 
''' </summary>
Public Class CommException
    Inherits Exception

    Sub New()
        MyBase.New()
    End Sub

    Sub New(iMessage As String)
        MyBase.New(iMessage)
    End Sub

    Sub New(iMessage As String, iEx As Exception)
        MyBase.New(iMessage, iEx)
    End Sub
End Class
