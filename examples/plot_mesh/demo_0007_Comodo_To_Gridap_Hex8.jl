using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.GeometryBasics
using GLMakie
using Comodo
using Gridap.Geometry
using Comodo.GLMakie.Colors

GLMakie.closeall()

pointSpacing = 0.5
boxDim = [2.5, 3.1, 4.0]
boxEl = ceil.(Int, boxDim ./ pointSpacing)

E, V, F, Fb, CFb_type = hexbox(boxDim, boxEl)
model = ComodoToGridap(E, V)

topo  = model.grid_topology

bottom_face = face_labeling_from_faces(topo, "bottom", Fb[CFb_type .== 1])
top_face    = face_labeling_from_faces(topo, "top",    Fb[CFb_type .== 2])
front_face    = face_labeling_from_faces(topo, "front",    Fb[CFb_type .== 3])

merge!(model.face_labeling, bottom_face)
merge!(model.face_labeling, top_face)
merge!(model.face_labeling, front_face)


# plot the mesh and boundary condition
M = GeometryBasics.Mesh(V, F, normal = face_normals(V, F))
Mb = GeometryBasics.Mesh(V, Fb, normal = face_normals(V, Fb))

GLMakie.closeall()
fig = Figure(size = (1200,800))
ax  = AxisGeom(fig[1,1], title = "Geometry")
hp = meshplot!(ax, Mb, color=(Gray(0.95), 0.3),  strokecolor=:black, strokewidth=2.0, shading= true, transparency = true)
### BC
scatter!(ax, boundary_nodes(model; tags="top"), color=:hotpink, markersize= 15.0, marker=:xcross, strokecolor=:black, strokewidth=2, label = "top")
scatter!(ax, boundary_nodes(model; tags="bottom"), color=:cyan, markersize= 15.0, marker=:circle, strokecolor=:black, strokewidth=2, label = "bottom")
scatter!(ax, boundary_nodes(model; tags="front"), color=:black, markersize= 15.0, marker=:circle, strokecolor=:black, strokewidth=2, label = "front")

axislegend(ax, position=:rb, backgroundcolor=(:white, 0.7), framecolor=:gray)


screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo Hex8")
