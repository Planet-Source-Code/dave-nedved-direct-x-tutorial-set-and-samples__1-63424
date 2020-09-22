VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Cls_MD2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
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
Rem // | Author:         Russel Taylor                  |
Rem // | Author Website: www.solarsplace.com            |
Rem // | Animation:      Marius Schmidt                 |
Rem // | Animation Web:  www.matrixvb.da.ru             |
Rem // |                                                |
Rem // --------------------------------------------------


Option Explicit

Rem // Information-Header
Rem // Holds the position and size of the data sections
Private Type ModelHeaderData
    magic As String * 4             'identifies the file as QuakeII-file("IDP2")
    Version As Long                 'should always be 8
    SkinWidth As Long               'width of the texture
    SkinHeight As Long              'height of the texture
    FrameSize As Long               'size of an animation frame (in bytes)
    NumSkins As Long                'texture count
    NumVertices As Long             'point count
    numTexCoords As Long            'texture coordinate count
    NumTris As Long                 'polygon count
    NumGLcmds As Long               'GL-commands were used for OGL rendering optimizations
    NumFrames As Long               'frame count
    OffsetSkins As Long             'offset to the textur-names (1 name = 64bytes)
    offsetTexCoords As Long         'offset to the texture s-t values
    OffsetTris As Long              'offset to the indicies
    OffsetFrames As Long            'offset to the frame-data
    OffsetGLcmds As Long            'offset to the GL-commands
    OffsetEnd As Long               'end of the file -> filesize
End Type
Private ModelHeader As ModelHeaderData


Rem // Non transformed data
Rem // Used for transforming/animating the frames

Rem // MD2 coordinates are saved as bytes and get transformed into
Rem // floating point values by multiplication by an scaling factor.
Rem // This way of saving the vertices saves up a lot of data space but
Rem // also has the effect of making the object look wobbly (because
Rem // the precision is too low)
Private Type ByteVert
Rem // The order of the coordinates is quite important
    x As Byte
    Z As Byte
    y As Byte
    NormalIndex As Byte
End Type
Rem // This structure holds the points of each frames
Private Type FramePointData
     FrameName As String * 16   'The name of the frame
     verts() As ByteVert        'Byte vertices
     SngVerts() As MDLVERTEX    'Floating point vertices (converted from byte vertices)
     ScaleFac As D3DVECTOR      'The scaling factor (used to transform the byte coords into floating point)
     Translate As D3DVECTOR     'Translation of the frame
End Type
Rem // The length of the array is the number of vectors.
Rem // The array holds the byte coordinates and all the data
Rem // we need to convert the byte coordinates to floating point
Rem // coordinates.
Private FramePoints() As FramePointData


Rem // Transformed texture coordinates
Rem // gets calculated whilst loading the model

Rem // Each vertex of the object has an texture coordinate.
Rem // The number of texture coordinates is not always the same as the
Rem // number of vertices.
Private TexCoord() As D3DVECTOR2


Rem // The indicies
Rem // Each index points to a texture coordinate or vector

Rem // We need the Indicies() array to render our object. Each vertex index ("VertIndex(2)")
Rem // points to a point in FramePoints(FrameID).verts()-array and 3 of them build up a polygon
Private Type ind
    VertIndex(2) As Integer
    TexIndex(2) As Integer
End Type
Private Indicies() As ind


Rem // Our calculated frame - the result
Private Type Frame
    Rem // Name of the frame (comes from FramePoints)
    FrameName As String
    Rem // Current animation status (percent)
    AnimationStatus As Single
    Rem // What is the current frame we interpolate from?
    FrameIDFrom As Long
    Rem // What will be the next frame? (normally FrameIDFrom+1, but the animation can change.)
    FrameIDTo As Long
    FrameIDTo2 As Long
    FrameIDTo3 As Long
    Rem // Holds the current geometry data
    VBuffer As Direct3DVertexBuffer8
End Type
Rem // The current frame
Private CurFrame As Frame


Rem // The texture for the model
Public Texture As Direct3DTexture8
Public bUseTexture As Boolean

