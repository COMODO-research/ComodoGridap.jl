using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.GeometryBasics
using GLMakie
using Comodo
using Gridap.Geometry
GLMakie.closeall()

plateDim = [1.0, 1.0]
plateElem = [10, 10]
orientation = :up
F, V, Eb, Cb = quadplate(plateDim, plateElem; orientation=orientation)

model = ComodoToGridap(F, V)

topo = get_grid_topology(model)
labels = get_face_labeling(model)


Fb_bottom = Eb[Cb .== 1]
Fb_right  = Eb[Cb .== 2]
Fb_top    = Eb[Cb .== 3]
Fb_left   = Eb[Cb .== 4]

add_boundary_tag!(labels, topo, Fb_left,   "left")
add_boundary_tag!(labels, topo, Fb_bottom, "bottom")
add_boundary_tag!(labels, topo, Fb_right,  "right")
add_boundary_tag!(labels, topo, Fb_top,    "top")


M = GeometryBasics.Mesh(V, F)

fig = Figure(size=(800,600))
ax = Axis(fig[1,1], aspect=DataAspect(), xlabel="X", ylabel="Y", xgridvisible = false, ygridvisible = false)
hp = meshplot!(ax, M, color= :gray,  strokecolor=:black, strokewidth=2.0, shading= true, transparency = false)


nodes_bottom = boundary_nodes(model; tags="bottom")
scatter!(ax, nodes_bottom, color=:blue, markersize=15.0, marker=:circle, strokecolor=:black, strokewidth=2, label="Fixed Y")
axislegend(ax)

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "ComodoToGridap quad4")