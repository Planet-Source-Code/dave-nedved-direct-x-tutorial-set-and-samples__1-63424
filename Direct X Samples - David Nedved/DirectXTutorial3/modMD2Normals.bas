Attribute VB_Name = "modMD2Helper"
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


Rem // This mod loads a MD2 File

Rem // DLL declarations for animation routines (this is the DLL that is coded in c++ found in this dir)
Public Declare Sub AnimateLinear Lib "mvbMath.dll" (ByRef vOut As MDLVERTEX, ByRef vFrame0 As MDLVERTEX, ByRef vFrame1 As MDLVERTEX, ByVal nVerts As Long, ByVal t As Single, ByRef vBoxMin As D3DVECTOR, ByRef vBoxMax As D3DVECTOR)
Public Declare Sub AnimateCatmullRom Lib "mvbMath.dll" (ByRef vOut As MDLVERTEX, ByRef vFrame0 As MDLVERTEX, ByRef vFrame1 As MDLVERTEX, ByRef vFrame2 As MDLVERTEX, ByRef vFrame3 As MDLVERTEX, ByVal nVerts As Long, ByVal t As Single, ByRef vBoxMin As D3DVECTOR, ByRef vBoxMax As D3DVECTOR)

Rem // This vertex type is used for MD2 rendering
Public Type MDLVERTEX
    Position As D3DVECTOR
    Normal As D3DVECTOR
    Texture As D3DVECTOR2
End Type
Public Const MDLVERTEX_SIZE As Long = 32
Public Const MDLVERTEX_FVF As Long = (D3DFVF_XYZ Or D3DFVF_TEX1 Or D3DFVF_NORMAL)

