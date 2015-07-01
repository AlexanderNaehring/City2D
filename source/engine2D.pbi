; 2D Engine for City2D

XIncludeFile "output.pbi"

DeclareModule Engine2D
  EnableExplicit
  
  Structure screen
    width.i
    height.i
    depths.i
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
    mouse.position
    hasFocus.i
  EndStructure
  
  Global state.state
  
  ; Public Procedures
  Declare init(*settings)
  Declare.s getLastError()
  Declare screenOpen()
  Declare screenClose()
  Declare nextFrame()
  Declare getMousePosition(*mouse)
  
EndDeclareModule

Module Engine2D
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
  Global userSettings.settings
  Global mouse.position
  
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
  
  
  Procedure mouseThread(*mouse.position)
    Repeat
      If ExamineMouse()
        *mouse\x = MouseX()
        *mouse\y = MouseY()
      EndIf
      Delay(20)
    ForEver
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
    
    CopyStructure(*settings, userSettings, settings)
    
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
    
    If Not InitMouse()
      lastError$ = "Engine2D::init() - error: failed to init mouse!"
      output::add(lastError$)
      ProcedureReturn #False
    EndIf
    
    If Not InitMouse()
      lastError$ = "Engine2D::init() - error: failed to init mouse!"
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
    Protected width, height, depth, screen$
    If Not ExamineDesktops()
      output::add("Engine2D::screenOpen() - error: cannot examine desktops!")
      ProcedureReturn #False
    EndIf
    
    width   = DesktopWidth(0)
    height  = DesktopHeight(0)
    depth   = DesktopDepth(0)
    screen$ = Str(width)+"x"+Str(height);+"x"+Str(depth)
    
    output::add("Engine2D::screenOpen() - open screen: "+screen$)
    
    window = OpenWindow(#PB_Any, 0, 0, width, height, userSettings\title$, #PB_Window_BorderLess)
    OpenWindowedScreen(WindowID(window), 0, 0, width, height, #True, 0, 0, #PB_Screen_NoSynchronization)
    ShowCursor_(0)
    ;OpenScreen(width, height, depth, title$, #PB_Screen_SmartSynchronization)
    SetFrameRate(60)
        
    FlipBuffers()
    
    ProcedureReturn #True 
  EndProcedure
  
  Procedure screenClose()
    output::add("Engine2D::screenClose()")
    CloseScreen()
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
        DrawText(15, 15, Str(fps1\fps) + " fps ("+Str(fps2\fps)+" fps)", RGB(0,0,0))
        
        If Not IsScreenActive()
          Delay(20)
          DrawText(15, 15+20, "PAUSE")
        EndIf
        StopDrawing()
      EndIf
    EndIf
    
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
    ;CopyStructure(mouse, *mouse, position)
    *mouse\x = WindowMouseX(window)
    *mouse\y = WindowMouseY(window)
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.30 (Windows - x64)
; CursorPosition = 150
; FirstLine = 138
; Folding = --
; EnableUnicode
; EnableXP