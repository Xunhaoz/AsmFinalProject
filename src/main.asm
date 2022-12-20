import engine

.DATA
Player player

.CODE
class Player:
    def init():
        Vec3 self.pos = Vec3(0, 0, 0)
        Matrix3 self._rot = Matrix3(Vec3(0, 0, 1), Vec3(1, 0, 0), Vec3(0, 1, 0))
        Matrix3 self.rot = Matrix3(Vec3(1, 0, 0), Vec3(0, 1, 0), Vec3(0, 0, 1))
        Vec3 self.scale = Vec3(3, 3, 3)
        Vec3 self.camera_offset = Vec3(30, 0, 10)
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

        camera.pos = self.pos - self.rot.u.mulc(self.camera_offset.x) - self.rot.v.mulc(self.camera_offset.y) - self.rot.w.mulc(self.camera_offset.z)
        Vec3 camera_w = (camera.pos - self.pos).norm()
        Vec3 camera_u = (Vec3(0, 0, 0) - self.rot.v).norm()
        Vec3 camera_v = Vec3.cross(camera_u, camera_w).norm()
        camera.set_inv_axis(Matrix3(camera_u, camera_v, camera_w))
        mm.set_transform(self.pos, self._rot, self.scale)
        mm.add_spaceship()
    endf
endc    

def init():
    ; engine = Engine()
    ; for i in range(5):
    ;     for j in range(5):
    ;         add_pyramid(Vec3(j*15,i*15-30,-30), 10, 10)
    ;     endl
    ; endl
    player = Player()
endf


def update():
    player.update()
endf
