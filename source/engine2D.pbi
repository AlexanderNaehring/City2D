; 2D Engine for City2D

XIncludeFile "output.pbi"

DeclareModule Engine2D
  EnableExplicit
  
;   Enumeration
;     #ScreenMode_WindowedFullScreen
;     #ScreenMode_Windowed
;   EndEnumeration
  
  Structure screen
    width.i
    height.i
    depth.i
    maxfps.i
;     mode.i
  EndStructure
  
  Structure settings
    screen.screen
    title$
  EndStructure
  
  Structure position
    x.i
    y.i
  EndStructure
  
  Structure state
    userSettings.settings
    hasFocus.i    ; does the screen has the focus?
    deltaT.i      ; time since last frame update
    mouse.position
  EndStructure
  
  Global state.state
  
  ; Public Procedures
  Declare init(*settings)
  Declare.s getLastError()
  Declare screenOpen()
  Declare screenClose()
  Declare nextFrame()
  Declare getMousePosition(*mouse.position)
  Declare getMouseX()
  Declare getMouseY()
  Declare loadGraphic(name$, file$, width = 0, height = 0)
  Declare displayGraphic(name$, x, y)
  Declare displayTransparentGraphic(name$, x, y, intensity = 255, color = -1)
  Declare setCursor(name$)
  Declare renderGUI()
EndDeclareModule

Module Engine2D
  
  #CursorSize = 50
  
  ; private Structures
  Structure fps
    lastTime.i    ; [ms]
    currentTime.i ; [ms]
    interval.i    ; [ms]
    frameCount.i  ; int
    fps.i         ; int
  EndStructure
  
  ; Private variables
  Global lastError$
  Global window
  Global initialized = #False
  Global NewMap graphics()
  Global cursor
