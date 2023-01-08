import numpy as np
from stl import mesh

your_mesh = mesh.Mesh.from_file('models/ImageToStl.com_low_poly_spaceship.stl')

pointMap = {}
mapCounter = 0

minp = np.array([1e30] * 3)
maxp = np.array([-1e30] * 3)

vertices = []

for i in range(len(your_mesh.v0)):
    pointList = [your_mesh.v0[i].tobytes(), your_mesh.v1[i].tobytes(), your_mesh.v2[i].tobytes()]
    for ps in pointList:
        if ps not in pointMap:
            pointMap[ps] = mapCounter
            mapCounter += 1
            p = np.frombuffer(ps, dtype="float32")
            minp = np.minimum(minp, p)
            maxp = np.maximum(maxp, p)
            vertices.append(p)

center = (maxp + minp) / 2

for i in range(len(your_mesh.v0)):
    pointList = [your_mesh.v0[i].tobytes(), your_mesh.v1[i].tobytes(), your_mesh.v2[i].tobytes()]
    print(f"\t\tself.add_triangle(Triangle({pointMap[pointList[0]]}, {pointMap[pointList[1]]}, {pointMap[pointList[2]]}))")

for v in vertices:
    p = v - center
    print(f"\t\tself.add_vertex(Vec3({p[0]:.4f}, {p[1]:.4f}, {p[2]:.4f}))")

minx = np.array([0, np.inf, 0])
maxx = np.array([0, -np.inf, 0])
miny = np.array([0, np.inf, 0])
maxy = np.array([0, -np.inf, 0])
minz = np.array([0, np.inf, 0])
maxz = np.array([0, -np.inf, 0])

for v in vertices:
    p = v - center
    if p[0] < minx[0]:
        minx = p
    if p[0] > maxx[0]:
        maxx = p
    if p[1] < miny[1]:
        miny = p
    if p[1] > maxy[1]:
        maxy = p
    if p[2] < minz[2]:
        minz = p
    if p[2] > maxz[2]:
        maxz = p

print(minx)
print(maxx)
print(miny)
print(maxy)
print(minz)
print(maxz)
