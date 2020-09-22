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

//3D VECTOR
struct D3DMATRIX
{
public:

	D3DMATRIX() {
		m11 = 1; m21 = 0; m31 = 0; m41 = 0;
		m12 = 0; m22 = 1; m32 = 0; m42 = 0;
		m13 = 0; m23 = 0; m33 = 1; m43 = 0;
		m14 = 0; m24 = 0; m34 = 0; m44 = 1;
	}

	D3DMATRIX(float Mm11, float Mm21, float Mm31, float Mm41, 
			  float Mm12, float Mm22, float Mm32, float Mm42,
			  float Mm13, float Mm23, float Mm33, float Mm43,
			  float Mm14, float Mm24, float Mm34, float Mm44)
	{ 
		m11 = Mm11; m21 = Mm21; m31 = Mm31; m41 = Mm41;
		m12 = Mm12; m22 = Mm22; m32 = Mm32; m42 = Mm42;
		m13 = Mm13; m23 = Mm23; m33 = Mm33; m43 = Mm43;
		m14 = Mm14; m24 = Mm24; m34 = Mm34; m44 = Mm44;
	}

	float m11, m12, m13, m14;
	float m21, m22, m23, m24;
	float m31, m32, m33, m34;
	float m41, m42, m43, m44;
};

//Prototypes
__declspec( dllexport ) void _stdcall MatrixMultiply(D3DMATRIX &matOut, D3DMATRIX &A, D3DMATRIX &B);
__declspec( dllexport ) void _stdcall MatrixRotationZ(D3DMATRIX &matOut, float rotValue);
__declspec( dllexport ) void _stdcall CreateTexMatrix(D3DMATRIX &matOut, float scaleX, float scaleY, float offX, float offY, float rot);