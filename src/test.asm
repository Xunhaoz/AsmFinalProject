.CODE
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