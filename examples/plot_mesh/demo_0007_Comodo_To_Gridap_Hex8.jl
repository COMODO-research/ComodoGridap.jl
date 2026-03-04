using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.GeometryBasics
using GLMakie
using Comodo
using Gridap.Geometry
using Comodo.GLMakie.Colors

pointSpacing = 0.5
boxDim = [2.5, 3.1, 4.0]
boxEl = ceil.(Int, boxDim ./ pointSpacing)

E, V, F, Fb, CFb_type = hexbox(boxDim, boxEl)

model = ComodoToGridap(E, V)

topo = get_grid_topology(model)
labels = get_face_labeling(model)

Fb_bottom = Fb[CFb_type .== 1]
Fb_top    = Fb[CFb_type .== 2]
Fb_front  = Fb[CFb_type .== 3]
Fb_back   = Fb[CFb_type .== 4]
Fb_right  = Fb[CFb_type .== 5]
Fb_left   = Fb[CFb_type .== 6]

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

node_idx = boundary_nodes(model; tags="back")
scatter!(ax, node_idx, color=:blue, markersize=15.0, marker=:circle, strokecolor=:black, strokewidth=2, label="Fixed")
axislegend(ax)
screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo Hex8")