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

#include <math.h>
#include "matrix.h"

const float Rad = 1.74532925199433f;


_declspec( dllexport ) void _stdcall MatrixMultiply(D3DMATRIX &matOut, D3DMATRIX &A, D3DMATRIX &B)
{
D3DMATRIX ret;
ret.m11 = B.m11 * A.m11 + B.m21 * A.m12 + B.m31 * A.m13 + B.m41 * A.m14;
ret.m12 = B.m12 * A.m11 + B.m22 * A.m12 + B.m32 * A.m13 + B.m42 * A.m14;
ret.m13 = B.m13 * A.m11 + B.m23 * A.m12 + B.m33 * A.m13 + B.m43 * A.m14;
ret.m14 = B.m14 * A.m11 + B.m24 * A.m12 + B.m34 * A.m13 + B.m44 * A.m14;
ret.m21 = B.m11 * A.m21 + B.m21 * A.m22 + B.m31 * A.m23 + B.m41 * A.m24;
ret.m22 = B.m12 * A.m21 + B.m22 * A.m22 + B.m32 * A.m23 + B.m42 * A.m24;
ret.m23 = B.m13 * A.m21 + B.m23 * A.m22 + B.m33 * A.m23 + B.m43 * A.m24;
ret.m24 = B.m14 * A.m21 + B.m24 * A.m22 + B.m34 * A.m23 + B.m44 * A.m24;
ret.m31 = B.m11 * A.m31 + B.m21 * A.m32 + B.m31 * A.m33 + B.m41 * A.m34;
ret.m32 = B.m12 * A.m31 + B.m22 * A.m32 + B.m32 * A.m33 + B.m42 * A.m34;
ret.m33 = B.m13 * A.m31 + B.m23 * A.m32 + B.m33 * A.m33 + B.m43 * A.m34;
ret.m34 = B.m14 * A.m31 + B.m24 * A.m32 + B.m34 * A.m33 + B.m44 * A.m34;
ret.m41 = B.m11 * A.m41 + B.m21 * A.m42 + B.m31 * A.m43 + B.m41 * A.m44;
ret.m42 = B.m12 * A.m41 + B.m22 * A.m42 + B.m32 * A.m43 + B.m42 * A.m44;
ret.m43 = B.m13 * A.m41 + B.m23 * A.m42 + B.m33 * A.m43 + B.m43 * A.m44;
ret.m44 = B.m14 * A.m41 + B.m24 * A.m42 + B.m34 * A.m43 + B.m44 * A.m44;

matOut = ret;
}

_declspec( dllexport ) void _stdcall MatrixRotationZ(D3DMATRIX &matOut, float rotValue)
{
D3DMATRIX matTemp;
matTemp.m11 = (float)cos(rotValue);
matTemp.m22 = (float)cos(rotValue);

matTemp.m12 = (float)sin(rotValue);
matTemp.m21 = (float)-sin(rotValue);

matOut = matTemp;
}

_declspec( dllexport ) void _stdcall CreateTexMatrix(D3DMATRIX &matOut, float scaleX, float scaleY, float offX, float offY, float rot)
{
D3DMATRIX rmat;
D3DMATRIX tmat;

matOut.m11 = scaleX;	matOut.m12 = 0;			matOut.m13 = 0;		matOut.m14 = 0;
matOut.m21 = 0;			matOut.m22 = scaleY;	matOut.m23 = 0;		matOut.m24 = 0;
matOut.m31 = offX;		matOut.m32 = offY;		matOut.m33 = 1;		matOut.m34 = 0;
matOut.m41 = 0;			matOut.m42 = 0;			matOut.m43 = 0;		matOut.m44 = 0;

MatrixRotationZ(rmat, Rad * rot);

tmat.m11 = 1;    tmat.m12 = 0;    tmat.m13 = 0;    tmat.m14 = 0;
tmat.m21 = 0;    tmat.m22 = 1;    tmat.m23 = 0;    tmat.m24 = 0;
tmat.m31 = 0.5;  tmat.m32 = 0.5;  tmat.m33 = 1;    tmat.m34 = 0;
tmat.m41 = 0;    tmat.m42 = 0;    tmat.m43 = 0;    tmat.m44 = 0;

MatrixMultiply(matOut, matOut, tmat);
MatrixMultiply(matOut, rmat, matOut);

tmat.m11 = 1;    tmat.m12 = 0;    tmat.m13 = 0;    tmat.m14 = 0;
tmat.m21 = 0;    tmat.m22 = 1;    tmat.m23 = 0;    tmat.m24 = 0;
tmat.m31 = -0.5; tmat.m32 = -0.5; tmat.m33 = 1;    tmat.m34 = 0;
tmat.m41 = 0;    tmat.m42 = 0;    tmat.m43 = 0;    tmat.m44 = 0;

MatrixMultiply(matOut, tmat, matOut);
matOut.m14 = 0; matOut.m24 = 0; matOut.m34 = 0;
matOut.m41 = 0;	matOut.m42 = 0;	matOut.m43 = 0;	matOut.m44 = 0;
}