Rem // Temp vectors (used whilst loading the polygon data)
Private v1New As D3DVECTOR
Private v2New As D3DVECTOR
Private v3New As D3DVECTOR

Rem // This array holds the result of our animation calculations (only temporary)
Private VertData() As MDLVERTEX

Rem // Variables for frame calculations
Private TempFrameSearchCount As Long
Public FramePrefix As String

Public AnimType As Long
Public MD2AnimSpeed As Long
Public Loaded As Boolean

Rem // These vectors represent the model borders
Private mMin As D3DVECTOR
Private mMax As D3DVECTOR

Rem // Helper variables
Private CountVar As Long
Private LastUpdate As Currency

Rem // This function loads the MD2 texture
Public Function LoadMD2Texture(ByVal TexturePath As String) As Boolean
If Mid(TexturePath, Len(TexturePath) - 3) = ".pcx" Then
    Rem // load PCX texture with our own loading function (Direct 3D can't load 8bit textures)
    Set Me.Texture = LoadPCX(TexturePath)
Else
    Set Me.Texture = D3DX.CreateTextureFromFileEx(D3DDevice, TexturePath, 0, 0, D3DX_DEFAULT, 0, D3DFMT_R8G8B8, D3DPOOL_MANAGED, D3DX_FILTER_LINEAR, D3DX_FILTER_LINEAR, 0, ByVal 0, ByVal 0)
End If
LoadMD2Texture = True
End Function

Public Function LoadMD2(ByVal ModelPath As String) As Boolean
Rem // temporary variables
Dim TexX As Integer, TexY As Integer, i As Long, t As Long
Dim FrameID As Long, DataOffSet As Long, FileNumber As Integer

FileNumber = FreeFile

Rem // open file
Open ModelPath For Binary As FileNumber

Rem // Read header
Rem // The header holds a lot of important data, like offsets and
Rem // sizes of the file sections

Rem // read header-informations
Get #FileNumber, , ModelHeader

Rem // Check the version number (there aren't much other MD2 versions)
If ModelHeader.magic <> "IDP2" Or ModelHeader.Version <> 8 Then
 LoadMD2 = False
 Exit Function
End If

Rem // we need the count of frames -1 (because in VB we define an array using the top bound and not the count of entries like in C)
ModelHeader.NumFrames = ModelHeader.NumFrames - 1

Rem // Read the indicies for the polygones
Rem // Each polygon has 3 indicies that point to different vertices
Rem // and 3 other indicies that point to the appropriate texture-
Rem // coordinates
ReDim Indicies(ModelHeader.NumTris * 3)
Seek #FileNumber, ModelHeader.OffsetTris + 1
Get #FileNumber, , Indicies()

Rem // Read texture-coordinates
Rem // The indicies array points to the texture coordinates
Rem // Redim texture coordinate array
ReDim TexCoord(ModelHeader.numTexCoords)

Seek #FileNumber, ModelHeader.offsetTexCoords + 1
For t = 0 To ModelHeader.numTexCoords
    Get #FileNumber, , TexX
    Get #FileNumber, , TexY
    TexCoord(t).x = CSng(TexX / Int(ModelHeader.SkinWidth))
    TexCoord(t).y = CSng(TexY / Int(ModelHeader.SkinHeight))
Next t

Rem // Redim the VertData array, this is a temporary array that stores
Rem // the current frame (interpolated)
ReDim VertData(ModelHeader.NumTris * 3)

Rem // The point array contains the vertices for each frame and some other informations (frame name)
Rem // Redim pointarray
ReDim FramePoints(ModelHeader.NumFrames)

