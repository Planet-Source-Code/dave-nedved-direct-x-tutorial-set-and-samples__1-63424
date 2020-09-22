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
struct D3DVECTOR
{
public:

	D3DVECTOR() {}

	D3DVECTOR(float X, float Y, float Z) 
	{ 
		x = X; y = Y; z = Z;
	}

	D3DVECTOR operator+(D3DVECTOR vVect)
	{
		return D3DVECTOR(vVect.x + x, vVect.y + y, vVect.z + z);
	}


	D3DVECTOR operator-(D3DVECTOR vVect)
	{
		return D3DVECTOR(x - vVect.x, y - vVect.y, z - vVect.z);
	}
	
	D3DVECTOR operator*(float Num)
	{
		return D3DVECTOR(x * Num, y * Num, z * Num);
	}

	D3DVECTOR operator/(float Num)
	{
		return D3DVECTOR(x / Num, y / Num, z / Num);
	}

	float x, y, z;
};


struct D3DVECTOR2
{
public:

	D3DVECTOR2() {}

	D3DVECTOR2(float X, float Y) 
	{ 
		x = X; y = Y;
	}

	D3DVECTOR2 operator+(D3DVECTOR2 vVect)
	{

		return D3DVECTOR2(vVect.x + x, vVect.y + y);
	}


	D3DVECTOR2 operator-(D3DVECTOR2 vVect)
	{
		return D3DVECTOR2(x - vVect.x, y - vVect.y);
	}

	D3DVECTOR2 operator*(float Num)
	{
		return D3DVECTOR2(x * Num, y * Num);
	}
	float x, y;
};


struct MDLVERTEX
{
public:
	D3DVECTOR position;
	D3DVECTOR normal;
    D3DVECTOR2 tex1;
};


//BSPVisData
//struct BSPVisData
//{
//public:
//	BSPVisData() {}
//
// int numOfClusters;
// int bytesPerCluster;
// byte *pBitsets;
//};


//BSPplane
struct BSPplane
{
public:

	BSPplane() {}

 D3DVECTOR vNormal;
 float d;
};


//PLANE
struct D3DPLANE
{
public:

	D3DPLANE() {}
	
	D3DPLANE(float A, float B, float C, float D)
	{
		a = A; b = B; c = C; d = D;
	}

	float a, b, c, d;

};


//Helper prototypes
__declspec( dllexport ) float _stdcall Vec3Length(D3DVECTOR& vVector);
__declspec( dllexport ) D3DVECTOR _stdcall Vec3Cross(D3DVECTOR& vVector1, D3DVECTOR& vVector2);
__declspec( dllexport ) float _stdcall Vec3Dot(D3DVECTOR& vVector1, D3DVECTOR& vVector2);
__declspec( dllexport ) D3DVECTOR _stdcall Vec3Normalize(D3DVECTOR &vNormal);
__declspec( dllexport ) D3DPLANE _stdcall PlaneNormalize(D3DPLANE &pPlane);
__declspec( dllexport ) float _stdcall PlaneDotVec(D3DPLANE& pPlane, D3DVECTOR& vVect);
__declspec( dllexport ) float _stdcall BSPPlaneDotVec(BSPplane& pPlane, D3DVECTOR& vVect);


//Main prototypes
__declspec( dllexport ) float _stdcall Vec3Dist(D3DVECTOR& vVect1, D3DVECTOR& vVect2);
//__declspec( dllexport ) short _stdcall ClusterVisible(BSPVisData& visData, int test, int pvs);
__declspec( dllexport ) D3DVECTOR _stdcall CalculateNormal(D3DVECTOR& vP0, D3DVECTOR& vP1, D3DVECTOR& vP2);
__declspec( dllexport ) short _stdcall GetSPoint(D3DVECTOR& vOut, D3DVECTOR& vP0, D3DVECTOR& vP1, D3DVECTOR& vP2, D3DVECTOR& vPv, D3DVECTOR& vUv);
__declspec( dllexport ) short _stdcall TriangleMatch(D3DVECTOR& P1, D3DVECTOR& P2, D3DVECTOR& P3, D3DVECTOR& Test_Point);
__declspec( dllexport ) short _stdcall RayTriCollision(D3DVECTOR& vOut, D3DVECTOR& P0, D3DVECTOR& P1, D3DVECTOR& P2, D3DVECTOR& vRay0, D3DVECTOR& vRay1);
__declspec( dllexport ) short _stdcall DirTriCollision(D3DVECTOR& vOut, D3DVECTOR& P0, D3DVECTOR& P1, D3DVECTOR& P2, D3DVECTOR& vFrom, D3DVECTOR& vDir);
__declspec( dllexport ) void _stdcall AnimateLinear(MDLVERTEX *vOut, MDLVERTEX *vFrame0, MDLVERTEX *vFrame1, long nVerts, float t, D3DVECTOR& vmin, D3DVECTOR& vmax, D3DVECTOR& position);
__declspec( dllexport ) void _stdcall AnimateCatmullRom(MDLVERTEX *vOut, MDLVERTEX *vFrame0, MDLVERTEX *vFrame1, MDLVERTEX *vFrame2, MDLVERTEX *vFrame3, long nVerts, float t, D3DVECTOR& vmin, D3DVECTOR& vmax, D3DVECTOR& position);