using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Gridap.Geometry
using ComodoGridap.Comodo
using ComodoGridap.Comodo.GLMakie
using ComodoGridap.Comodo.GLMakie.Colors

GLMakie.closeall()

boxDim = [2.5, 3.1, 4.0]
pointSpacing = 0.5

E, V, Fb, CFb_type = tetbox(boxDim, pointSpacing)
F = element2faces(E)
model = ComodoToGridap(E, V)

topo  = model.grid_topology
left_face = face_labeling_from_faces(topo, "left", Fb[CFb_type .== 6])
right_face    = face_labeling_from_faces(topo, "right",    Fb[CFb_type .== 5])
front_face    = face_labeling_from_faces(topo, "front",    Fb[CFb_type .== 3])

merge!(model.face_labeling, left_face)
merge!(model.face_labeling, right_face)
merge!(model.face_labeling, front_face)

## Visualise the mesh and boundary conditions
fig = Figure(size = (1200,800))
ax  = AxisGeom(fig[1,1], title = "Geometry")
hp = meshplot!(ax, Fb, V, color=(Gray(0.95), 0.3),  strokecolor=:black, strokewidth=2.0, shading= true, transparency = true)
### BC
scatter!(ax, boundary_nodes(model; tags="left"), color=:hotpink, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "top")
scatter!(ax, boundary_nodes(model; tags="right"), color=:cyan, markersize= 15.0, marker=:circle, strokecolor=:black, strokewidth=2, label = "bottom")
scatter!(ax, boundary_nodes(model; tags="front"), color=:black, markersize= 15.0, marker=:circle, strokecolor=:black, strokewidth=2, label = "front")

axislegend(ax, position=:rb, backgroundcolor=(:white, 0.7), framecolor=:gray)

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo Tet4")
