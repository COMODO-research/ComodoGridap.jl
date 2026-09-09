using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Gridap.Geometry
using ComodoGridap.Comodo
using ComodoGridap.Comodo.GLMakie
using ComodoGridap.Comodo.GLMakie.Colors

using GridapGmsh

GLMakie.closeall()

fileName_mesh = joinpath(ComodoGridap_dir(),"assets","msh","cube.msh")
model = GmshDiscreteModel(fileName_mesh)

topo = get_grid_topology(model)
labels = FaceLabeling(topo)

bottom_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "bottom", x -> abs(x[3]) ≤ 1e-6)
top_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "top", x -> abs(x[3] - 2.0) ≤ 1e-6)
front_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "front", x -> abs(x[2]) ≤ 1e-6)
back_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "back", x -> abs(x[2]- 2.0) ≤ 1e-6)
left_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "left", x -> abs(x[1]) ≤ 1e-6)
right_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "right", x -> abs(x[1]- 2.0) ≤ 1e-6)

merge!(labels, bottom_face)
merge!(labels, top_face)
merge!(labels, front_face)
merge!(labels, back_face)
merge!(labels, left_face)
merge!(labels, right_face)

model = UnstructuredDiscreteModel(get_grid(model), topo, labels)

E , V, F, Fb, CFb_type = GridapToComodo(model)

## Visualise the mesh and boundary conditions
fig = Figure(size = (1200,800))
ax  = AxisGeom(fig[1,1], title = "Geometry")
hp = meshplot!(ax, Fb, V, color=(Gray(0.95), 0.3),  strokecolor=:black, strokewidth=2.0, transparency = true)
### BC
scatter!(ax, boundary_nodes(model; tags="top"), color=:hotpink, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "top")
scatter!(ax, boundary_nodes(model; tags="bottom"), color=:cyan, markersize= 15.0, marker=:circle, strokecolor=:black, strokewidth=2, label = "bottom")
axislegend(ax, position=:rb, backgroundcolor=(:white, 0.7), framecolor=:gray)
axislegend(ax, position=:rb, backgroundcolor=(:white, 0.7), framecolor=:gray)

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo Tet4")