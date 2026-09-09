using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Gridap.Geometry
using ComodoGridap.Comodo
using ComodoGridap.Comodo.GLMakie
using ComodoGridap.Comodo.GLMakie.Colors

GLMakie.closeall()

plateDim1 = [20.0, 24.0]
pointSpacing1 = 2.0
orientation1 = :up
F, V, Eb, Cb = triplate(plateDim1, pointSpacing1; orientation=orientation1, return_boundary_edges=Val(true))

model = ComodoToGridap(F, V)

Fb_bottom = Eb[Cb .== 1]
Fb_right  = Eb[Cb .== 2]
Fb_top    = Eb[Cb .== 3]
Fb_left   = Eb[Cb .== 4]

topo  = model.grid_topology

bottom_face = face_labeling_from_faces(topo, "bottom", Fb_bottom)
top_face = face_labeling_from_faces(topo, "top", Fb_top)
right_face = face_labeling_from_faces(topo, "right", Fb_right)
left_face = face_labeling_from_faces(topo, "left", Fb_left)

merge!(model.face_labeling, left_face)
merge!(model.face_labeling, right_face)
merge!(model.face_labeling, bottom_face)
merge!(model.face_labeling, top_face)

## Visualise the mesh and boundary conditions
fig = Figure(size=(800,600))
ax = Axis(fig[1,1], aspect=DataAspect(), xlabel="X", ylabel="Y")
hp = meshplot!(ax, F, V, color= :gray,  strokecolor=:black, strokewidth=2.0, shading= false, transparency = false)
### BC
scatter!(ax, boundary_nodes(model; tags="right"), color=:red, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "right")
scatter!(ax, boundary_nodes(model; tags="left"), color=:blue, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "left")
scatter!(ax, boundary_nodes(model; tags="top"), color=:green, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "top")
scatter!(ax, boundary_nodes(model; tags="bottom"), color=:cyan, markersize= 15.0, marker=:circle, strokecolor=:black, strokewidth=2, label = "bottom")
axislegend(ax, position=:rb, backgroundcolor=(:white, 0.7), framecolor=:gray)

xlims!(ax, [-14.8 14.8])

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "ComodoToGridap tri3")