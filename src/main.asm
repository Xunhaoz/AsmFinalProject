import engine

.DATA
Player player
Terrain terrain

.CODE
class PD:
    def init(float kp, float kd):
        float self.pre_err = 0
        float self.kp = kp
        float self.kd = kd
    endf

    def step(float p, float target) -> (float):
        float err = target - p
        float deri = (err - self.pre_err) / engine.dt
        float y = self.kp * err + self.kd * deri
        self.pre_err = err
        return y
    endf
endc

class Vec3PD:
    def init(Vec3 kp, Vec3 kd):
        Vec3 self.pre_err = Vec3_zero()
        Vec3 self.kp = kp
        Vec3 self.kd = kd
    endf

    def step(Vec3 p, Vec3 target) -> (Vec3):
        Vec3 err = target - p
        Vec3 deri = (err - self.pre_err).mulc(1 / engine.dt)
        Vec3 y = self.kp * err + self.kd * deri
        self.pre_err = err
        return y
    endf
endc

class Player:
    def init():
        float self.max_speed = 300
        float self.speed = 300
        Vec3 self._pos = Vec3(0, 0, 10)
        Vec3 self.pos = Vec3(0, 0, 10)
        Matrix3 self._rot = Matrix3(Vec3(0, 0, -1), Vec3(-1, 0, 0), Vec3(0, 1, 0))
        ; Matrix3 self._rot = Matrix3_identity()
        Vec3 self.scale = Vec3(3, 3, 3)

        Vec3 self.camera_pos = Vec3(0, -89, -600)
        Vec3 self.camera_vel = Vec3(0, 0, 0)
        Vec3 self.camera_tar_pos = Vec3(0, 0, -80)
        Vec3PD self.camera_ctr = Vec3PD(Vec3(0.1, 0.1, 0.1), Vec3(5, 5, 5))

        Vec3 self.rot = Vec3_zero()
        Vec3 self.rot_v = Vec3_zero()
        float self.rot_tar_x = 0
        PD self.rot_x_ctr = PD(5, 4)

        float self.dead_time = -1
    endf

    def collide() -> (int):
        Vec3 w = self._pos - self.pos
        float d = w.length()
        for i in range(d):
            Vec3 t = self.pos + w.mulc(i / d)
            Vec3 a = t + Vec3(2.877, 0, 0) * self.scale
            Vec3 b = t + Vec3(-2.135, 3.393, 0) * self.scale
            Vec3 c = t + Vec3(-2.135, -3.393, 0) * self.scale
            Vec3 u = a - b
            float dd = u.length()
            for j in range(dd):
                if terrain.collide(b + u.mulc(j / dd)) == 1: return 1
            endl
            Vec3 u = a - c
            float dd = u.length()
            for j in range(dd):
                if terrain.collide(c + u.mulc(j / dd)) == 1: return 1
            endl
        endl
        return 0
    endf

    def update():
        ; if keyboard.d == 1:
        ;     self.camera_pos.x = self.camera_pos.x + 0.1
        ; elif keyboard.a == 1:
        ;     self.camera_pos.x = self.camera_pos.x - 0.1
        ; elif keyboard.q == 1:
        ;     self.camera_pos.z = self.camera_pos.z + 1
        ; elif keyboard.e == 1:
        ;     self.camera_pos.z = self.camera_pos.z - 1
        ; elif keyboard.w == 1:
        ;     self.camera_pos.y = self.camera_pos.y + 0.1
        ; elif keyboard.s == 1:
        ;     self.camera_pos.y = self.camera_pos.y - 0.1
        ; endif

        if keyboard.d == 1:
            self.camera_tar_pos = Vec3(0, 0, -80)
        elif keyboard.e == 1:
            self.camera_tar_pos = Vec3(-45, -45, -300)
        elif keyboard.w == 1:
            self.camera_tar_pos = Vec3(0, -89, -600)
        elif keyboard.q == 1:
            self.camera_tar_pos = Vec3(30, -180, -300)
        elif keyboard.a == 1:
            ; camera.add_distortion(Distortion(self.pos, 50, 2))
            camera.add_distortion(Distortion(Vec3(self.pos.x - 200, 0, 0), 50, 3))
        endif

        if keyboard.left == 1:
            self.rot_tar_x = -15
        elif keyboard.right == 1:
            self.rot_tar_x = 15
        elif keyboard.down == 1:
            self.rot_tar_x = 0
        endif

        ; if self.pos.x > 1000:
        ;     self.speed = 0
        ; endif

        ; self.rot_x_ctl_test()

        ; dead
        if camera.distortions[0].need(self.pos) == 1:
            self.dead_time = engine.time
        endif

        if self.dead_time > 0: return


        ; player
        if self.speed < self.max_speed:
            self.speed = self.speed + 150 * engine.dt
        endif

        self.rot_v.x = self.rot_v.x + self.rot_x_ctr.step(self.rot.x, self.rot_tar_x) * engine.dt
        self.rot.x = self.rot.x + self.rot_v.x * engine.dt
        self.rot.z = 0 - self.rot.x
        Matrix3 rot = axisAngle2Matrix(Vec3(1, 0, 0), self.rot.x) * axisAngle2Matrix(Vec3(0, 1, 0), self.rot.y) * axisAngle2Matrix(Vec3(0, 0, 1), self.rot.z)
        self._pos = self.pos
        self.pos = self.pos + rot.u.mulc(self.speed * engine.dt) * Vec3(1, -1, 1)

        ; camera
        self.camera_vel = self.camera_vel + self.camera_ctr.step(self.camera_pos, self.camera_tar_pos).mulc(engine.dt)
        self.camera_pos = self.camera_pos + self.camera_vel.mulc(engine.dt)

        float theta = deg2rad(self.camera_pos.x)
        float phi = deg2rad(self.camera_pos.y)
        float local_camera_x = cos(theta) * cos(phi)
        float local_camera_y = sin(theta) * cos(phi)
        float local_camera_z = sin(phi)
        camera.pos = self.pos + Vec3(local_camera_x, local_camera_y, local_camera_z).mulc(self.camera_pos.z)
        Vec3 camera_w = Vec3_zero() - (camera.pos - self.pos).norm()
        Vec3 camera_u = Vec3.cross(camera_w, Vec3(0, 0, 1)).norm()
        Vec3 camera_v = Vec3.cross(camera_w, camera_u).norm()
        camera.set_inv_axis(Matrix3(camera_u, camera_v, camera_w))

        ; collide
        if self.collide() == 1:
            camera.shake(5, 0.5)
            self.speed = 150
        endif

        mm.set_transform(self.pos, rot * self._rot, self.scale)
        mm.add_spaceship()
    endf

    def rot_x_ctl_test():
        ; PID test
        if keyboard.q == 1:
            self.rot_x_ctr.kp = self.rot_x_ctr.kp + 0.1
        elif keyboard.a == 1:
            self.rot_x_ctr.kp = self.rot_x_ctr.kp - 0.1
        elif keyboard.e == 1:
            self.rot_x_ctr.kd = self.rot_x_ctr.kd + 0.1
        elif keyboard.d == 1:
            self.rot_x_ctr.kd = self.rot_x_ctr.kd - 0.1
        endif

        printFloat self.rot_x_ctr.kp
        printFloat self.rot_x_ctr.kd
        printEndl
    endf
