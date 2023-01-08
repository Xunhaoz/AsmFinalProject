.DATA
const INF = 1000000000

.CODE
def fsqrt(float x) -> (float):
    ffsqrt x, x
    return x
endf

def fabs(float x) -> (float):
    ffabs x, x
    return x
endf

def sin(float x) -> (float):
    ffld x
    fsin
    fstp x
    return x
endf

def cos(float x) -> (float):
    ffld x
    fcos
    fstp x
    return x
endf

def rand(float x, float y) -> (float):
    int ri
    call Random32
    mov ri, eax
    float mean = (x + y) / 2
    return (ri + 0.5) / 2147483647.5 / 2 * (y - x) + (x + y) / 2
endf

; def round(float x) -> (int):
;     ffld x
;     fstcw fcw
; 	or fcw, 0000110000000000b
; 	fldcw fcw
;     int y
; 	fistp y
;     return y
; endf

def min2i(int x, int y) -> (int):
    if x < y: return x
    return y
endf

def max2i(int x, int y) -> (int):
    if x > y: return x
    return y
endf

def min2f(float x, float y) -> (float):
    if x < y: return x
    return y
endf

def max2f(float x, float y) -> (float):
    if x > y: return x
    return y
endf

def min3i(int x, int y, int z) -> (int):
    if x < y && x < z: 
        return x
    elif y < z:
        return y
    else:
        return z
    endif
endf

def max3i(int x, int y, int z) -> (int):
    if x > y && x > z: 
        return x
    elif y > z:
        return y
    else:
        return z
    endif
endf

; def max5f(float a, float b, float c, float d, float e) -> (float):
;     if a > b && a > c && a > d && a > e:
;         return a
;     elif b > c && b > d && b > e:
;         return b
;     elif c > d && c > e:
;         return c
;     elif d > e:
;         return d
;     else:
;         return e
; endf
; 
; def min5f(float a, float b, float c, float d, float e) -> (float):
;     if a < b && a < c && a < d && a < e:
;         return a
;     elif b < c && b < d && b < e:
;         return b
;     elif c < d && c < e:
;         return c
;     elif d < e:
;         return d
;     else:
;         return e
; endf

class Vec2:
	def init(float x, float y):
		float self.x = x
		float self.y = y
	endf
                    
    def add(Vec2 other) -> (Vec2):
        return Vec2(self.x + other.x, self.y + other.y)
    endf
                
    def sub(Vec2 other) -> (Vec2):
        return Vec2(self.x - other.x, self.y - other.y)
    endf

    def mulc(float other) -> (Vec2):
        return Vec2(self.x * other, self.y * other)
    endf
                
    def length() -> (float):
        return fsqrt(self.x * self.x + self.y * self.y)
    endf

    def dot(Vec2 other) -> (float):
        return self.x * other.x + self.y * other.y
    endf

    def norm() -> (Vec2):
        float l = self.length()
        return Vec2(self.x / l, self.y / l)
    endf
                
    def print():
        printFloat self.x
        printFloat self.y
        printEndl
    endf 
endc

class Vec3:
    def init(float x, float y, float z):
        float self.x = x
        float self.y = y
        float self.z = z
    endf
                
    def add(Vec3 other) -> (Vec3):
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)
    endf
                
    def sub(Vec3 other) -> (Vec3):
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)
    endf

    def mul(Vec3 other) -> (Vec3):
        return Vec3(self.x * other.x, self.y * other.y, self.z * other.z)
    endf

    def mulc(float other) -> (Vec3):
        return Vec3(self.x * other, self.y * other, self.z * other)
    endf
                
    def length() -> (float):
        return fsqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    endf

    def dot(Vec3 other) -> (float):
        return self.x * other.x + self.y * other.y + self.z * other.z
    endf

    def cross(Vec3 other) -> (Vec3):
        return Vec3(self.y * other.z - other.y * self.z, other.x * self.z - self.x * other.z, self.x * other.y - other.x * self.y)
    endf

    def toVec2() -> (Vec2):
        return Vec2(self.x, self.y)
    endf

    def norm() -> (Vec3):
        float l = self.length()
        return Vec3(self.x / l, self.y / l, self.z / l)
    endf
                
    def print():
        printFloat self.x
        printFloat self.y
        printFloat self.z
        printEndl
    endf          
endc

def Vec3_zero() -> (Vec3):
    return Vec3(0, 0, 0)
endf

def Vec3_one() -> (Vec3):
    return Vec3(1, 1, 1)
endf

