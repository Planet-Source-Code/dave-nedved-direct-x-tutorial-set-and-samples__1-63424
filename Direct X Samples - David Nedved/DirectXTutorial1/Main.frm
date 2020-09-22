VERSION 5.00
Begin VB.Form frmMain 
   BackColor       =   &H00000000&
   Caption         =   "DirectX Tutorial #1"
   ClientHeight    =   9000
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   12000
   LinkTopic       =   "Form1"
   ScaleHeight     =   600
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   800
   StartUpPosition =   3  'Windows Default
   WindowState     =   2  'Maximized
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Rem // --------------------------------------------------
Rem // |                                                |
Rem // | This is part #1 of the DirectX Tutorial Set    |
Rem // | In this Tutorial you will learn how to setup a |
Rem // | Direct 3D Device and how to clear the screen   |
Rem // |                                                |
Rem // | To exit the Tutorial jus press ESC             |
Rem // |                                                |
Rem // | Coded by David Nedved                          |
Rem // | Resources from: http://www.revolution3d.de     |
Rem // | Website:        http://www.datosoftware.com    |
Rem // | Email:          dnedved@datosoftware.com       |
Rem // |                                                |
Rem // --------------------------------------------------


Option Explicit

Rem // main DX object
Private DirectX As New DirectX8
Rem // main D3D object
Private Direct3D As Direct3D8
Rem // the D3D device represents the hardware we are using for 3D rendering
Private D3Ddevice As Direct3DDevice8
Rem // The display settings structure (important to get current display settings)
Private DisplaySettings As D3DDISPLAYMODE
Rem // The Window parameters (tells d3d which properties the device should have)
Private D3DWindow As D3DPRESENT_PARAMETERS

Rem // The D3DX helper library (very usefull!)
Private D3DX As New D3DX8

Rem // The main matrices (not used yet, take a look at the next tutorial)
Private matView As D3DMATRIX
Private matWorld As D3DMATRIX
Private matProj As D3DMATRIX

Rem // Information variables
Private FullScreen As Boolean
Private AppRunning As Boolean

Private Sub InitD3D()
  If FullScreen = False Then
    Rem // We want to run windowed mode, so get the current display format
    Direct3D.GetAdapterDisplayMode D3DADAPTER_DEFAULT, DisplaySettings
    D3DWindow.Windowed = 1
    Rem // Tell D3D to init the device using current display format settings
    D3DWindow.BackBufferFormat = DisplaySettings.Format
    D3DWindow.BackBufferWidth = Me.ScaleWidth
    D3DWindow.BackBufferHeight = Me.ScaleHeight
  Else
    Rem // Some old voodoo cards doesn't support 32 bit, so better check if 32 bit gfx is available
    If Direct3D.CheckDeviceType(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_X8R8G8B8, D3DFMT_X8R8G8B8, False) >= 0 Then
      Rem // 32 bit
      DisplaySettings.Format = D3DFMT_X8R8G8B8
    Else
      Rem // 16 bit display mode
      DisplaySettings.Format = D3DFMT_R5G6B5
    End If
    Rem // Screen resolution
    DisplaySettings.Width = 800
    Rem // 800x600 should always work, in advanced games you can make this read from a settings file, where you can config the game
    DisplaySettings.Height = 600
    Rem // Put the values into the D3DPRESENT_PARAMETERS structure
    D3DWindow.BackBufferFormat = DisplaySettings.Format
    D3DWindow.BackBufferWidth = DisplaySettings.Width
    D3DWindow.BackBufferHeight = DisplaySettings.Height
    Rem // This should deactivate vsync (could cause flickering images)
    D3DWindow.FullScreen_PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE
  End If
  
  Rem // The handle of our rendering window
  D3DWindow.hDeviceWindow = Me.hWnd
  Rem // How to transfer the backbuffer to the frontbuffer
  D3DWindow.SwapEffect = D3DSWAPEFFECT_FLIP
  Rem // We only need 1 backbuffer
  D3DWindow.BackBufferCount = 1
  D3DWindow.EnableAutoDepthStencil = 1
  Rem // Check for z-buffer format
  D3DWindow.AutoDepthStencilFormat = CheckZBuffer(DisplaySettings)

  Rem // Create the device using HAL (Hardware abstraction layer)
  Set D3Ddevice = Direct3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DWindow.hDeviceWindow, CheckHardwareTL(), D3DWindow)
  If D3Ddevice Is Nothing Then Debug.Print "Direct3D-Device NOT FOUND"
  Rem // let windows catch back up to the program.
  DoEvents

  If FullScreen = False Then
    Me.WindowState = vbNormal
    Me.Show
  End If

  Rem // enter the main loop, this loop will run as long as AppRunning stays true
  Rem // so we just have to set AppRunning to false and the app will shut down
  Rem // If you'd shut down the app event based (e.g. button click event) it's possible that
  Rem // you'll get an automatisation error
  AppRunning = True
  Do While AppRunning
    Rem // Check if our device is ready for rendering
    If D3Ddevice.TestCooperativeLevel = D3DERR_DEVICELOST Then
      Rem // Device was lost
      Do
        If D3Ddevice.TestCooperativeLevel = D3DERR_DEVICENOTRESET Then
          Rem // Device needs to be reset
          D3Ddevice.Reset D3DWindow
          Exit Do
        End If
        DoEvents
      Loop
    End If
    
    Rem // Clear the buffer to the Selected Color (For blue use "&HFF" or Black use "&H0&")
    D3Ddevice.Clear 0, ByVal 0, D3DCLEAR_TARGET Or D3DCLEAR_ZBUFFER, &HFF, 1, 0
    D3Ddevice.BeginScene

    D3Ddevice.EndScene
    Rem // Present the resulting image to the screen
    D3Ddevice.Present ByVal 0, ByVal 0, 0, ByVal 0
    Rem // Give windows some time to handle other processes (your app would crash if you'd remove this)
    DoEvents
  Loop

