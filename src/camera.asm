.CODE
class Distortion:
    def init(Vec3 pos, float siz, int type):
        Vec3 self.pos = pos
        float self.siz = siz
        float self.r = 50
        float self.k = 1.5
        int self.type = type

        if self.type == 1:
            self.r = self.siz + self.siz ** self.k
        endif
    endf

    def need(Vec3 p) -> (int):
        if self.type == 0:
            return 0
        elif self.type == 1:
            Vec3 v = self.pos - p
            return v.length() < self.r
        elif self.type == 2:
            return fabs((p - self.pos).length() - self.r) < self.siz
        elif self.type == 3:
            return fabs(self.pos.x - p.x) < self.siz
        endif
    endf

    def update():
        if self.type == 1:
            float nx = max2f(player.pos.x - 100 - self.r, self.pos.x + 0.9 * player.max_speed * engine.dt)
            self.pos = Vec3(nx, player.pos.y, 40)
        elif self.type == 2:
            self.r = self.r + 10 * engine.dt
            if self.r > 500:
                self.type = 0
            endif
        elif self.type == 3:
            self.pos.x = self.pos.x + 200 * engine.dt
            if self.pos.x - player.pos.x > 1000:
                self.type = 0
            endif
        endif
    endf

    def distort(Vec3 p) -> (Vec3):
        if self.type == 1:
            Vec3 v = self.pos - p
            float d = v.length()
            float x = d - self.siz ** self.k
            if 0 < x && x < self.siz:
                 return v.mulc(((self.siz - x) ** self.k) / d)
            else:
                return self.pos - p
            endif
        elif self.type == 2:
            Vec3 v = p - self.pos
            float d = v.length()
            float x = d - self.r
            if fabs(x) < self.siz:
                 float k = 0.7
                 float t = (self.siz - ((self.siz * cos(x / 2 / self.siz * 3.1415926)) ** k) / (self.siz ** (k - 1))) * x / fabs(x)
                 return v.mulc((t - x) / d)
            else:
                return Vec3_zero()
            endif
        elif self.type == 3:
            float x = self.pos.x - p.x
            if fabs(x) < self.siz:
                 float h = 30
                 float t = (1 + cos(x * 3.1415926 / self.siz)) * h / 2
                 return Vec3(0, 0, t)
            else:
                return Vec3_zero()
            endif
        endif
    endf
