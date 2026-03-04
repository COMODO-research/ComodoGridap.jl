using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.GeometryBasics
using GLMakie
using Comodo
using Gridap.Geometry
using Comodo.GLMakie.Colors

boxDim = [2.5, 3.1, 4.0]
pointSpacing = 0.5

E, V, Fb, Cb = tetbox(boxDim, pointSpacing)
F = element2faces(E)
model = ComodoToGridap(E, V)

topo = get_grid_topology(model)
labels = get_face_labeling(model)

Fb_bottom = Fb[Cb .== 1]
Fb_top    = Fb[Cb .== 2]
Fb_front  = Fb[Cb .== 3]
Fb_back   = Fb[Cb .== 4]
Fb_left   = Fb[Cb .== 5]
Fb_right  = Fb[Cb .== 6]


add_boundary_tag!(labels, topo, Fb_left,   "left")
add_boundary_tag!(labels, topo, Fb_right,  "right")
add_boundary_tag!(labels, topo, Fb_bottom, "bottom")
add_boundary_tag!(labels, topo, Fb_top,    "top")
add_boundary_tag!(labels, topo, Fb_front,  "front")
add_boundary_tag!(labels, topo, Fb_back,   "back")



M = GeometryBasics.Mesh(V, F, normal = face_normals(V, F))
Mb = GeometryBasics.Mesh(V, Fb, normal = face_normals(V, Fb))

GLMakie.closeall()
fig = Figure(size = (1200,800))
ax  = AxisGeom(fig[1,1], title = "Geometry")

hp = meshplot!(ax, Mb, color=(Gray(0.95), 0.3),  strokecolor=:black, strokewidth=2.0, shading= true, transparency = true)

node_idx = boundary_nodes(model; tags="top")
scatter!(ax, node_idx, color=:blue, markersize=15.0, marker=:circle, strokecolor=:black, strokewidth=2, label="Fixed")
axislegend(ax)
screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo Hex8")