endc    

class Obstacle:
    def init(Vec3 pos, int w, int h, int type):
        Vec3 self.pos = pos
        int self.type = type
        float self.w = w
        float self.h = h
    endf

    def collide(Vec3 p) -> (int):
        Vec3 d = p - self.pos
        if self.type == 1:
            float b = d.z * self.w / self.h
            return 0 <= d.z && d.z < self.h && fabs(d.x) < b && fabs(d.y) < b
        elif self.type == 2:
            return 0 <= d.z && d.z < self.h && fabs(d.x) < self.w && fabs(d.y) < self.w
        endif
    endf

    def update():
        if self.type == 1:
            mm.add_pyramid(self.pos, self.w, self.h)
        elif self.type == 2:
            mm.add_box(self.pos, self.w, self.h)
        endif
    endf
endc

class Terrain:
    def init():
        float self.x = 1000
        float self.gen_x = 1000
        float self.gen_y = 500

        int self.n_obs = 0
        int self.p_obs = 0
        int self.max_obs = 2000
        Obstacle self.obstacles[2000]

        float self.siz = 100
        int self.stage = 1
    endf

    def collide(Vec3 p) -> (int):
        for i in range(self.n_obs):
            if self.obstacles[i].collide(p) == 1:
                return 1
            endif
        endl
        return 0
    endf

    def add_obstacle(Vec3 pos, int w, int h, int type):
        self.obstacles[self.p_obs] = Obstacle(pos, w, h, type)
        self.n_obs = min2i(self.n_obs + 1, self.max_obs)
        self.p_obs = (self.p_obs + 1) % self.max_obs
    endf

    def update(Vec3 player_pos):
        self.generate_terrain(player_pos)
        mm.set_transform(Vec3_zero(), Matrix3_identity(), Vec3_one())
        for i in range(self.n_obs):
            self.obstacles[i].update()
        endl
        ; mm.add_plane(player_pos)
    endf

    def generate_sub_terrain(Vec3 pos, float siz):
        float w, h, nw, nh
        float nsiz = siz / 3
        float rid = rand(0, 1)
        if rid < 0.0075:
            w = siz * 4 / 5
            self.add_obstacle(pos, w, w, 1)
        elif rid < 0.020 && siz < 15:
            w = siz
            h = rand(40, 70)
            self.add_obstacle(pos, w, h, 1)
        elif siz >= 30:
            self.generate_sub_terrain(pos + Vec3(nsiz * 0, nsiz * 0, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 0, nsiz * 1, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 0, nsiz * 2, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 1, nsiz * 0, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 1, nsiz * 1, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 1, nsiz * 2, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 2, nsiz * 0, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 2, nsiz * 1, 0), nsiz)
            self.generate_sub_terrain(pos + Vec3(nsiz * 2, nsiz * 2, 0), nsiz)
        endif
    endf

    def generate_terrain(Vec3 pos):
        float tar_x = pos.x + self.gen_x
        float tar_y = pos.y + self.gen_y / 2
        float y = pos.y - self.gen_y / 2
        y = y - y % self.siz
        while self.x < tar_x:
            while y < tar_y:
                self.generate_sub_terrain(Vec3(self.x, y, 0), self.siz)
                y = y + self.siz
            endl
            self.x = self.x + self.siz
        endl
    endf
endc

def init():
    player = Player()
    terrain = Terrain()
    
    engine.update_time()
    engine.step()

    while keyboard.up == 0:
        keyboard.update()
        camera.render()
        display()
    endl

    engine.update_time()
    camera.distortions[0] = Distortion(Vec3(-10000, 0, 0), 50, 1)
endf


def update():
    player.update()
    terrain.update(player.pos)

    if player.dead_time > 0 && engine.time - player.dead_time > 3:
        camera.distortions[0] = Distortion(Vec3(-10000, 0, 0), 0, 0)
        init()
    endif
endf
