DeclareModule output
  EnableExplicit
  
  Declare setLogFile(file$)
  Declare deleteLogFile()
  Declare add(str$)
  
EndDeclareModule

Module output
  Global LogFile$, file
  
  Procedure setLogFile(file$)
    If file And IsFile(file)
      CloseFile(file)
      file = #False
    EndIf
    
    LogFile$ = file$
    
    If LogFile$
      file = OpenFile(#PB_Any, LogFile$, #PB_File_Append|#PB_File_NoBuffering)
    EndIf
  EndProcedure
  
  Procedure deleteLogFile()
    Debug "delete debug log file"
    DeleteFile(LogFile$, #PB_FileSystem_Force)
  EndProcedure
  
  Procedure add(str$)
    Protected file
    Debug str$
    If LogFile$
      If file
        str$ = FormatDate("%hh:%ii:%ss", Date()) + " " + str$
        WriteStringN(file, str$)
      EndIf
    EndIf
  EndProcedure
EndModule
; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 21
; Folding = -
; EnableUnicode
; EnableXP