endc

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

        Vec3 self.sun_dir = Vec3(1, 0, 1).norm()
        float self.env_light = 0.2
        float self.diffuse = 0.4
        float self.bloom = 0.4

        float self.mesh_size = 0.01

        float self.shake_start_time = 0
        float self.shake_magnitude = 0
        float self.shake_duration = 0

        int self.cnt = 0

        int self.n_distortions = 10
        Distortion self.distortions[10]
        for i in range(self.n_distortions):
            self.distortions[i].type = 0
        endl
    endf

    def add_distortion(Distortion d):
        for i in range(self.n_distortions):
            if self.distortions[i].type == 0:
                self.distortions[i] = d
                return
            endif
        endl
    endf

    def need_distort(Vec3 p) -> (int):
        for i in range(self.n_distortions):
            if self.distortions[i].need(p) == 1: return 1
        endl
        return 0
    endf

    def distort(Vec3 p) -> (Vec3):
        Vec3 r = p
        for i in range(self.n_distortions):
            if self.distortions[i].type > 0:
                r = r + self.distortions[i].distort(p)
            endif
        endl
        return r
    endf

    def set_axis(Matrix3 axis):
        self.axis = axis
        self.inv_axis = axis.inv() 
        self.near_gp = self.pos + self.inv_axis.w.mulc(self.near.z)
    endf

    def set_inv_axis(Matrix3 inv_axis):
        self.inv_axis = inv_axis 
        self.axis = inv_axis.inv() 
        self.near_gp = self.pos + self.inv_axis.w.mulc(self.near.z)
    endf

    def render():
        self._shake()
        for i in range(self.n_distortions):
            self.distortions[i].update()
        endl
        clear_buffer()
        for i in range(n_triangles):
            Triangle tri = triangles[i]
            Vec3 p0 = vertices[tri.p0]
            Vec3 p1 = vertices[tri.p1]
            Vec3 p2 = vertices[tri.p2]

            Vec3 bound = self.distortions[0].pos
            float bound_r = self.distortions[0].r - self.distortions[0].siz
            float bound_x = bound.x
            if (p0.x < bound_x || (p0 - bound).length() < bound_r) && \
               (p1.x < bound_x || (p1 - bound).length() < bound_r) && \
               (p2.x < bound_x || (p2 - bound).length() < bound_r):
                continue
            endif

            ; clip near
            if self.visible(p0) == 0 && self.visible(p1) == 0 && self.visible(p2) == 0:
                continue
            endif
            
            float l0 = (p1 - p2).length()
            float l1 = (p0 - p2).length()
            float l2 = (p0 - p1).length()
            
            ; int x0 = self.need_distort(p0)
            ; int x1 = self.need_distort(p1)
            ; int x2 = self.need_distort(p2)

            if self.need_distort(p0) == 1 || self.need_distort(p1) == 1 || self.need_distort(p2):
                if l0 > l1 && l0 > l2:
                    self.seperate_triangle(p0, p1, p2)
                elif l1 > l2:
                    self.seperate_triangle(p1, p2, p0)
                else:
                    self.seperate_triangle(p2, p0, p1)
                endif
            else:
                self.render_triangle(p2, p1, p0)
            endif
        endl
    endf

    def seperate_triangle(Vec3 p0, Vec3 p1, Vec3 p2):
        Vec3 p = (p1 + p2).mulc(0.5)
        if (p1 - p2).length() < (p - self.pos).length() * self.mesh_size:
            self.render_triangle(self.distort(p2), self.distort(p1), self.distort(p0))
        else:
            self.seperate_triangle(p, p0, p1)
            self.seperate_triangle(p, p2, p0)
        endif
    endf

    def visible(Vec3 p) -> (int):
        float t
        Vec3 gp
        t, gp = rayPlaneIntersect(self.pos, p, self.near_gp, self.inv_axis.w)
        Vec3 cp = self.inv_axis.transform(gp - self.near_gp) * self.canvas_scale + self.canvas_offset
        int x = cp.x
        int y = cp.y
        return x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT && t > 0
    endf

    def shake(float magnitude, float duration):
        self.shake_start_time = engine.time
        self.shake_magnitude = magnitude
        self.shake_duration = duration
    endf

    def _shake():
        float t = engine.time - self.shake_start_time
        if t <= self.shake_duration:
            float k = self.shake_magnitude * t / self.shake_duration
            self.pos = self.pos + Vec3(rand(0-k, k), rand(0-k, k), rand(0-k, k))
        endif
    endf

    def render_triangle(Vec3 v1, Vec3 v2, Vec3 v3):
        self.cnt = self.cnt + 3

        float t1, t2, t3
        Vec3 gp1, gp2, gp3

        t1, gp1 = rayPlaneIntersect(self.pos, v1, self.near_gp, self.inv_axis.w)
        t2, gp2 = rayPlaneIntersect(self.pos, v2, self.near_gp, self.inv_axis.w)
        t3, gp3 = rayPlaneIntersect(self.pos, v3, self.near_gp, self.inv_axis.w)

        if t1 < 0 || t2 < 0 || t3 < 0: return

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
        float _light = self.env_light + self.diffuse * max2f(0, N.dot(self.sun_dir))
        
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
                        Vec3 v = Vec3(w1*v1.x + w2*v2.x + w3*v3.x, w1*v1.y + w2*v2.y + w3*v3.y, w1*v1.z + w2*v2.z + w3*v3.z).norm()
                        Vec3 h = (self.sun_dir + v).norm()
                        float light = _light + max2f(0, N.dot(h)) * self.bloom
                        int color = light * 64
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