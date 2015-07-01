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

Define settings.Engine2D::settings
settings\screen\width = 0   ; use value from primary desktop
settings\screen\height = 0  ; use value from primary desktop
settings\screen\depths = 0  ; use value from primary desktop
settings\title$ = "City2D"

If Not Engine2D::init(settings)
  MessageRequester("Error", Engine2D::getLastError())
  End
EndIf
If Not Engine2D::screenOpen()
  MessageRequester("Error", Engine2D::getLastError())
EndIf



Repeat
  
  Define mouse.Engine2D::position
  Engine2D::getMousePosition(mouse)
  
  StartDrawing(ScreenOutput())
  Box(mouse\x, mouse\y, 10, 10, #red)
  StopDrawing()
  
  ExamineKeyboard()
  If KeyboardPushed(#PB_Key_Escape)
    Break
  EndIf
  
  
  
  
  Engine2D::nextFrame()
ForEver

Engine2D::screenClose()
End

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 41
; EnableUnicode
; EnableXP