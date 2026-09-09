using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Comodo
using ComodoGridap.Comodo.GLMakie
using ComodoGridap.Comodo.GLMakie.Colors

GLMakie.closeall()
Lx = 1.0 # Length in x-direction
Ly = 1.0 # Length in y-direction
nx = 10   # number of elements in x-dir
ny = 10   # number of elements in y-dir
domain = (0, Lx, 0,Ly)
partition = (nx,ny)
model = CartesianDiscreteModel(domain, partition)

F , V = GridapToComodo(model)

#=
To define the boundary conidtion we can use the tags from Gridap such that
1, 2, 3, 4: the four points around your domain (it begins lower left, then lower right, upper left, upper right)
5: lower segment
6 upper segment
7: left segment
8: right segment
and 9 is for the domain itself .
labels = get_face_labeling(model)
add_tag_from_tags!(labels, "left",  [1, 3, 7])

Howover, we prefer the following way to add the boundary condition based on the coordinate
=#
topo = model.grid_topology
left_face  = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "left",  x -> abs(x[1]) ≤ 1e-6)
right_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "right", x -> abs(x[1] - 1.0) ≤ 1e-6)
bottom_face = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "bottom", x -> abs(x[2]) ≤ 1e-6) 
top_face  = Gridap.Geometry.face_labeling_from_vertex_filter(topo, "top",  x -> abs(x[2] - 1.0) ≤ 1e-6)
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

xlims!(ax, [-0.2 1.2])

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo quad4")