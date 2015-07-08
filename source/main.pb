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

output::add("current directory: "+GetCurrentDirectory())

Define settings.Engine2D::settings
; settings\screen\mode    = Engine2D::#ScreenMode_WindowedFullScreen
settings\screen\width   = 0  ; use value from primary desktop
settings\screen\height  = 0  ; use value from primary desktop
settings\screen\depth   = 0  ; use value from primary desktop
settings\screen\maxfps  = 120
settings\title$ = "City2D"

If Not Engine2D::init(settings)
  MessageRequester("Error", Engine2D::getLastError())
  End
EndIf
If Not Engine2D::screenOpen()
  MessageRequester("Error", Engine2D::getLastError())
  End
EndIf


Engine2D::loadGraphic("cursor", "../data/graphics/cursors/cursor.png")

Engine2D::setCursor("cursor")

Repeat
  
  ExamineKeyboard()
  If KeyboardPushed(#PB_Key_Escape)
    Break
  EndIf
  
  Engine2D::renderGUI()
  
  Engine2D::nextFrame()
ForEver

Engine2D::screenClose()
End

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 35
; EnableUnicode
; EnableXP