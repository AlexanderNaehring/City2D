; 2D Engine for City2D

XIncludeFile "output.pbi"

DeclareModule Engine2D
  EnableExplicit
  
  Structure settings
    
  EndStructure
  
  ; Public Procedures
  Declare init()
  Declare.s getLastError()
  Declare screenOpen(title$ = "")
  Declare screenClose()
  Declare nextFrame()
  
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
  
  
  ; Public Procedures
  Procedure init()
    output::add("Engine2D::init()")
    
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
  
  Procedure screenOpen(title$ = "")
    Protected width, height, depth, screen$
    If Not ExamineDesktops()
      output::add("Engine2D::screenOpen() - error: cannot examine desktops!")
      ProcedureReturn #False
    EndIf
    
    width   = DesktopWidth(0)
    height  = DesktopHeight(0)
    depth   = DesktopDepth(0)
    screen$ = Str(width)+"x"+Str(height)+"x"+Str(depth)
    
    output::add("Engine2D::screenOpen() - open screen: "+screen$)
    
    window = OpenWindow(#PB_Any, 0, 0, width, height, title$, #PB_Window_BorderLess)
    OpenWindowedScreen(WindowID(window), 0, 0, width, height, #True, 0, 0, #PB_Screen_NoSynchronization)
    ;OpenScreen(width, height, depth, title$, #PB_Screen_SmartSynchronization)
    ; SetFrameRate(120)
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
    
    ;------------------------------------
    
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
    
    
;     Static Dim fps(60), counter
;     Protected fps_avg, i, sum, num
    
    ; Calculate avg fps from last 60 frames
;     If counter > 60 : counter = 1 : EndIf
;     fps(counter) = fps
;     counter + 1
;     For i = 1 To 60
;       sum + fps(i)
;     Next
;     fps_avg = sum/60
    
    ; Calculate avg fps from last 60 frames only using fps > 0
;     If counter > 60 : counter = 1 : EndIf
;     fps(counter) = fps
;     counter + 1
;     For i = 1 To 60
;       If fps(i) : sum + fps(i) : EndIf
;     Next
;     If num
;       fps_avg = sum/num
;     EndIf
    
    ; print some debug info
    output = ScreenOutput()
    If output
      If StartDrawing(output)
        DrawText(10, 10, FormatDate("%hh:%ii:%ss", Date()))
        DrawText(10, 30, Str(fps1\fps) + " fps ("+Str(fps2\fps)+" fps)")
        
        If Not IsScreenActive()
          Delay(20)
          DrawText(10, 70, "PAUSE")
        EndIf
        StopDrawing()
      EndIf
    EndIf
    
    ; send frame to screen
    FlipBuffers()
;     Delay(0)
    ClearScreen(0)
    
    ; calculate time since last frame
    deltaT = currentTime - lastFrameTime
    lastFrameTime = currentTime
    
    ProcedureReturn deltaT
  EndProcedure
  
  
EndModule

; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 182
; FirstLine = 140
; Folding = --
; EnableUnicode
; EnableXP