Rem // Clean up everything
  Set D3Ddevice = Nothing
  Set D3DX = Nothing
  Set Direct3D = Nothing
  Set DirectX = Nothing
  End
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
Rem // Exit the DirectX Application
  If KeyCode = vbKeyEscape Then
    AppRunning = False
  End If
End Sub

Private Sub Form_Load()
Rem // Ask user if they want to run the application in full screen or windowed mode.
Rem // I generally remove this when Publishing a game, but i run the game in windowed mode for Debugging it.
  
  Dim result As VbMsgBoxResult

  Set Direct3D = DirectX.Direct3DCreate()

  result = MsgBox("Click Yes to go to full screen (Recommended)", vbQuestion Or vbYesNo, "Options")
  If result = vbYes Then
    FullScreen = True
  Else
    FullScreen = False
  End If
Rem // Call the Function to InitD3D
  InitD3D
End Sub

Private Function CheckHardwareTL() As Long
Rem // A Handy helper function to get the device caps
Dim DevCaps As D3DCAPS8
Direct3D.GetDeviceCaps D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, DevCaps

If (DevCaps.DevCaps And D3DDEVCAPS_HWTRANSFORMANDLIGHT) Then
CheckHardwareTL = D3DCREATE_HARDWARE_VERTEXPROCESSING
Else
CheckHardwareTL = D3DCREATE_SOFTWARE_VERTEXPROCESSING
End If
End Function

Public Function CheckZBuffer(mode As D3DDISPLAYMODE) As Long
Rem // Another handy helper to check the ZBuffer mode
If Direct3D.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, mode.Format, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D16) = D3D_OK Then
CheckZBuffer = D3DFMT_D16
End If
        
If Direct3D.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, mode.Format, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D16_LOCKABLE) = D3D_OK Then
CheckZBuffer = D3DFMT_D16_LOCKABLE
End If
        
If Direct3D.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, mode.Format, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D24S8) = D3D_OK Then
CheckZBuffer = D3DFMT_D24S8
End If
        
If Direct3D.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, mode.Format, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D24X4S4) = D3D_OK Then
CheckZBuffer = D3DFMT_D24X4S4
End If
        
If Direct3D.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, mode.Format, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D24X8) = D3D_OK Then
CheckZBuffer = D3DFMT_D24X8
End If
        
If Direct3D.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, mode.Format, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D32) = D3D_OK Then
CheckZBuffer = D3DFMT_D32
End If
End Function

Private Sub Form_Unload(Cancel As Integer)
Rem // Prevent the form from getting unloaded
Cancel = 1
Rem // So we can shut down everything ourself
AppRunning = False
End Sub
