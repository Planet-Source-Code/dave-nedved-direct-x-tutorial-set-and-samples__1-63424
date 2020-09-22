// ------------------------------------------------------
// | I did not program this dll but i do not know who   |
// | made it. if you are the programmer of it let me    |
// | know.. it is one of those examples that has been   |
// | sitting on my hdd for ages.. i hope you understand.|
// |													|
// ------------------------------------------------------
// |                                                    |
// | This is the ray-triangle collision detection DLL   |
// | which is a part of the DirectX Tutorial Set        |
// |                                                    |
// | Resources from: http://www.revolution3d.de         |
// | Website:        http://www.datosoftware.com        |
// | Email:          dnedved@datosoftware.com           |
// |                                                    |
// ------------------------------------------------------

// Include the Header-Dateien Files
#include <math.h>
#include "main.h"

//Vec3Length
_declspec( dllexport ) float _stdcall Vec3Length(D3DVECTOR& vVector)
{
return (float)sqrt((vVector.x * vVector.x) + (vVector.y * vVector.y) + (vVector.z * vVector.z));	
}

//Vec3Cross
_declspec( dllexport ) D3DVECTOR _stdcall Vec3Cross(D3DVECTOR& vVector1, D3DVECTOR& vVector2)
{
	D3DVECTOR result;

	result.x = vVector1.y * vVector2.z - vVector1.z * vVector2.y;
	result.y = vVector1.z * vVector2.x - vVector1.x * vVector2.z;
	result.z = vVector1.x * vVector2.y - vVector1.y * vVector2.x;

	return result;
}


//PlaneDotVec
_declspec( dllexport ) float _stdcall PlaneDotVec(D3DPLANE& pPlane, D3DVECTOR& vVect)
{
return (pPlane.a * vVect.x + pPlane.b * vVect.y + pPlane.c * vVect.z + pPlane.d);
}

//BSPPlaneDotVec
_declspec( dllexport ) float _stdcall BSPPlaneDotVec(BSPplane& pPlane, D3DVECTOR& vVect)
{
return (pPlane.vNormal.x * vVect.x + pPlane.vNormal.y * vVect.y + pPlane.vNormal.z * vVect.z - pPlane.d);
}

//Vec3Dot
_declspec( dllexport ) float _stdcall Vec3Dot(D3DVECTOR& vVector1, D3DVECTOR& vVector2)
{
 // The dot product is this equation: V1.V2 = (V1.x * V2.x  +  V1.y * V2.y  +  V1.z * V2.z)
 // In math terms, it looks like this:  V1.V2 = ||V1|| ||V2|| cos(theta)
return ( (vVector1.x * vVector2.x) + (vVector1.y * vVector2.y) + (vVector1.z * vVector2.z) );
}

//Vec3Normalize
_declspec( dllexport ) D3DVECTOR _stdcall Vec3Normalize(D3DVECTOR &vNormal)
{
 D3DVECTOR vTemp;
 // Get the magnitude of our normal
 float magnitude = (float)sqrt((vNormal.x * vNormal.x) + (vNormal.y * vNormal.y) + (vNormal.z * vNormal.z));

 // Now that we have the magnitude, we can divide our normal by that magnitude.
 // That will make our normal a total length of 1.  This makes it easier to work with too.
 vTemp.x = vNormal.x / magnitude;			// Divide the X value of our normal by it's magnitude
 vTemp.y = vNormal.y / magnitude;			// Divide the Y value of our normal by it's magnitude
 vTemp.z = vNormal.z / magnitude;			// Divide the Z value of our normal by it's magnitude

 // Finally, return our normalized normal.
 return vTemp;					// Return the new normal of length 1.
}

//Vec3Normalize
_declspec( dllexport ) D3DPLANE _stdcall PlaneNormalize(D3DPLANE &pPlane)
{
 D3DPLANE vTemp;
 // Get the magnitude of our plane
 float magnitude = (float)sqrt((pPlane.a * pPlane.a) + (pPlane.b * pPlane.b) + (pPlane.c * pPlane.c) + (pPlane.d * pPlane.d));

 // Now that we have the magnitude, we can divide our plane by that magnitude.
 // That will make our plane a total length of 1.  This makes it easier to work with too.
 vTemp.a = pPlane.a / magnitude;			// Divide the a value of our plane by it's magnitude
 vTemp.b = pPlane.b / magnitude;			// Divide the b value of our plane by it's magnitude
 vTemp.c = pPlane.c / magnitude;			// Divide the c value of our plane by it's magnitude
 vTemp.d = pPlane.d / magnitude;			// Divide the d value of our plane by it's magnitude

 // Finally, return our normalized normal.
 return vTemp;					// Return the new normal of length 1.
}
