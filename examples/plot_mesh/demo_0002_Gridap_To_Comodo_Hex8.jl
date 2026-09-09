using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Comodo
using ComodoGridap.Comodo.GLMakie
using ComodoGridap.Comodo.GLMakie.Colors

GLMakie.closeall()
domain = (0, 1, 0, 1, 0, 1)
partition = (10, 10, 10)
model = CartesianDiscreteModel(domain, partition)

E , V, F, Fb, CFb_type = GridapToComodo(model)

topo = model.grid_topology

bottom_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "bottom", x -> abs(x[3]) ≤ 1e-6)
top_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "top", x -> abs(x[3] - 1.0) ≤ 1e-6)
front_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "front", x -> abs(x[2]) ≤ 1e-6)
back_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "back", x -> abs(x[2]- 1.0) ≤ 1e-6)
left_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "left", x -> abs(x[1]) ≤ 1e-6)
right_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "right", x -> abs(x[1]- 1.0) ≤ 1e-6)

merge!(model.face_labeling, bottom_face)
merge!(model.face_labeling, top_face)
merge!(model.face_labeling, front_face)
merge!(model.face_labeling, back_face)
merge!(model.face_labeling, left_face)
merge!(model.face_labeling, right_face)

## Visualise plot the mesh and boundary conditions
fig = Figure(size = (1200,800))
ax  = AxisGeom(fig[1,1], title = "Geometry")
hp = meshplot!(ax, Fb, V, color=(Gray(0.95), 0.3),  strokecolor=:black, strokewidth=2.0, shading= true, transparency = true)
### BC
scatter!(ax, boundary_nodes(model; tags="top"), color=:hotpink, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "top")
scatter!(ax, boundary_nodes(model; tags="bottom"), color=:cyan, markersize= 15.0, marker=:circle, strokecolor=:black, strokewidth=2, label = "bottom")
axislegend(ax, position=:rb, backgroundcolor=(:white, 0.7), framecolor=:gray)
axislegend(ax, position=:rb, backgroundcolor=(:white, 0.7), framecolor=:gray)

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo Hex8")