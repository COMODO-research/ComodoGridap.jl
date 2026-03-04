using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.GeometryBasics
using Comodo
using Comodo.GLMakie
using GridapGmsh
using Comodo.GLMakie.Colors
GLMakie.closeall()

fileName_mesh = joinpath(ComodoGridap_dir(),"assets","msh","cube.msh")
model = GmshDiscreteModel(fileName_mesh)

E , V, F, Fb, CFb_type = GridapToComodo(model)

M = GeometryBasics.Mesh(V, F, normal = face_normals(V, F))
Mb = GeometryBasics.Mesh(V, Fb, normal = face_normals(V, Fb))
GLMakie.closeall()
fig = Figure(size = (1200,800))
ax  = AxisGeom(fig[1,1], title = "Geometry")

hp = meshplot!(ax, Mb, color= :gray , strokecolor=:black, strokewidth=2.0, shading= false, transparency = false)

screen = display(GLMakie.Screen(), fig)
GLMakie.set_title!(screen, "GridapToComodo Tet4")