Public MD2LightNormals(162) As D3DVECTOR
Public MD2Material As D3DMATERIAL8
Rem // The sucky thing about VB is that we have no initialized array data
Rem // We have to initialize the data ourself... Bores anyone to death!
Public Function InitLightNormals()
MD2LightNormals(0) = VEC3(-0.525731, 0, 0.850651)
MD2LightNormals(1) = VEC3(-0.442863, 0.238856, 0.864188)
MD2LightNormals(2) = VEC3(-0.295242, 0#, 0.955423)
MD2LightNormals(3) = VEC3(-0.309017, 0.5, 0.809017)
MD2LightNormals(4) = VEC3(-0.16246, 0.262866, 0.951056)
MD2LightNormals(5) = VEC3(0#, 0#, 1#)
MD2LightNormals(6) = VEC3(0#, 0.850651, 0.525731)
MD2LightNormals(7) = VEC3(-0.147621, 0.716567, 0.681718)
MD2LightNormals(8) = VEC3(0.147621, 0.716567, 0.681718)
MD2LightNormals(9) = VEC3(0#, 0.525731, 0.850651)
MD2LightNormals(10) = VEC3(0.309017, 0.5, 0.809017)
MD2LightNormals(11) = VEC3(0.525731, 0#, 0.850651)
MD2LightNormals(12) = VEC3(0.295242, 0#, 0.955423)
MD2LightNormals(13) = VEC3(0.442863, 0.238856, 0.864188)
MD2LightNormals(14) = VEC3(0.16246, 0.262866, 0.951056)
MD2LightNormals(15) = VEC3(-0.681718, 0.147621, 0.716567)
MD2LightNormals(16) = VEC3(-0.809017, 0.309017, 0.5)
MD2LightNormals(17) = VEC3(-0.587785, 0.425325, 0.688191)
MD2LightNormals(18) = VEC3(-0.850651, 0.525731, 0#)
MD2LightNormals(19) = VEC3(-0.864188, 0.442863, 0.238856)
MD2LightNormals(20) = VEC3(-0.716567, 0.681718, 0.147621)
MD2LightNormals(21) = VEC3(-0.688191, 0.587785, 0.425325)
MD2LightNormals(22) = VEC3(-0.5, 0.809017, 0.309017)
MD2LightNormals(23) = VEC3(-0.238856, 0.864188, 0.442863)
MD2LightNormals(24) = VEC3(-0.425325, 0.688191, 0.587785)
MD2LightNormals(25) = VEC3(-0.716567, 0.681718, -0.147621)
MD2LightNormals(26) = VEC3(-0.5, 0.809017, -0.309017)
MD2LightNormals(27) = VEC3(-0.525731, 0.850651, 0#)
MD2LightNormals(28) = VEC3(0#, 0.850651, -0.525731)
MD2LightNormals(29) = VEC3(-0.238856, 0.864188, -0.442863)
MD2LightNormals(30) = VEC3(0#, 0.955423, -0.295242)
MD2LightNormals(31) = VEC3(-0.262866, 0.951056, -0.16246)
MD2LightNormals(32) = VEC3(0#, 1#, 0#)
MD2LightNormals(33) = VEC3(0#, 0.955423, 0.295242)
MD2LightNormals(34) = VEC3(-0.262866, 0.951056, 0.16246)
MD2LightNormals(35) = VEC3(0.238856, 0.864188, 0.442863)
MD2LightNormals(36) = VEC3(0.262866, 0.951056, 0.16246)
MD2LightNormals(37) = VEC3(0.5, 0.809017, 0.309017)
MD2LightNormals(38) = VEC3(0.238856, 0.864188, -0.442863)
MD2LightNormals(39) = VEC3(0.262866, 0.951056, -0.16246)
MD2LightNormals(40) = VEC3(0.5, 0.809017, -0.309017)
MD2LightNormals(41) = VEC3(0.850651, 0.525731, 0#)
MD2LightNormals(42) = VEC3(0.716567, 0.681718, 0.147621)
MD2LightNormals(43) = VEC3(0.716567, 0.681718, -0.147621)
MD2LightNormals(44) = VEC3(0.525731, 0.850651, 0#)
MD2LightNormals(45) = VEC3(0.425325, 0.688191, 0.587785)
MD2LightNormals(46) = VEC3(0.864188, 0.442863, 0.238856)
MD2LightNormals(47) = VEC3(0.688191, 0.587785, 0.425325)
MD2LightNormals(48) = VEC3(0.809017, 0.309017, 0.5)
MD2LightNormals(49) = VEC3(0.681718, 0.147621, 0.716567)
MD2LightNormals(50) = VEC3(0.587785, 0.425325, 0.688191)
MD2LightNormals(51) = VEC3(0.955423, 0.295242, 0#)
MD2LightNormals(52) = VEC3(1#, 0#, 0#)
MD2LightNormals(53) = VEC3(0.951056, 0.16246, 0.262866)
MD2LightNormals(54) = VEC3(0.850651, -0.525731, 0#)
MD2LightNormals(55) = VEC3(0.955423, -0.295242, 0#)
MD2LightNormals(56) = VEC3(0.864188, -0.442863, 0.238856)
MD2LightNormals(57) = VEC3(0.951056, -0.16246, 0.262866)
MD2LightNormals(58) = VEC3(0.809017, -0.309017, 0.5)
MD2LightNormals(59) = VEC3(0.681718, -0.147621, 0.716567)
MD2LightNormals(60) = VEC3(0.850651, 0#, 0.525731)
MD2LightNormals(61) = VEC3(0.864188, 0.442863, -0.238856)
MD2LightNormals(62) = VEC3(0.809017, 0.309017, -0.5)
MD2LightNormals(63) = VEC3(0.951056, 0.16246, -0.262866)
MD2LightNormals(64) = VEC3(0.525731, 0#, -0.850651)
MD2LightNormals(65) = VEC3(0.681718, 0.147621, -0.716567)
MD2LightNormals(66) = VEC3(0.681718, -0.147621, -0.716567)
MD2LightNormals(67) = VEC3(0.850651, 0#, -0.525731)
MD2LightNormals(68) = VEC3(0.809017, -0.309017, -0.5)
MD2LightNormals(69) = VEC3(0.864188, -0.442863, -0.238856)
MD2LightNormals(70) = VEC3(0.951056, -0.16246, -0.262866)
MD2LightNormals(71) = VEC3(0.147621, 0.716567, -0.681718)
MD2LightNormals(72) = VEC3(0.309017, 0.5, -0.809017)
MD2LightNormals(73) = VEC3(0.425325, 0.688191, -0.587785)
MD2LightNormals(74) = VEC3(0.442863, 0.238856, -0.864188)
MD2LightNormals(75) = VEC3(0.587785, 0.425325, -0.688191)
MD2LightNormals(76) = VEC3(0.688191, 0.587785, -0.425325)
MD2LightNormals(77) = VEC3(-0.147621, 0.716567, -0.681718)
MD2LightNormals(78) = VEC3(-0.309017, 0.5, -0.809017)
MD2LightNormals(79) = VEC3(0#, 0.525731, -0.850651)
MD2LightNormals(80) = VEC3(-0.525731, 0#, -0.850651)
MD2LightNormals(81) = VEC3(-0.442863, 0.238856, -0.864188)
MD2LightNormals(82) = VEC3(-0.295242, 0#, -0.955423)
MD2LightNormals(83) = VEC3(-0.16246, 0.262866, -0.951056)
MD2LightNormals(84) = VEC3(0#, 0#, -1#)
MD2LightNormals(85) = VEC3(0.295242, 0#, -0.955423)
MD2LightNormals(86) = VEC3(0.16246, 0.262866, -0.951056)
MD2LightNormals(87) = VEC3(-0.442863, -0.238856, -0.864188)
MD2LightNormals(88) = VEC3(-0.309017, -0.5, -0.809017)
MD2LightNormals(89) = VEC3(-0.16246, -0.262866, -0.951056)
MD2LightNormals(90) = VEC3(0#, -0.850651, -0.525731)
MD2LightNormals(91) = VEC3(-0.147621, -0.716567, -0.681718)
MD2LightNormals(92) = VEC3(0.147621, -0.716567, -0.681718)
MD2LightNormals(93) = VEC3(0#, -0.525731, -0.850651)
MD2LightNormals(94) = VEC3(0.309017, -0.5, -0.809017)
MD2LightNormals(95) = VEC3(0.442863, -0.238856, -0.864188)
MD2LightNormals(96) = VEC3(0.16246, -0.262866, -0.951056)
MD2LightNormals(97) = VEC3(0.238856, -0.864188, -0.442863)
MD2LightNormals(98) = VEC3(0.5, -0.809017, -0.309017)
MD2LightNormals(99) = VEC3(0.425325, -0.688191, -0.587785)
MD2LightNormals(100) = VEC3(0.716567, -0.681718, -0.147621)
MD2LightNormals(101) = VEC3(0.688191, -0.587785, -0.425325)
MD2LightNormals(102) = VEC3(0.587785, -0.425325, -0.688191)
MD2LightNormals(103) = VEC3(0#, -0.955423, -0.295242)
MD2LightNormals(104) = VEC3(0#, -1#, 0#)
MD2LightNormals(105) = VEC3(0.262866, -0.951056, -0.16246)
MD2LightNormals(106) = VEC3(0#, -0.850651, 0.525731)
MD2LightNormals(107) = VEC3(0#, -0.955423, 0.295242)
MD2LightNormals(108) = VEC3(0.238856, -0.864188, 0.442863)
MD2LightNormals(109) = VEC3(0.262866, -0.951056, 0.16246)
MD2LightNormals(110) = VEC3(0.5, -0.809017, 0.309017)
MD2LightNormals(111) = VEC3(0.716567, -0.681718, 0.147621)
MD2LightNormals(112) = VEC3(0.525731, -0.850651, 0#)
MD2LightNormals(113) = VEC3(-0.238856, -0.864188, -0.442863)
MD2LightNormals(114) = VEC3(-0.5, -0.809017, -0.309017)
MD2LightNormals(115) = VEC3(-0.262866, -0.951056, -0.16246)
MD2LightNormals(116) = VEC3(-0.850651, -0.525731, 0#)
MD2LightNormals(117) = VEC3(-0.716567, -0.681718, -0.147621)
MD2LightNormals(118) = VEC3(-0.716567, -0.681718, 0.147621)
MD2LightNormals(119) = VEC3(-0.525731, -0.850651, 0#)
MD2LightNormals(120) = VEC3(-0.5, -0.809017, 0.309017)
MD2LightNormals(121) = VEC3(-0.238856, -0.864188, 0.442863)
MD2LightNormals(122) = VEC3(-0.262866, -0.951056, 0.16246)
MD2LightNormals(123) = VEC3(-0.864188, -0.442863, 0.238856)
MD2LightNormals(124) = VEC3(-0.809017, -0.309017, 0.5)
MD2LightNormals(125) = VEC3(-0.688191, -0.587785, 0.425325)
MD2LightNormals(126) = VEC3(-0.681718, -0.147621, 0.716567)
MD2LightNormals(127) = VEC3(-0.442863, -0.238856, 0.864188)
MD2LightNormals(128) = VEC3(-0.587785, -0.425325, 0.688191)
MD2LightNormals(129) = VEC3(-0.309017, -0.5, 0.809017)
MD2LightNormals(130) = VEC3(-0.147621, -0.716567, 0.681718)
MD2LightNormals(131) = VEC3(-0.425325, -0.688191, 0.587785)
MD2LightNormals(132) = VEC3(-0.16246, -0.262866, 0.951056)
MD2LightNormals(133) = VEC3(0.442863, -0.238856, 0.864188)
MD2LightNormals(134) = VEC3(0.16246, -0.262866, 0.951056)
MD2LightNormals(135) = VEC3(0.309017, -0.5, 0.809017)
MD2LightNormals(136) = VEC3(0.147621, -0.716567, 0.681718)
MD2LightNormals(137) = VEC3(0#, -0.525731, 0.850651)
MD2LightNormals(138) = VEC3(0.425325, -0.688191, 0.587785)
MD2LightNormals(139) = VEC3(0.587785, -0.425325, 0.688191)
MD2LightNormals(140) = VEC3(0.688191, -0.587785, 0.425325)
MD2LightNormals(141) = VEC3(-0.955423, 0.295242, 0#)
MD2LightNormals(142) = VEC3(-0.951056, 0.16246, 0.262866)
MD2LightNormals(143) = VEC3(-1#, 0#, 0#)
MD2LightNormals(144) = VEC3(-0.850651, 0#, 0.525731)
MD2LightNormals(145) = VEC3(-0.955423, -0.295242, 0#)
MD2LightNormals(146) = VEC3(-0.951056, -0.16246, 0.262866)
MD2LightNormals(147) = VEC3(-0.864188, 0.442863, -0.238856)
MD2LightNormals(148) = VEC3(-0.951056, 0.16246, -0.262866)
MD2LightNormals(149) = VEC3(-0.809017, 0.309017, -0.5)
MD2LightNormals(150) = VEC3(-0.864188, -0.442863, -0.238856)
MD2LightNormals(151) = VEC3(-0.951056, -0.16246, -0.262866)
MD2LightNormals(152) = VEC3(-0.809017, -0.309017, -0.5)
MD2LightNormals(153) = VEC3(-0.681718, 0.147621, -0.716567)
MD2LightNormals(154) = VEC3(-0.681718, -0.147621, -0.716567)
MD2LightNormals(155) = VEC3(-0.850651, 0#, -0.525731)
MD2LightNormals(156) = VEC3(-0.688191, 0.587785, -0.425325)
MD2LightNormals(157) = VEC3(-0.587785, 0.425325, -0.688191)
MD2LightNormals(158) = VEC3(-0.425325, 0.688191, -0.587785)
MD2LightNormals(159) = VEC3(-0.425325, -0.688191, -0.587785)
MD2LightNormals(160) = VEC3(-0.587785, -0.425325, -0.688191)
MD2LightNormals(161) = VEC3(-0.688191, -0.587785, -0.425325)

Rem // Set ident material
MD2Material.Ambient.a = 1
MD2Material.Ambient.r = 1
MD2Material.Ambient.g = 1
MD2Material.Ambient.b = 1

MD2Material.diffuse.a = 1
MD2Material.diffuse.r = 1
MD2Material.diffuse.g = 1
MD2Material.diffuse.b = 1

MD2Material.power = 10

D3DDevice.SetMaterial MD2Material
End Function

Rem // the ^^^ is a big sub of lighting stuff.. it tells the camera where to position the light etc..
