using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.GeometryBasics
using GLMakie
using Comodo

GLMakie.closeall()
Lx = 1.0 # Length in x-direction
Ly = 1.0 # Length in y-direction
nx = 10   # number of elements in x-dir
ny = 10   # number of elements in y-dir
domain = (0, Lx, 0,Ly)
partition = (nx,ny)
model = CartesianDiscreteModel(domain, partition)

F , V = GridapToComodo(model)

M = GeometryBasics.Mesh(V, F)

fig = Figure(size=(800,600))
ax = Axis(fig[1,1], aspect=DataAspect(), xlabel="X", ylabel="Y", xgridvisible = false, ygridvisible = false)

#poly!(ax, M,color = (:gray, 0.25), strokecolor = :black, strokewidth = 3)
hp = meshplot!(ax, M, color= :gray,  strokecolor=:black, strokewidth=2.0, shading= false, transparency = false)


### plot the boundary

#=
1, 2, 3, 4: the four points around your domain (it begins lower left, then lower right, upper left, upper right)
5: lower segment
6 upper segment
7: left segment
8: right segment
and 9 is for the domain itself .
=#
labels = get_face_labeling(model)
add_tag_from_tags!(labels, "left",  [1, 3, 7])
nodes = boundary_nodes(model; tags="left")


scatter!(ax, nodes, color=:red, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "Fixed XY")

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo quad4")