Rem // Loop through all the frames
For FrameID = 0 To ModelHeader.NumFrames
  With FramePoints(FrameID)
  Rem // Redim the vertex array for this frame
  ReDim .verts(ModelHeader.NumVertices)
  
  Rem // The offset is calculated by the: frame-data-start + (FrameID * Size-of-a-frame)
  DataOffSet = ModelHeader.OffsetFrames + 1 + (FrameID * ModelHeader.FrameSize)
  Rem // Jump to the offset of the current frame
  Seek #FileNumber, DataOffSet

  Rem // Get the scaling factor
  Get #FileNumber, , .ScaleFac.x
  Get #FileNumber, , .ScaleFac.Z
  Get #FileNumber, , .ScaleFac.y
  Rem // Get the position
  Get #FileNumber, , .Translate.x
  Get #FileNumber, , .Translate.Z
  Get #FileNumber, , .Translate.y

  Rem // Get the name of this frame (16 chars)
  Get #FileNumber, , .FrameName

  Rem // Read model data
  Rem // Here we just read the vertices,
  Rem // a Vertex can occour twice in a single object, this is due indexing
  Rem // Read the coordinates (byte values)
  Get #FileNumber, , .verts()

  Rem // Transform coordinates (always transform 1 polygon at once)
  ReDim .SngVerts(ModelHeader.NumTris * 3)
  CountVar = 0
  Rem // Scale/translate points
  For i = 0 To ModelHeader.NumTris - 1
    Rem // First point
    v1New = VEC3(.ScaleFac.x * .verts(Indicies(i).VertIndex(0)).x + .Translate.x, _
                   .ScaleFac.y * .verts(Indicies(i).VertIndex(0)).y + .Translate.y, _
                   .ScaleFac.Z * .verts(Indicies(i).VertIndex(0)).Z + .Translate.Z)
    Rem // Second point
    v2New = VEC3(.ScaleFac.x * .verts(Indicies(i).VertIndex(1)).x + .Translate.x, _
                   .ScaleFac.y * .verts(Indicies(i).VertIndex(1)).y + .Translate.y, _
                   .ScaleFac.Z * .verts(Indicies(i).VertIndex(1)).Z + .Translate.Z)
    Rem // Third point
    v3New = VEC3(.ScaleFac.x * .verts(Indicies(i).VertIndex(2)).x + .Translate.x, _
                   .ScaleFac.y * .verts(Indicies(i).VertIndex(2)).y + .Translate.y, _
                   .ScaleFac.Z * .verts(Indicies(i).VertIndex(2)).Z + .Translate.Z)
                    
    Rem // Create the vertices (we also add normal/texture information here)
    MakeMDLVERTEX .SngVerts(MakeIndexRet), v1New, MD2LightNormals(.verts(Indicies(i).VertIndex(0)).NormalIndex), TexCoord(Indicies(i).TexIndex(0))
    MakeMDLVERTEX .SngVerts(MakeIndexRet), v2New, MD2LightNormals(.verts(Indicies(i).VertIndex(1)).NormalIndex), TexCoord(Indicies(i).TexIndex(1))
    MakeMDLVERTEX .SngVerts(MakeIndexRet), v3New, MD2LightNormals(.verts(Indicies(i).VertIndex(2)).NormalIndex), TexCoord(Indicies(i).TexIndex(2))
  Next i

  Rem // Free memory
  Erase .verts()
  End With
Next FrameID

Rem // Read out textures
Rem // I dont know why this data is saved here because
Rem // most times the paths are incorrect
Seek #FileNumber, ModelHeader.OffsetSkins + 1
Rem // Each path is 64 chars long (64 bytes obviously)
Dim ModelTex As String * 64
Rem // Read out texture names
Rem // Only a few MD2 have (correct) texture informations
For t = 0 To ModelHeader.NumSkins - 1
  Get #FileNumber, , ModelTex
  Rem // Uncomment this line to find out what texture paths are stored in the model file
Next t

Rem // Close the file
Close #FileNumber

Rem // Set up the CurFrame struct to start with the first frame (frame 0)
CurFrame.FrameIDFrom = 0
CurFrame.FrameIDTo = 1
CurFrame.FrameIDTo2 = 2
CurFrame.FrameIDTo3 = 3

Rem // Create the vertex buffer that holds the current status of the model
Set CurFrame.VBuffer = D3DDevice.CreateVertexBuffer(MDLVERTEX_SIZE * (ModelHeader.NumTris * 3), D3DUSAGE_WRITEONLY, MDLVERTEX_FVF, D3DPOOL_MANAGED)
If CurFrame.VBuffer Is Nothing Then LoadMD2 = False: Exit Function

