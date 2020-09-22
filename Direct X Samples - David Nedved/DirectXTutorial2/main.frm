VERSION 5.00
Begin VB.Form frmMain 
   BackColor       =   &H00000000&
   Caption         =   "DirectX Tutorial #2"
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
Rem // -----------------------------------------------------
Rem // |                                                   |
Rem // | This is part #2 of the DirectX Tutorial Set       |
Rem // | In this Tutorial you will learn how to setup a    |
Rem // | Direct 3D Device and how to clear the screen      |
Rem // | You will also learn how to render simple objects  |
Rem // |                                                   |
Rem // | To exit the Tutorial jus press ESC                |
Rem // |                                                   |
Rem // | Coded by David Nedved                             |
Rem // | Resources from: http://www.revolution3d.de        |
Rem // | Website:        http://www.datosoftware.com       |
Rem // | Email:          dnedved@datosoftware.com          |
Rem // |                                                   |
Rem // -----------------------------------------------------


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

Rem // The main matrices
Private matView As D3DMATRIX
Private matWorld As D3DMATRIX
Private matProj As D3DMATRIX

Rem // The vertex structure storing the points informations
Private Type LITVERTS
  Rem // The position
  p As D3DVECTOR
  Rem // The color
  c As Long
End Type

Rem // The triangle
Rem // 0,1,2 - 3 points
Private MyTriangle(2) As LITVERTS

Rem // The FVF - it tells d3d what data it has to process
Private Const LITVERTS_FVF As Long = D3DFVF_XYZ Or D3DFVF_DIFFUSE

Rem // We want to rotate the triangle around the y axis so that we could see it from all sides
Rem // this variable stores the current rotation
Private rotation As Single

Rem // Declare the const's IP and Radius
Private Const Pi As Single = 3.14159265358979
Private Const Rad As Single = Pi / 180

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
  
  Rem // Set the world matrix to it's identity state and give it to the device
  D3DXMatrixIdentity matWorld
  D3Ddevice.SetTransform D3DTS_WORLD, matWorld
  
  Rem // Create the view matrix and give it to the device
  Rem // The camera is placed at (0,0,20)
  Rem // The camera is pointing to (0,0,0)
  D3DXMatrixLookAtLH matView, VEC3(0, 0, 20), VEC3(0, 0, 0), VEC3(0, 1, 0)
  D3Ddevice.SetTransform D3DTS_VIEW, matView
  
  Rem // The projections matrix
  Rem // The second parameter is the fov (field of view)
  D3DXMatrixPerspectiveFovLH matProj, D3DWindow.BackBufferWidth / D3DWindow.BackBufferHeight, 1, 0.1, 5000
  D3Ddevice.SetTransform D3DTS_PROJECTION, matProj
  
  Rem // Create the triangle verts, the makelitvert function is just an wrapper to make creation easier
  MyTriangle(0) = MakeLitVert(0, 10, 0, D3DColorARGB(255, 255, 0, 0))
  MyTriangle(1) = MakeLitVert(-10, -10, 0, D3DColorARGB(255, 0, 255, 0))
  MyTriangle(2) = MakeLitVert(10, -10, 0, D3DColorARGB(255, 0, 0, 255))

  Rem // This setting makes it possible to see the triangle from both sides
  Rem // An triangle is usually defined in clockwise point order, you could also set
  Rem // the culling to cull out all counter clockwise polygons by setting it to
  Rem // D3DCULL_CCW or by setting it to D3DCULL_CW to cull all clockwise defined
  Rem // polygons
  D3Ddevice.SetRenderState D3DRS_CULLMODE, D3DCULL_NONE
  Rem // Turn off D3Ds light engine because we want to use our vertex colors
  Rem // When turning this on our triangle will appear black because we didnt
  Rem // define any normal vectors for it (Normal=the direction a point is facing to)
  D3Ddevice.SetRenderState D3DRS_LIGHTING, 0


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
    D3Ddevice.Clear 0, ByVal 0, D3DCLEAR_TARGET Or D3DCLEAR_ZBUFFER, D3DColorARGB(255, 0, 0, 100), 1, 0
    D3Ddevice.BeginScene
    
    Rem // Add 0.1 degree to our rotation
    rotation = rotation + 0.1
    Rem // If you'd remove this check and let the app run like 1h or so it'll crash because of an overflow error.
    If rotation >= 360 Then rotation = 0
    
    Rem // Convert degree to radians and calculate the Y rotation matrix
    D3DXMatrixRotationY matWorld, rotation * Rad
    Rem // Set the matrix to the device
    D3Ddevice.SetTransform D3DTS_WORLD, matWorld
    
    Rem // Set the vertex shader - it's actually our FVF, not an real vertex shader
    D3Ddevice.SetVertexShader LITVERTS_FVF
    Rem // Draw the triangle
    D3Ddevice.DrawPrimitiveUP D3DPT_TRIANGLELIST, 1, MyTriangle(0), 16

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

'Constructs our custom point
Private Function MakeLitVert(ByVal vX As Single, ByVal vY As Single, ByVal vZ As Single, ByVal vC As Single) As LITVERTS
  MakeLitVert.p.x = vX
  MakeLitVert.p.y = vY
  MakeLitVert.p.z = vZ
  MakeLitVert.c = vC
End Function

Private Function VEC3(ByVal vX As Single, ByVal vY As Single, ByVal vZ As Single) As D3DVECTOR
Rem // Construct a simple Direct 3D vector
  VEC3.x = vX
  VEC3.y = vY
  VEC3.z = vZ
End Function

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
