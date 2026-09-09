using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Gridap.Geometry
using ComodoGridap.Comodo
using ComodoGridap.Comodo.GLMakie
using ComodoGridap.Comodo.GLMakie.Colors

using GridapGmsh 

GLMakie.closeall()

fileName_mesh = joinpath(ComodoGridap_dir(),"assets","msh","plate.msh")
model = GmshDiscreteModel(fileName_mesh)

topo = get_grid_topology(model)
labels = FaceLabeling(topo)
left_face  = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "left",  x -> abs(x[1]) ≤ 1e-6)
right_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "right", x -> abs(x[1] - 2.0) ≤ 1e-6)
bottom_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "bottom", x -> abs(x[2]) ≤ 1e-6) 
top_face  = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "top",  x -> abs(x[2] - 1.0) ≤ 1e-6)

merge!(labels, left_face)
merge!(labels, right_face)
merge!(labels, bottom_face)
merge!(labels, top_face)
model = UnstructuredDiscreteModel(get_grid(model), topo, labels)

F, V = GridapToComodo(model)

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

xlims!(ax, [-0.2 2.5])

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo tri3")