class Matrix3:
    ; u, v, w are rows
    def init(Vec3 u, Vec3 v, Vec3 w):
        Vec3 self.u = u
        Vec3 self.v = v
        Vec3 self.w = w
    endf

    def transform(Vec3 other) -> (Vec3):
        return Vec3(self.u.dot(other), self.v.dot(other), self.w.dot(other))
    endf

    def transpose() -> (Matrix3):
        return Matrix3(Vec3(self.u.x, self.v.x, self.w.x), Vec3(self.u.y, self.v.y, self.w.y), Vec3(self.u.z, self.v.z, self.w.z))
    endf

    def mul(Matrix3 other) -> (Matrix3):
        Matrix3 ot = other.transpose()
        return Matrix3(\
            Vec3(Vec3.dot(self.u, ot.u), Vec3.dot(self.u, ot.v), Vec3.dot(self.u, ot.w)),\
            Vec3(Vec3.dot(self.v, ot.u), Vec3.dot(self.v, ot.v), Vec3.dot(self.v, ot.w)),\
            Vec3(Vec3.dot(self.w, ot.u), Vec3.dot(self.w, ot.v), Vec3.dot(self.w, ot.w))\
        )
    endf

    def inv() -> (Matrix3):
        float det = self.u.x * (self.v.y * self.w.z - self.w.y * self.v.z) - \
                    self.u.y * (self.v.x * self.w.z - self.v.z * self.w.x) + \
                    self.u.z * (self.v.x * self.w.y - self.v.y * self.w.x)

        float invdet = 1 / det

        Matrix3 inv
        inv.u.x = (self.v.y * self.w.z - self.w.y * self.v.z) * invdet
        inv.u.y = (self.u.z * self.w.y - self.u.y * self.w.z) * invdet
        inv.u.z = (self.u.y * self.v.z - self.u.z * self.v.y) * invdet
        inv.v.x = (self.v.z * self.w.x - self.v.x * self.w.z) * invdet
        inv.v.y = (self.u.x * self.w.z - self.u.z * self.w.x) * invdet
        inv.v.z = (self.v.x * self.u.z - self.u.x * self.v.z) * invdet
        inv.w.x = (self.v.x * self.w.y - self.w.x * self.v.y) * invdet
        inv.w.y = (self.w.x * self.u.y - self.u.x * self.w.y) * invdet
        inv.w.z = (self.u.x * self.v.y - self.v.x * self.u.y) * invdet

        return inv
    endf

    def print():
        self.u.print()
        self.v.print()
        self.w.print()
        printEndl
    endf
endc

def Matrix3_identity() -> (Matrix3):
    return Matrix3(Vec3(1, 0, 0), Vec3(0, 1, 0), Vec3(0, 0, 1))
endf

class AngleAxis:
    def init(Vec3 axis, float angle):
        Vec3 self.axis = axis
        float self.angle = angle
    endf

    def rotate(Vec3 v) -> (Vec3):
        return v.mulc(cos(self.angle)) + self.axis.cross(v).mulc(sin(self.angle)) + self.axis.mulc(1 - cos(self.angle) * self.axis.dot(v))
    endf
endc

class Triangle:
    def init(int p0, int p1, int p2):
        int self.p0 = p0 + n_vertices
        int self.p1 = p1 + n_vertices
        int self.p2 = p2 + n_vertices
    endf
endc

def rayPlaneIntersect(Vec3 p0, Vec3 p1, Vec3 P, Vec3 N) -> (float, Vec3):
    Vec3 dir = (p1 - p0).norm()
    float NdotRayDirection = N.dot(dir)
    if fabs(NdotRayDirection) < 0.000001:
        return INF, None
    endif

    float t = N.dot(P - p0) / NdotRayDirection
    return t, p0 + dir.mulc(t)
endf

def rayPlaneDist(Vec3 p0, Vec3 p1, Vec3 P, Vec3 N) -> (float):
    Vec3 dir = (p1 - p0).norm()
    float NdotRayDirection = N.dot(dir)
    if fabs(NdotRayDirection) < 0.000001:
        return INF
    endif
    return N.dot(P - p0) / NdotRayDirection
endf

def deg2rad(float deg) -> (float):
    return deg * 3.1415926 / 180
endf

def axisAngle2Matrix(Vec3 v, float angle) -> (Matrix3):
    angle = deg2rad(angle)

    float x = v.x
    float y = v.y
    float z = v.z

    float c = cos(angle)
    float s = sin(angle)
    float t = 1.0 - c

    return Matrix3(\
        Vec3(t*x*x + c, t*x*y - z*s, t*x*z + y*s),\
        Vec3(t*x*y + z*s, t*y*y + c, t*y*z - x*s),\
        Vec3(t*x*z - y*s, t*y*z + x*s, t*z*z + c)\
    )
endf

; def rayTriangleIntersect(Vec3 pos, Vec3 dir, Triangle tri) -> (float, Vec3):
; 
;     Vec3 v0 = vertices[tri.p0]
;     Vec3 v1 = vertices[tri.p1]
;     Vec3 v2 = vertices[tri.p2]
; 
;     t, p = rayPlaneIntersect(pos, dir, v0, v1, v2)
;     if t == INF: return INF, None
; 
;     Vec3 C, edge, vp
;     
;     ; edge 0
;     edge = v1 - v0
;     vp = p - v0
;     C = edge.cross(vp)
;     if N.dot(C) < 0: return INF, None
;     
;     ; edge 1
;     edge = v2 - v1
;     vp = p - v1
;     C = edge.cross(vp)
;     if N.dot(C) < 0: return INF, None
;     
;     ; edge 2
;     edge = v0 - v2
;     vp = p - v2
;     C = edge.cross(vp)
;     if N.dot(C) < 0: return INF, None
;     
;     return t, p
; endf