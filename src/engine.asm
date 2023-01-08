import math
import model
import screen
import camera

.data
ModelManager mm
Engine engine
Camera camera
Keyboard keyboard

.code
def get_time() -> (int):
    int t
    call GetMseconds
    mov t, eax
    return t
endf

class Keyboard:
    def init():
        int self.q
        int self.e
        int self.w
        int self.a
        int self.s
        int self.d
        int self.up = 0
        int self.down = 0
        int self.left = 0
        int self.right = 0
        int self.esc = 0
    endf

    def update():
        call ReadKey
        int key
        movzx ebx, ax
        mov key, ebx
        self.q      = key == 04209
        self.e      = key == 04709
        self.w      = key == 04471
        self.a      = key == 07777
        self.s      = key == 08051
        self.d      = key == 08292
        self.up     = key == 18432
        self.down   = key == 20480
        self.left   = key == 19200
        self.right  = key == 19712
        self.esc    = key == 00283
    endf

    def print():
        printInt self.up   
        printInt self.down 
        printInt self.left 
        printInt self.right
        printInt self.esc  
        printEndl
    endf
endc

class Engine:
	def init():
		float self.update_rate = 1
		float self.dt
        float self.time
		int self.last_t = get_time()
	endf

	def step():
        float t = get_time()
        while t - self.last_t < self.update_rate:
            t = get_time()
        endl
        self.dt = (t - self.last_t) / 1000.0
        ; printFloat self.dt
        self.last_t = t 
        self.time = t / 1000

        mm.reset()
        update()
        keyboard.update()
		camera.render()
        display()
	endf
endc

def main():
	build_char_level()

	camera = Camera()
    engine = Engine()
    keyboard = Keyboard()
    mm = ModelManager()

    init()
    while True:
        engine.step()
    endl
    ; testRayTriangleIntersect()
    ; testRender()
    ; testRenderAnimation()
    ; testRenderTriangle()
    call WaitMsg
endf