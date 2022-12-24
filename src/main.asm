import engine

.DATA
Player player
Terrain terrain1

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

class Player:
    def init():
        float self.speed = 150
        Vec3 self.pos = Vec3_zero()
        Matrix3 self._rot = Matrix3(Vec3(0, 0, -1), Vec3(-1, 0, 0), Vec3(0, 1, 0))
        Vec3 self.scale = Vec3(3, 3, 3)
        Vec3 self.camera_offset = Vec3(30, 0, 10)

        Vec3 self.rot = Vec3_zero()
        Vec3 self.rot_v = Vec3_zero()
        float self.rot_tar_x = 0
        PD self.rot_x_ctr = PD(5, 4)
    endf

    def update():
        if keyboard.a == 1:
            self.camera_offset.x = self.camera_offset.x + 1
        elif keyboard.d == 1:
            self.camera_offset.x = self.camera_offset.x - 1
        elif keyboard.w == 1:
            self.camera_offset.z = self.camera_offset.z + 1
        elif keyboard.s == 1:
            self.camera_offset.z = self.camera_offset.z - 1
        elif keyboard.q == 1:
            self.camera_offset.y = self.camera_offset.y + 1
        elif keyboard.e == 1:
            self.camera_offset.y = self.camera_offset.y - 1
        endif

        if keyboard.left == 1:
            self.rot_tar_x = -30
        elif keyboard.right == 1:
            self.rot_tar_x = 30
        elif keyboard.down == 1:
            self.rot_tar_x = 0
        endif

        ; self.rot_x_ctl_test()

        self.rot_v.x = self.rot_v.x + self.rot_x_ctr.step(self.rot.x, self.rot_tar_x) * engine.dt
        self.rot.x = self.rot.x + self.rot_v.x * engine.dt
        self.pos.x = self.pos.x + self.speed * engine.dt

        Matrix3 rot = axisAngle2Matrix(Vec3(1, 0, 0), self.rot.x) * axisAngle2Matrix(Vec3(0, 1, 0), self.rot.y) * axisAngle2Matrix(Vec3(0, 0, 1), self.rot.z)
        camera.pos = self.pos - rot.u.mulc(self.camera_offset.x) - rot.v.mulc(self.camera_offset.y) - rot.w.mulc(self.camera_offset.z)
        Vec3 camera_w = (camera.pos - self.pos).norm()
        ; Vec3 camera_u = (Vec3(0, 0, 0) - rot.v).norm()
        ; Vec3 camera_w = (camera.pos - self.pos).norm()
        Vec3 camera_u = Vec3(0, -1, 0)
        Vec3 camera_v = Vec3.cross(camera_u, camera_w).norm()
        camera.set_inv_axis(Matrix3(camera_u, camera_v, camera_w))

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
        float self.h = 10
        float self.w = 10
    endf

    def update():
        if self.type == 1:
            mm.add_pyramid(self.pos, self.w, self.h)
        endif
    endf
endc

class Terrain:
    def init(Vec3 pos):
        Vec3 self.pos = pos
        int self.n_obstacles = 0
        Obstacle self.obstacles[2000]
    endf

    def add_obstacle(Vec3 pos, int w, int h, int type):
        self.obstacles[self.n_obstacles] = Obstacle(pos, w, h, type)
        self.n_obstacles = self.n_obstacles + 1
    endf

    def update():
        mm.set_transform(self.pos, Matrix3_identity(), Vec3_one())
        for i in range(self.n_obstacles):
            self.obstacles[i].update()
        endl
    endf
endc

def init():
    engine = Engine()
    player = Player()
    terrain1 = Terrain(Vec3_zero())
    for i in range(500):
        terrain1.add_obstacle(Vec3(50 + i * 15, 30, 0), 10, 10, 1)
        terrain1.add_obstacle(Vec3(50 + i * 15, -30, 0), 10, 10, 1)
    endl
endf


def update():
    player.update()
    terrain1.update()
endf