;   Global mouse.position
  
  ; Private Procedures
  Procedure updateFPS(*fps.fps)
    With *fps
      If \lastTime + \interval < \currentTime
        \fps = \frameCount * 1000 / (\currentTime - \lastTime)
        \lastTime = \currentTime
        \frameCount = 0
      EndIf
      \frameCount + 1
    EndWith
  EndProcedure
  
  Procedure updateMousePosition(*mouse.position)
    Protected x, y, win
    
    Repeat
      win = window
      If Not win
        Break
      EndIf
      
      x = WindowMouseX(win)
      y = WindowMouseY(win)
      If x <> -1 And y <> -1
        *mouse\x = x
        *mouse\y = y
      EndIf
      Delay(1)
    ForEver
  EndProcedure
  
  Procedure displayCursor()
    If cursor
      If IsSprite(cursor)
        DisplayTransparentSprite(cursor, state\mouse\x - #CursorSize/2, state\mouse\y - #CursorSize/2)
      Else
        cursor = 0
      EndIf
    EndIf
  EndProcedure
  
  ; Public Procedures
  Procedure init(*settings)
    output::add("Engine2D::init()")
    
    If initialized
      lastError$ = "Engine2D::init() - error: engine can only be initialized once!"
      output::add(lastError$)
      ProcedureReturn #False
    EndIf
    initialized = #True
    
    CopyStructure(*settings, state\userSettings, settings)
    
    UsePNGImageDecoder()
    
    If Not InitSprite()
      lastError$ = "Engine2D::init() - error: failed to init graphics!"
      output::add(lastError$)
      ProcedureReturn #False
    EndIf
    
    If Not InitKeyboard()
      lastError$ = "Engine2D::init() - error: failed to init keyboard!"
      output::add(lastError$)
      ProcedureReturn #False
    EndIf
    
    If Not InitSound()
      lastError$ = "Engine2D::init() - error: failed to init sound!"
      output::add(lastError$)
      ; error not fatal, do not return false
    EndIf
    
    ProcedureReturn #True 
  EndProcedure
  
  Procedure.s getLastError()
    ProcedureReturn lastError$
  EndProcedure
  
  Procedure screenOpen()
    Protected screen$
    If Not ExamineDesktops()
      lastError$ = "Engine2D::screenOpen() - error: cannot examine desktops!"
      output::add(lastError$)
      ProcedureReturn #False
    EndIf
    
    With state\userSettings\screen
      If Not \width
        \width = DesktopWidth(0)
      EndIf
      If Not \height
        \height = DesktopHeight(0)
      EndIf
      If Not \depth
        \depth = DesktopDepth(0)
      EndIf
      
      Select \maxfps
        Case 25, 30, 60, 120, 144
        Default
          \maxfps = 0
      EndSelect
      
      screen$ = Str(\width)+"x"+Str(\height)+"x"+Str(\depth)
      If \maxfps
        screen$ + " @"+Str(\maxfps)+" fps"
      EndIf
    EndWith
    
    output::add("Engine2D::screenOpen() - open screen: "+screen$)
  
    window = OpenWindow(#PB_Any, 0, 0, state\userSettings\screen\width, state\userSettings\screen\height, state\userSettings\title$, #PB_Window_BorderLess)
    If Not window
      lastError$ = "Engine2D::screenOpen() - error: cannot open window!"
      output::add(lastError$)
      ProcedureReturn #False
    EndIf
    
    If Not OpenWindowedScreen(WindowID(window), 0, 0, state\userSettings\screen\width, state\userSettings\screen\height, #True, 0, 0, #PB_Screen_NoSynchronization)
      lastError$ = "Engine2D::screenOpen() - error: cannot open screen!"
      output::add(lastError$)
      CloseWindow(window)
      window = 0
      ProcedureReturn #False
    EndIf
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ShowCursor_(0) ; hide cursor while over window
      CompilerCase #PB_OS_Linux
        ; TODO
      CompilerCase #PB_OS_MacOS
        ; TODO
    CompilerEndSelect
    
    If state\userSettings\screen\maxfps
      SetFrameRate(state\userSettings\screen\maxfps - 1)
    EndIf
    FlipBuffers()
    
    CreateThread(@updateMousePosition(), state\mouse)
    
    ProcedureReturn #True 
  EndProcedure
  
  Procedure screenClose()
    Protected win
    output::add("Engine2D::screenClose()")
    
    ; locally store window ID
    win = window
    
    ; set global window ID to zero, indicating window will close
    window = 0
    Delay(100)
    
    ; hide window
    HideWindow(win, #True)
    
    ; close screen
    CloseScreen()
    
    ; close window
    CloseWindow(win)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure nextFrame()
    Protected output, event, currentTime, deltaT
    Static lastFrameTime
    Static.fps fps1, fps2
    
    If Not lastFrameTime ; only do this once (when lastFrameTime is not initialized yet)
      fps1\interval = 100  ; every 100 ms
      fps2\interval = 1000 ; every second
      lastFrameTime = ElapsedMilliseconds()
    EndIf
        
    Repeat ; finish all window events
      event = WindowEvent()
      If event = #PB_Event_CloseWindow
        End
      EndIf
    Until event = 0
    
    ; calculate FPS
    currentTime = ElapsedMilliseconds()
    fps1\currentTime = currentTime
    fps2\currentTime = currentTime
    updateFPS(fps1)
    updateFPS(fps2)
    
    ; print some debug info
    
    output = ScreenOutput()
    If output
      If StartDrawing(output)
        Box(10, 10, 200, 50, RGB(255,255,255))
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(15, 15, Str(fps1\fps) + " fps ("+Str(fps2\fps)+" fps)", #Black)
        DrawText(15, 35, "hasFocus = "+Str(state\hasFocus), #Black)
        StopDrawing()
      EndIf
    EndIf
    
    state\hasFocus = IsScreenActive()
    
    ; send frame to screen
    FlipBuffers()
;     Delay(10)
    ClearScreen(0)
    
    ; calculate time since last frame
    deltaT = currentTime - lastFrameTime
    lastFrameTime = currentTime
    
    ProcedureReturn deltaT
  EndProcedure
  
  Procedure getMousePosition(*mouse.position)
    *mouse\x = state\mouse\x
    *mouse\y = state\mouse\y
  EndProcedure
  
  Procedure getMouseX()
    ProcedureReturn state\mouse\x
  EndProcedure
  
  Procedure getMouseY()
    ProcedureReturn state\mouse\y
  EndProcedure
  
  Procedure loadGraphic(name$, file$, width = 0, height = 0)
    Protected sprite
    
    If FindMapElement(graphics(), name$)
      output::add("Engine2D::loadGraphic() - graphic with name {"+name$+"} already loaded!")
      ProcedureReturn #False
    EndIf
    
    sprite = LoadSprite(#PB_Any, file$, #PB_Sprite_AlphaBlending)
    If Not sprite
      output::add("Engine2D::loadGraphic() - error: could not load {"+name$+"} from file {"+file$+"}")
      ProcedureReturn #False
    EndIf
    
    If width And height
      ZoomSprite(sprite, width, height)
    EndIf
    
    graphics(name$) = sprite
    ProcedureReturn #True
  EndProcedure
  
  Procedure displayGraphic(name$, x, y)
    Protected sprite
    If FindMapElement(graphics(), name$)
      sprite = graphics(name$)
      If IsSprite(sprite)
        DisplaySprite(sprite, x, y)
      EndIf
    EndIf
  EndProcedure
  
  Procedure displayTransparentGraphic(name$, x, y, intensity = 255, color = -1)
    Protected sprite
    If FindMapElement(graphics(), name$)
      sprite = graphics(name$)
      If IsSprite(sprite)
        If color = -1
          DisplayTransparentSprite(sprite, x, y, intensity)
        Else
          DisplayTransparentSprite(sprite, x, y, intensity, color)
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  Procedure setCursor(name$)
    Protected sprite
    If FindMapElement(graphics(), name$)
      sprite = graphics(name$)
      If IsSprite(sprite)
        ZoomSprite(sprite, #CursorSize, #CursorSize)
        cursor = sprite
      EndIf
    EndIf
  
  EndProcedure
  
  Procedure renderGUI()
    
    displayCursor()
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 206
; FirstLine = 105
; Folding = DCi-
; EnableUnicode
; EnableXP