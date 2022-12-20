

.DATA
int stride = 1
const WIDTH = 240; 480
const HEIGHT = 180; 360
const INF = 1000000000
int color_buffer[HEIGHT][WIDTH]
float deep_buffer[HEIGHT][WIDTH]
int charLevel[64]
int buffer[200000]
int n_vertices = 0
int n_triangles = 0
Vec3 vertices[10000]
Triangle triangles[10000]
Camera camera
int ct = 0
int rate = 16; 60 fps

.CODE
; ----------------------------------------------------------------------- Math ----------------------------------------------------------------------- ;
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

def triangle_Interpolate(Vec3 p, Vec3 v0, Vec3 v1, Vec3 v2) -> (Vec3):
    Vec3 f0 = v0 - p
    Vec3 f1 = v1 - p
    Vec3 f2 = v2 - p

    float w = Vec3.cross(v0-v1, v0-v2).length()
    float w0 = Vec3.cross(f1, f2).length() / w
    float w1 = Vec3.cross(f2, f0).length() / w
    float w2 = Vec3.cross(f0, f1).length() / w

    return Vec3(w0, w1, w2)
endf



; ---------------------------------------------------------------------- Model ----------------------------------------------------------------------- ;

; triangle needs to be added before vertex
def add_vertex(Vec3 v):
    vertices[n_vertices] = v
    n_vertices = n_vertices + 1
endf

def add_triangle(Triangle t):
    triangles[n_triangles] = t
    n_triangles = n_triangles + 1
endf

def add_pyramid(Vec3 pos, float w, float h):
    float r = w / 2
    add_triangle(Triangle(0, 1, 2))
    add_triangle(Triangle(0, 2, 3))
    add_triangle(Triangle(0, 3, 4))
    add_triangle(Triangle(0, 4, 1))
    add_vertex(Vec3(pos.x, pos.y, pos.z + h))
    add_vertex(Vec3(pos.x + r, pos.y + r, pos.z))
    add_vertex(Vec3(pos.x - r, pos.y + r, pos.z))
    add_vertex(Vec3(pos.x - r, pos.y - r, pos.z))
    add_vertex(Vec3(pos.x + r, pos.y - r, pos.z))
endf

def add_box(Vec3 pos, float w, float h):
    float r = w / 2
    ; top
    add_triangle(Triangle(0, 2, 1))
    add_triangle(Triangle(0, 3, 2))
    ; bottom
    add_triangle(Triangle(4, 5, 6))
    add_triangle(Triangle(4, 6, 7))
    ; back
    add_triangle(Triangle(2, 6, 7))
    add_triangle(Triangle(2, 3, 7))
    ; right
    add_triangle(Triangle(3, 4, 7))
    add_triangle(Triangle(3, 0, 4))
    ; front
    add_triangle(Triangle(0, 5, 4))
    add_triangle(Triangle(0, 1, 5))
    ; left
    add_triangle(Triangle(1, 2, 6))
    add_triangle(Triangle(1, 6, 5))

    add_vertex(Vec3(pos.x + r, pos.y + r, pos.z))
    add_vertex(Vec3(pos.x - r, pos.y + r, pos.z))
    add_vertex(Vec3(pos.x - r, pos.y - r, pos.z))
    add_vertex(Vec3(pos.x + r, pos.y - r, pos.z))
    add_vertex(Vec3(pos.x + r, pos.y + r, pos.z + h))
    add_vertex(Vec3(pos.x - r, pos.y + r, pos.z + h))
    add_vertex(Vec3(pos.x - r, pos.y - r, pos.z + h))
    add_vertex(Vec3(pos.x + r, pos.y - r, pos.z + h))
endf


; ---------------------------------------------------------------------- Render ---------------------------------------------------------------------- ;
def build_char_level():
    charLevel[00] = 32
    charLevel[01] = 46
    charLevel[02] = 39
    charLevel[03] = 45
    charLevel[04] = 44
    charLevel[05] = 58
    charLevel[06] = 95
    charLevel[07] = 34
    charLevel[08] = 59
    charLevel[09] = 60
    charLevel[10] = 62
    charLevel[11] = 47
    charLevel[12] = 92
    charLevel[13] = 33
    charLevel[14] = 43
    charLevel[15] = 42
    charLevel[16] = 61
    charLevel[17] = 94
    charLevel[18] = 76
    charLevel[19] = 74
    charLevel[20] = 63
    charLevel[21] = 84
    charLevel[22] = 89
    charLevel[23] = 40
    charLevel[24] = 41
    charLevel[25] = 55
    charLevel[26] = 67
    charLevel[27] = 70
    charLevel[28] = 50
    charLevel[29] = 49
    charLevel[30] = 73
    charLevel[31] = 51
    charLevel[32] = 53
    charLevel[33] = 90
    charLevel[34] = 91
    charLevel[35] = 93
    charLevel[36] = 83
    charLevel[37] = 86
    charLevel[38] = 69
    charLevel[39] = 65
    charLevel[40] = 88
    charLevel[41] = 80
    charLevel[42] = 71
    charLevel[43] = 79
    charLevel[44] = 85
    charLevel[45] = 52
    charLevel[46] = 75
    charLevel[47] = 37
    charLevel[48] = 78
    charLevel[49] = 72
    charLevel[50] = 87
    charLevel[51] = 35
    charLevel[52] = 48
    charLevel[53] = 77
    charLevel[54] = 36
    charLevel[55] = 68
    charLevel[56] = 82
    charLevel[57] = 57
    charLevel[58] = 81
    charLevel[59] = 54
    charLevel[60] = 66
    charLevel[61] = 64
    charLevel[62] = 56
    charLevel[63] = 38