Rem // Prepair the first frame
PrepairMesh

LoadMD2 = True
Loaded = True
Exit Function
Handler:
LoadMD2 = False
Exit Function
End Function


Private Function MakeIndexRet() As Long
MakeIndexRet = CountVar
CountVar = CountVar + 1
End Function

Private Sub PrepairMesh()
Rem // Here we pass our vertex data to the keyframe animation functions, the
Rem // animations are a lot faster by using C++ DLLs
If AnimType = 0 Then
  Rem // Linear interpolation
  Call AnimateLinear(VertData(0), FramePoints(CurFrame.FrameIDFrom).SngVerts(0), FramePoints(CurFrame.FrameIDTo).SngVerts(0), (ModelHeader.NumTris * 3), CurFrame.AnimationStatus, mMin, mMax)
  D3DVertexBuffer8SetData CurFrame.VBuffer, 0, MDLVERTEX_SIZE * (ModelHeader.NumTris * 3), 0, VertData(0)
ElseIf AnimType = 1 And ModelHeader.NumFrames >= 3 Then
  Rem // Catmull Rom interpolation
  Call AnimateCatmullRom(VertData(0), FramePoints(CurFrame.FrameIDFrom).SngVerts(0), FramePoints(CurFrame.FrameIDTo).SngVerts(0), FramePoints(CurFrame.FrameIDTo2).SngVerts(0), FramePoints(CurFrame.FrameIDTo3).SngVerts(0), (ModelHeader.NumTris * 3), CurFrame.AnimationStatus, mMin, mMax)
  D3DVertexBuffer8SetData CurFrame.VBuffer, 0, MDLVERTEX_SIZE * (ModelHeader.NumTris * 3), 0, VertData(0)
Else
  Rem // No interpolation
  D3DVertexBuffer8SetData CurFrame.VBuffer, 0, MDLVERTEX_SIZE * (ModelHeader.NumTris * 3), 0, FramePoints(CurFrame.FrameIDFrom).SngVerts(0)
End If
CurFrame.FrameName = FramePoints(CurFrame.FrameIDFrom).FrameName
End Sub

Public Function Render(Optional WeaponModel As Cls_MD2, Optional AnimationStatus As Single, Optional FrameIDFrom As Long, Optional FrameIDTo As Long, Optional FrameIDTo2 As Long, Optional FrameIDTo3 As Long, Optional NoUpdate As Boolean) As Boolean
On Error GoTo Handler:

If NoUpdate = False Then
Rem // The frame finding methods are kinda cheesy, but i wasnt able to think of any better way to do it
    If Not (FrameIDFrom = 0 And FrameIDTo = 0 And FrameIDTo2 = 0 And FrameIDTo3 = 0 And AnimationStatus = 0) Then
        CurFrame.FrameIDFrom = FrameIDFrom
        CurFrame.FrameIDTo = FrameIDTo
        CurFrame.FrameIDTo2 = FrameIDTo2
        CurFrame.FrameIDTo3 = FrameIDTo3
        CurFrame.AnimationStatus = AnimationStatus
    Else
        If CurFrame.AnimationStatus >= 1 Then
            If CurFrame.FrameIDTo <= ModelHeader.NumFrames Then
                CurFrame.FrameIDFrom = CurFrame.FrameIDTo
            End If
            CurFrame.FrameIDTo = CurFrame.FrameIDTo2
            CurFrame.FrameIDTo2 = CurFrame.FrameIDTo3
