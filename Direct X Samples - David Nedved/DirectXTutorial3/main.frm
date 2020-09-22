VERSION 5.00
Begin VB.Form frmMain 
   BackColor       =   &H00000000&
   Caption         =   "DirectX Tutorial #3"
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

Option Explicit

Rem // The model itself
Private MD2Model As New Cls_MD2
Rem // The models weapon
Private MD2Weapon As New Cls_MD2

Private Sub MainLoop()
  Rem // Clear world matrix
  D3DXMatrixIdentity matWorld
  D3DDevice.SetTransform D3DTS_WORLD, matWorld
  Rem // Set up direct x camera
  D3DXMatrixLookAtLH matView, VEC3(50, 0, 0), VEC3(0, 0, 0), VEC3(0, 1, 0)
  D3DDevice.SetTransform D3DTS_VIEW, matView
  Rem // Set up perspective
  D3DXMatrixPerspectiveFovLH matProj, 800 / 600, 1, 0.1, 5000
  D3DDevice.SetTransform D3DTS_PROJECTION, matProj
  Rem // turn Lights off
  D3DDevice.SetRenderState D3DRS_LIGHTING, 0
  Rem // Linear texture filter
  D3DDevice.SetTextureStageState 0, D3DTSS_MAGFILTER, D3DTEXF_LINEAR
  D3DDevice.SetTextureStageState 0, D3DTSS_MINFILTER, D3DTEXF_LINEAR
  D3DDevice.SetTextureStageState 0, D3DTSS_MIPFILTER, D3DTEXF_LINEAR

  Rem // Our PCX loading routine could ONLY handle original Quake2 textures (8 bit pcx)
  Rem // but it could load all other D3DX compatible textures as well
  Rem // The following will load the quake 2 model and texture
  If MD2Model.LoadMD2("Resources\tris.md2") And MD2Model.LoadMD2Texture("Resources\blade.pcx") Then
    If MD2Weapon.LoadMD2("Resources\w_machinegun.md2") And MD2Weapon.LoadMD2Texture("Resources\w_machinegun.pcx") Then
      Rem // The model is ready
      AppRunning = True
    End If
  End If
  
  Rem // Step into the mainloop
  Do While AppRunning
    Rem // Test device
    If D3DDevice.TestCooperativeLevel = D3DERR_DEVICELOST Then
      Rem // The Device was lost
      Do
        If D3DDevice.TestCooperativeLevel = D3DERR_DEVICENOTRESET Then
          Rem // The Device needs to be reset
          D3DDevice.Reset D3DWindow
          Exit Do
        End If
        DoEvents
      Loop
    End If
    
    Rem // Clear the buffer to the Selected Color (For blue use "&HFF" or Black use "&H0&")
    D3DDevice.Clear 0, ByVal 0, D3DCLEAR_TARGET Or D3DCLEAR_ZBUFFER, D3DColorARGB(255, 0, 0, 100), 1, 0
    D3DDevice.BeginScene
    
    Rem // Render MD2 (the weapon is passed here because its animation needs to get synchronized with the players animation)
    MD2Model.Render MD2Weapon, 0, 0, 0, 0, 0, False
   
    D3DDevice.EndScene
    Rem // Present the resulting image to the screen
    D3DDevice.Present ByVal 0, ByVal 0, 0, ByVal 0
    Rem // Give windows some time to handle other processes (your app would crash if you'd remove this)
    DoEvents
  Loop

Rem // Clean up everything
  Set D3DDevice = Nothing
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
  InitD3D Me.hwnd
  InitLightNormals
  Rem // Lets call our main function
  MainLoop
End Sub

Private Sub Form_Unload(Cancel As Integer)
Rem // Prevent the form from getting unloaded
Cancel = 1
Rem // So we can shut down everything ourself
AppRunning = False
End Sub