endf

push_render_buffer Macro c, p
    mov eax, p
    mov ebx, c
    mov BYTE PTR buffer[eax], bl
    inc p
ENDM

def display():
    int p = 0
	for i in range(HEIGHT):
	    for j in range(WIDTH):
            int color = color_buffer[i][j]
            int char = charLevel[color]
            push_render_buffer char, p
        endl
        push_render_buffer 10, p
    endl
    push_render_buffer 0, p

    ; call Clrscr
    mov edx, OFFSET buffer
    call WriteString
endf

def clear_buffer():
    for i in range(HEIGHT):
        for j in range(WIDTH):
            color_buffer[i][j] = 0
            deep_buffer[i][j] = INF
        endl
    endl
endf

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

; def rayTriangleIntersect(Vec3 p0, Vec3 p1, Triangle tri) -> (float, Vec3):
;     Vec3 v0 = vertices[tri.p0]
;     Vec3 v1 = vertices[tri.p1]
;     Vec3 v2 = vertices[tri.p2]
; 
;     Vec3 v0v1 = v1 - v0
;     Vec3 v0v2 = v2 - v0
;     Vec3 N = v0v1.cross(v0v2)
;     return rayPlaneIntersect(p0, p1, N)
; endf

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

class Camera:
    def init():
        Vec3 self.pos = Vec3(-100, 0, 0)
        Vec3 self.near = Vec3(40, 30, 40)
        Vec3 self.near_gp
        Matrix3 self.axis
        Matrix3 self.inv_axis
        self.set_axis(Matrix3(Vec3(0, 0, -1), Vec3(-1, 0, 0), Vec3(0, -1, 0)))
        Vec3 self.canvas_offset = Vec3(WIDTH / 2, HEIGHT / 2, 0)
        Vec3 self.canvas_scale = Vec3(WIDTH / self.near.x, HEIGHT / self.near.y, 1)

        float self.env_light = 0.5
        Vec3 self.sun_dir = Vec3(1, 0, 1).norm()
        float self.sun = 0.5

        int self.cnt = 0
    endf

    def set_axis(Matrix3 axis):
        self.axis = axis
        self.inv_axis = axis.inv() 
        self.near_gp = self.pos - self.inv_axis.w.mulc(self.near.z)
    endf

    def render():
        clear_buffer()
        for i in range(n_triangles):
            self.render_triangle(triangles[i])
        endl
    endf

    def render_triangle(Triangle tri):
        self.cnt = self.cnt + 3

        float t1, t2, t3
        Vec3 gp1, gp2, gp3

        Vec3 v1 = vertices[tri.p0]
        Vec3 v2 = vertices[tri.p1]
        Vec3 v3 = vertices[tri.p2]

        t1, gp1 = rayPlaneIntersect(self.pos, v1, self.near_gp, self.inv_axis.w)
        t2, gp2 = rayPlaneIntersect(self.pos, v2, self.near_gp, self.inv_axis.w)
        t3, gp3 = rayPlaneIntersect(self.pos, v3, self.near_gp, self.inv_axis.w)

        if t1 < 0 && t2 < 0 && t3 < 0: return

        Vec3 N = Vec3.cross(v2 - v1, v3 - v1).norm()

        float d1 = (v1 - self.pos).length()
        float d2 = (v2 - self.pos).length()
        float d3 = (v3 - self.pos).length()

        Vec3 p1 = self.inv_axis.transform(gp1 - self.near_gp) * self.canvas_scale + self.canvas_offset
        Vec3 p2 = self.inv_axis.transform(gp2 - self.near_gp) * self.canvas_scale + self.canvas_offset
        Vec3 p3 = self.inv_axis.transform(gp3 - self.near_gp) * self.canvas_scale + self.canvas_offset

        float wf = (p2.y-p3.y) * (p1.x-p3.x) + (p3.x-p2.x) * (p1.y-p3.y)

        ; calculate light
        ; Vec3 h = (self.sun_dir + ).norm()
        float light = self.env_light + self.sun * max2f(0, N.dot(self.sun_dir))
        int color = light * 64
        ; N.print()
        ; printFloat light
        ; printInt color
        

	    ; fixed-point coordinates
        int X1 = 16 * p1.x
        int X2 = 16 * p2.x
        int X3 = 16 * p3.x
                
	    int Y1 = 16 * p1.y
        int Y2 = 16 * p2.y
        int Y3 = 16 * p3.y

	    ; Deltas
        int DX12 = X1 - X2
        int DX23 = X2 - X3
        int DX31 = X3 - X1

        int DY12 = Y1 - Y2
        int DY23 = Y2 - Y3
        int DY31 = Y3 - Y1

        ; Fixed-point deltas
        int FDX12 = DX12 << 4
        int FDX23 = DX23 << 4
        int FDX31 = DX31 << 4

        int FDY12 = DY12 << 4
        int FDY23 = DY23 << 4
        int FDY31 = DY31 << 4

        ; Bounding rectangle
        int minx = (min3i(X1, X2, X3) + 15) >> 4
        int maxx = (max3i(X1, X2, X3) + 15) >> 4
        int miny = (min3i(Y1, Y2, Y3) + 15) >> 4
        int maxy = (max3i(Y1, Y2, Y3) + 15) >> 4

        minx = max2i(minx, 0)
        maxx = min2i(maxx+1, WIDTH)
        miny = max2i(miny, 0)
        maxy = min2i(maxy+1, HEIGHT)

        ; Half-edge constants
        int C1 = DY12 * X1 - DX12 * Y1;
        int C2 = DY23 * X2 - DX23 * Y2;
        int C3 = DY31 * X3 - DX31 * Y3;

        ; Correct for fill convention
        if DY12 < 0 || (DY12 == 0 && DX12 > 0): C1 = C1 + 1
        if DY23 < 0 || (DY23 == 0 && DX23 > 0): C2 = C2 + 1
        if DY31 < 0 || (DY31 == 0 && DX31 > 0): C3 = C3 + 1

        int CY2 = C2 + DX23 * (miny << 4) - DY23 * (minx << 4)
        int CY1 = C1 + DX12 * (miny << 4) - DY12 * (minx << 4)
        int CY3 = C3 + DX31 * (miny << 4) - DY31 * (minx << 4)

        for y in range(miny, maxy):
            int CX1 = CY1
            int CX2 = CY2
            int CX3 = CY3

            for x in range(minx, maxx):
                if CX1 > 0 && CX2 > 0 && CX3 > 0:
                    float w1, w2, w3, d                    
                    w1 = ((p2.y-p3.y) * (x-p3.x) + (p3.x-p2.x) * (y-p3.y)) / wf
                    w2 = ((p3.y-p1.y) * (x-p3.x) + (p1.x-p3.x) * (y-p3.y)) / wf
                    w3 = 1 - w1 - w2
                    d = w1 * d1 + w2 * d2 + w3 * d3

                    if d < deep_buffer[y][x]:
                        ; draw pixel
                        color_buffer[y][x] = color
                        deep_buffer[y][x] = d
                    endif
                endif

                CX1 = CX1 - FDY12
                CX2 = CX2 - FDY23
                CX3 = CX3 - FDY31
            endl

            CY1 = CY1 + FDX12
            CY2 = CY2 + FDX23
            CY3 = CY3 + FDX31

        endl
		
    endf
