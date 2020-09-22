Attribute VB_Name = "modDirectX"
Rem // --------------------------------------------------
Rem // |                                                |
Rem // | This is part #3 of the DirectX Tutorial Set    |
Rem // | In this Tutorial you will learn how to render  |
Rem // | a MD2 File / model.. used from the game Quake  |
Rem // |                                                |
Rem // | To exit the Tutorial jus press ESC             |
Rem // |                                                |
Rem // | Resources from: http://www.revolution3d.de     |
Rem // | Website:        http://www.datosoftware.com    |
Rem // |                                                |
Rem // --------------------------------------------------

Rem // This module handles the Direct X Stuff
Rem // In the first 2 Examples there isnt a directx module
Rem // This is beacuse there wasnt a need to use a module so i 'wacked'
Rem // All the code at the top of the form. A Module is now been used
Rem // And when programming games you should use several modules.
Option Explicit

Public DirectX As New DirectX8
Public Direct3D As Direct3D8
Public D3DDevice As Direct3DDevice8
Public DisplaySettings As D3DDISPLAYMODE
Public D3DWindow As D3DPRESENT_PARAMETERS
Public D3DX As New D3DX8

Public matView As D3DMATRIX
Public matWorld As D3DMATRIX
Public matProj As D3DMATRIX

Rem // Declare the const's IP and Radius
Public Const Pi As Single = 3.14159265358979
Public Const Rad As Single = Pi / 180

Rem // Information variables
Public FullScreen As Boolean
Public AppRunning As Boolean

Rem // We just get a hwnd for the InitD3D function, so we need this function to manipulate window state
Public Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long
Public Const SW_NORMAL = 1
Public Const SW_MAXIMIZE = 3

Private Declare Function QueryPerformanceFrequency Lib "kernel32" (lpFrequency As Currency) As Long
Private Declare Function QueryPerformanceCounter Lib "kernel32" (lpPerformanceCount As Currency) As Long

Public Takt As Currency
Public Dauer As Currency


Public Sub InitD3D(wndHandle As Long)
  If FullScreen = False Then
    Rem // We want to run windowed mode, so get the current display format
    Direct3D.GetAdapterDisplayMode D3DADAPTER_DEFAULT, DisplaySettings
    D3DWindow.Windowed = 1
    Rem // Tell D3D to init the device using current display format settings
    D3DWindow.BackBufferFormat = DisplaySettings.Format
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
  D3DWindow.hDeviceWindow = wndHandle
  Rem // How to transfer the backbuffer to the frontbuffer
  D3DWindow.SwapEffect = D3DSWAPEFFECT_FLIP
  Rem // We only need 1 backbuffer
  D3DWindow.BackBufferCount = 1
  D3DWindow.EnableAutoDepthStencil = 1
  Rem // Check for z-buffer format
  D3DWindow.AutoDepthStencilFormat = CheckZBuffer(DisplaySettings)

  Rem // Create the device using HAL (Hardware abstraction layer)
  Set D3DDevice = Direct3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DWindow.hDeviceWindow, CheckHardwareTL(), D3DWindow)
  If D3DDevice Is Nothing Then Debug.Print "Direct3D-Device NOT FOUND"
  Rem // let windows catch back up to the program.
  DoEvents
  
  If FullScreen = False Then
    Call ShowWindow(wndHandle, SW_NORMAL)
  Else
    Call ShowWindow(wndHandle, SW_MAXIMIZE)
  End If
End Sub

Rem // This constructs a simple Direct 3D vector
Public Function VEC3(ByVal vX As Single, ByVal vY As Single, ByVal vZ As Single) As D3DVECTOR
  VEC3.x = vX
  VEC3.y = vY
  VEC3.Z = vZ
End Function


Public Function CheckHardwareTL() As Long
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

Rem // The Timing function
Public Function QPTimer() As Currency
  If Takt = 0 Then
    Rem // Get the frequency
    QueryPerformanceFrequency Takt
  End If
  
  Rem // get the current time value
  QueryPerformanceCounter Dauer
  
  Rem // calculate current time in seconds
  QPTimer = Dauer / Takt
End Function
