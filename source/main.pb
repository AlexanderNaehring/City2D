; City2D
; Alexander Nähring

EnableExplicit

XIncludeFile "output.pbi"
XIncludeFile "engine2D.pbi"


; get launch option
Define i
Define parameter$
For i = 1 To CountProgramParameters()
  parameter$ = ProgramParameter()
  If LCase(parameter$) = "-log"
    output::setLogFile("output-log.txt")
  EndIf
Next

If Not Engine2D::init()
  MessageRequester("Error", Engine2D::getLastError())
  End
EndIf
If Not Engine2D::screenOpen("City2D")
  MessageRequester("Error", Engine2D::getLastError())
EndIf



Repeat
  Engine2D::nextFrame()
ForEver

Engine2D::screenClose()
End

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 29
; EnableUnicode
; EnableXP