endc

; class Player:
;     def init():
;         Vec self.pos
;         Vec self.rot
;     endf
; 
;     def update():
;         
;     endf
; endc

; def testRayTriangleIntersect():
;     Vec3 pos = Vec3(-20, -10, 0)
;     Vec3 dir = Vec3(30, 30, 5)
;     add_triangle(Triangle(2, 1, 0))
;     add_vertex(Vec3(10,30,0))
;     add_vertex(Vec3(30,10,0))
;     add_vertex(Vec3(30,30,20))
;     float t
;     Vec3 p
;     t, p = rayTriangleIntersect(pos, dir, triangles[0])
;     printFloat t
;     p.print()
; endf

def testRender():
    for i in range(2):
        for j in range(2):
            add_pyramid(Vec3(j*15,i*15-30,-30), 10, 10)
        endl
    endl
    camera.render()
    display()
endf

def get_time() -> (int):
    int t
    call GetMseconds
    mov t, eax
    return t
endf

def testRenderAnimation():
    for i in range(5):
        for j in range(5):
            add_pyramid(Vec3(j*15,i*15-30,-30), 10, 10)
        endl
    endl
    ct = get_time()
    int t
    while True:
        ; vertices[0].y = vertices[0].y + 1
        ; if vertices[0].y > 50: vertices[0].y = 0
        camera.pos.x = camera.pos.x - 0.5
        camera.pos.x = camera.pos.x - 0.1
        camera.render()
        while t - ct < rate:
            t = get_time()
        endl
        int x = t - ct
        ; printInt x
        display()
        ct = t
    endl
endf

def testRenderTriangle():
    add_triangle(Triangle(0, 1, 2))
    add_vertex(Vec3(0,-50,-37.5))
    add_vertex(Vec3(0,50,-37.5))
    add_vertex(Vec3(0,0,37.5))
    clear_buffer()
    camera.render_triangle(triangles[0])
    display()
endf

; ----------------------------------------------------------------------- Main ----------------------------------------------------------------------- ;
def main():
    build_char_level()
    camera = Camera()
    ; testRayTriangleIntersect()
    ; testRender()
    testRenderAnimation()
    ; testRenderTriangle()
    call WaitMsg
endf