SearchFrame:
            If CurFrame.FrameIDTo3 < ModelHeader.NumFrames Then
                CurFrame.FrameIDTo3 = CurFrame.FrameIDTo3 + 1
            Else
                CurFrame.FrameIDTo3 = 0
            End If

            Rem // Found a frame?
            If Not Left(FramePoints(CurFrame.FrameIDTo3).FrameName, Len(FramePrefix)) = FramePrefix Then
                GoTo SearchFrame:
            End If
            CurFrame.AnimationStatus = 0
            CurFrame.FrameName = FramePoints(CurFrame.FrameIDFrom).FrameName
        End If
        TempFrameSearchCount = 0
    End If

    If Not (WeaponModel Is Nothing) Then
        If WeaponModel.Loaded Then
            WeaponModel.Render Nothing, CurFrame.AnimationStatus, CurFrame.FrameIDFrom, CurFrame.FrameIDTo, CurFrame.FrameIDTo2, CurFrame.FrameIDTo3
        End If
    End If

    Rem // Change the animation status (add the time that passed since last update multiplied with the animation speed
    CurFrame.AnimationStatus = CurFrame.AnimationStatus + ((QPTimer() - LastUpdate) * MD2AnimSpeed)
    LastUpdate = QPTimer()
    If CurFrame.AnimationStatus > 1 Then CurFrame.AnimationStatus = 1

    Rem // Calculate the new mesh (animations)
    PrepairMesh
Else
Rem // No update, but render the weapon anyway (if it is existant)
    If Not (WeaponModel Is Nothing) Then
        If WeaponModel.Loaded Then
            WeaponModel.Render WeaponModel:=Nothing, NoUpdate:=True
        End If
    End If
End If

Rem // Set the vertex shader so that D3D knows how to interpret the polygon data
D3DDevice.SetVertexShader MDLVERTEX_FVF
If bUseTexture Then
    Rem // Set the texture
    D3DDevice.SetTexture 0, Me.Texture
Else
    D3DDevice.SetTexture 0, Nothing
End If

Rem // Set the correct vertex buffer as vertex stream source
D3DDevice.SetStreamSource 0, CurFrame.VBuffer, MDLVERTEX_SIZE
'render MD2 model
D3DDevice.DrawPrimitive D3DPT_TRIANGLELIST, 0, ModelHeader.NumTris


Render = True
Exit Function
Handler:
Render = False
End Function

Rem // Some informations you can read out of this class
Public Property Get NumFrames() As Long
    NumFrames = ModelHeader.NumFrames
End Property
Public Property Get NumTriangles() As Long
    NumTriangles = ModelHeader.NumTris
End Property
Public Property Get ActualFrameID() As Long
    ActualFrameID = CurFrame.FrameIDFrom
End Property
Public Property Get GetFrameName(ByVal FrameNumber As Long) As String
    GetFrameName = FramePoints(FrameNumber).FrameName
End Property
Public Property Get GetFrameScaling(ByVal FrameNumber As Long) As D3DVECTOR
    GetFrameScaling = FramePoints(FrameNumber).ScaleFac
End Property
Public Property Get GetFrameTranslation(ByVal FrameNumber As Long) As D3DVECTOR
    GetFrameTranslation = FramePoints(FrameNumber).Translate
End Property

Public Property Get AnimationStatus() As Single
AnimationStatus = CurFrame.AnimationStatus
End Property

Public Property Get FrameIDFrom() As Long
FrameIDFrom = CurFrame.FrameIDFrom
End Property

Public Property Get FrameIDTo() As Long
FrameIDTo = CurFrame.FrameIDTo
End Property

Public Property Get FrameIDTo2() As Long
FrameIDTo2 = CurFrame.FrameIDTo2
End Property

Public Property Get FrameIDTo3() As Long
FrameIDTo3 = CurFrame.FrameIDTo3
End Property

Public Property Get BoxMin() As D3DVECTOR
    BoxMin = mMin
End Property
Public Property Get BoxMax() As D3DVECTOR
    BoxMax = mMax
End Property

Private Sub Class_Initialize()
Rem // Standard value for animation speed
MD2AnimSpeed = 9
AnimType = 1
bUseTexture = True
End Sub

Private Sub MakeMDLVERTEX(vOut As MDLVERTEX, ByRef pos As D3DVECTOR, Normal As D3DVECTOR, tex1 As D3DVECTOR2)
    vOut.Position = pos
    vOut.Normal = Normal
    vOut.Texture = tex1
End Sub
