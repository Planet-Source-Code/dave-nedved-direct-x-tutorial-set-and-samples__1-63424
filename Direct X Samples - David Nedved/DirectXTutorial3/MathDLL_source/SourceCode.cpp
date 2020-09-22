// -----------------------------------------------------
// |                                                   |
// | This is the ray-triangle collision detection DLL  |
// | which is a part of the DirectX Tutorial Set       |
// |                                                   |
// | Resources from: http://www.revolution3d.de        |
// | Website:        http://www.datosoftware.com       |
// | Email:          dnedved@datosoftware.com          |
// |                                                   |
// -----------------------------------------------------

#pragma warning (disable:4244) //disable the error about double-float conversions. irritating.

#include <math.h>
#include "main.h"


//Funktionen
_declspec( dllexport ) float _stdcall Vec3Dist(D3DVECTOR& vVect1, D3DVECTOR& vVect2)
{
	float Distance = 0;
	D3DVECTOR tdVect;

	tdVect = vVect1 - vVect2;
	Distance = Vec3Length(tdVect);
	return Distance;
}


//_declspec( dllexport ) short _stdcall ClusterVisible(BSPVisData& visData, int test, int pvs)
//{
//int8 visSet = visData.pBitsets[(test * visData.bytesPerCluster) + (pvs >> 3)];
//
//if(visSet & (1 << ((pvs) & 7))) {
//return 1;
//} else {
//return 0;
//}
//}


//AnimateKeyFramesLinear()
// - uses the function A+V(B-A) to linearly interpolate between the vertices...
_declspec( dllexport ) void _stdcall AnimateLinear(MDLVERTEX *FinalVerts, MDLVERTEX *SrcVerts, MDLVERTEX *DestVerts, long nVerts, float t, D3DVECTOR& boxMin, D3DVECTOR& boxMax)
{
	D3DVECTOR tbMin(100000,100000,100000);
	D3DVECTOR tbMax(-100000,-100000,-100000);
	
	//we're just gonna loop through all the vertices:
	for (long i=0;i<nVerts;i++)
	{
		//Interpolate the vertices:
		FinalVerts->position = SrcVerts->position + ((DestVerts->position - SrcVerts->position) * t);
		FinalVerts->normal = SrcVerts->normal + ((DestVerts->normal - SrcVerts->normal) * t);
		FinalVerts->tex1 = SrcVerts->tex1 + ((DestVerts->tex1 - SrcVerts->tex1) * t);

		//Update the boxMin value
		if (FinalVerts->position.x < tbMin.x)
			tbMin.x = FinalVerts->position.x;
		if (FinalVerts->position.y < tbMin.y)
			tbMin.y = FinalVerts->position.y;
		if (FinalVerts->position.z < tbMin.z)
			tbMin.z = FinalVerts->position.z;
		//Update the boxMax value
		if (FinalVerts->position.x > tbMax.x)
			tbMax.x = FinalVerts->position.x;
		if (FinalVerts->position.y > tbMax.y)
			tbMax.y = FinalVerts->position.y;
		if (FinalVerts->position.z > tbMax.z)
			tbMax.z = FinalVerts->position.z;

		boxMin = tbMin;
		boxMax = tbMax;

		//Increment the buffer pointers
		SrcVerts++;
		DestVerts++;
		FinalVerts++;
	}
}




//AnimateKeyFramesCatmullRom()
// - blends the keyframes using the Catmull-Rom spline equations.
_declspec( dllexport ) void _stdcall AnimateCatmullRom(MDLVERTEX *FinalVerts, MDLVERTEX *Frame0Verts, MDLVERTEX *Frame1Verts, MDLVERTEX *Frame2Verts, MDLVERTEX *Frame3Verts, long nVerts, float t, D3DVECTOR& boxMin, D3DVECTOR& boxMax)
{
	float t_2 = t * t;
	float t_3 = t_2 * t;
	D3DVECTOR tbMin(100000,100000,100000);
	D3DVECTOR tbMax(-100000,-100000,-100000);

	//we're just gonna loop through all the vertices:
	for (long i=0;i<nVerts;i++)
	{
		//Interpolate the vertices
		FinalVerts->position = Frame0Verts->position * (-0.5f * t_3 + t_2 - 0.5f * t) +
							   Frame1Verts->position * (1.5f * t_3 + -2.5f * t_2 + 1) +
							   Frame2Verts->position * (-1.5f * t_3 + 2 * t_2 + 0.5 * t) +
							   Frame3Verts->position * (0.5f * t_3 - 0.5 * t_2);

		FinalVerts->normal = Frame0Verts->normal * (-0.5f * t_3 + t_2 - 0.5f * t) +
							 Frame1Verts->normal * (1.5f * t_3 + -2.5f * t_2 + 1) +
							 Frame2Verts->normal * (-1.5f * t_3 + 2 * t_2 + 0.5 * t) +
						 	 Frame3Verts->normal * (0.5f * t_3 - 0.5 * t_2);

		FinalVerts->tex1 = Frame0Verts->tex1 * (-0.5f * t_3 + t_2 - 0.5f * t) +
						   Frame1Verts->tex1 * (1.5f * t_3 + -2.5f * t_2 + 1) +
						   Frame2Verts->tex1 * (-1.5f * t_3 + 2 * t_2 + 0.5 * t) +
						   Frame3Verts->tex1 * (0.5f * t_3 - 0.5 * t_2);

		//Update the boxMin value
		if (FinalVerts->position.x < tbMin.x)
			tbMin.x = FinalVerts->position.x;
		if (FinalVerts->position.y < tbMin.y)
			tbMin.y = FinalVerts->position.y;
		if (FinalVerts->position.z < tbMin.z)
			tbMin.z = FinalVerts->position.z;
		//Update the boxMax value
		if (FinalVerts->position.x > tbMax.x)
			tbMax.x = FinalVerts->position.x;
		if (FinalVerts->position.y > tbMax.y)
			tbMax.y = FinalVerts->position.y;
		if (FinalVerts->position.z > tbMax.z)
			tbMax.z = FinalVerts->position.z;

		boxMin = tbMin;
		boxMax = tbMax;

		//Update the ptrs
		FinalVerts++;
		Frame0Verts++;
		Frame1Verts++;
		Frame2Verts++;
		Frame3Verts++;
	}
}



