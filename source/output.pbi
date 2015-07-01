DeclareModule output
  EnableExplicit
  
  Declare setLogFile(file$)
  Declare deleteLogFile()
  Declare add(str$)
  
EndDeclareModule

Module output
  Global LogFile$
  
  Procedure setLogFile(file$)
    LogFile$ = file$
  EndProcedure
  
  Procedure deleteLogFile()
    Debug "delete debug log file"
    DeleteFile(LogFile$, #PB_FileSystem_Force)
  EndProcedure
  
  Procedure add(str$)
    Protected file
    Debug str$
    If LogFile$ <> ""
      file = OpenFile(#PB_Any, LogFile$, #PB_File_Append|#PB_File_NoBuffering)
      If file
        str$ = FormatDate("%hh:%ii:%ss", Date()) + " " + str$
        WriteStringN(file, str$)
        CloseFile(file)
      EndIf
    EndIf
  EndProcedure
EndModule
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 27
; Folding = -
; EnableUnicode
; EnableXP