_declspec( dllexport ) D3DVECTOR _stdcall CalculateNormal(D3DVECTOR& vP0, D3DVECTOR& vP1, D3DVECTOR& vP2)
{
return Vec3Cross(vP1 - vP0, vP2 - vP0);
}

_declspec( dllexport ) short _stdcall GetSPoint(D3DVECTOR& vOut, D3DVECTOR& vP0, D3DVECTOR& vP1, D3DVECTOR& vP2, D3DVECTOR& vPv, D3DVECTOR& vUv)
{
D3DVECTOR ENorm;
D3DVECTOR vTmp;
float Eb = 0;
float Temp = 0;
float t = 0;
short Result = 0;

ENorm = CalculateNormal(vP0, vP1, vP2);
Eb = Vec3Dot(ENorm, vP0) - Vec3Dot(ENorm, vPv);

Temp = Vec3Dot(ENorm, vUv);

if(Temp != 0) {
    t = Eb / Temp;
    Result = 1;
} else {
    Result = 0;
}

vTmp = vUv * t;
vOut = vPv + vTmp;

return Result;
}

_declspec( dllexport ) short _stdcall TriangleMatch(D3DVECTOR& P1, D3DVECTOR& P2, D3DVECTOR& P3, D3DVECTOR& Test_Point)
{
D3DVECTOR nE;
D3DVECTOR tP;
short tBool = 0;
D3DVECTOR spanTP;

nE = CalculateNormal(P1, P2, P3);
nE = Vec3Normalize(nE);

spanTP.x = Test_Point.x - P1.x;
spanTP.y = Test_Point.y - P1.y;
spanTP.z = Test_Point.z - P1.z;

tP.x = P3.x + nE.x;
tP.y = P3.y + nE.y;
tP.z = P3.z + nE.z;

tBool = GetSPoint(tP, P2, P3, tP, P1, spanTP);

if (Vec3Dist(P1, Test_Point) <= Vec3Dist(P1, tP) && Vec3Dist(Test_Point, tP) <= Vec3Dist(P1, tP) && Vec3Dist(P2, tP) <= Vec3Dist(P2, P3) && Vec3Dist(P3, tP) <= Vec3Dist(P2, P3)) {
    return 1;
} else {
	return 0;
}
}

_declspec( dllexport ) short _stdcall RayTriCollision(D3DVECTOR& vOut, D3DVECTOR& P0, D3DVECTOR& P1, D3DVECTOR& P2, D3DVECTOR& vFrom, D3DVECTOR& vTo)
{
D3DVECTOR tVec;
D3DVECTOR tVec2;
D3DVECTOR vTo2;

vTo2 = vFrom - vTo;

if(GetSPoint(tVec, P0, P1, P2, vFrom, vTo2) == 1) {
	tVec2 = tVec - vFrom;
	tVec2 = Vec3Normalize(tVec2);

	vTo2 = Vec3Normalize(vTo);
	if(Vec3Dot(tVec2, vTo2) > 0) {
		if(TriangleMatch(P0, P1, P2, tVec) == 1) {
			vOut = tVec;
			return 1;
		}
	}
}
return 0;
}


_declspec( dllexport ) short _stdcall DirTriCollision(D3DVECTOR& vOut, D3DVECTOR& P0, D3DVECTOR& P1, D3DVECTOR& P2, D3DVECTOR& vFrom, D3DVECTOR& vDir)
{
D3DVECTOR tVec;
D3DVECTOR tVec2;
D3DVECTOR vDir2;

vDir2 = Vec3Normalize(vDir);

if(GetSPoint(tVec, P0, P1, P2, vFrom, vDir2) == 1) {
	tVec2 = tVec - vFrom;
	tVec2 = Vec3Normalize(tVec2);
	if(Vec3Dot(tVec2, vDir2) > 0) {
		if(TriangleMatch(P0, P1, P2, tVec) == 1) {
		    vOut = tVec;
            return 1;
		}
	}
}
return 0;
}
