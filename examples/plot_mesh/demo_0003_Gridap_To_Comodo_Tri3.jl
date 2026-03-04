using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.GeometryBasics
using Comodo
using GridapGmsh
using Comodo.GLMakie
using Comodo.GLMakie.Colors
GLMakie.closeall()

fileName_mesh = joinpath(ComodoGridap_dir(),"assets","msh","plate.msh")
model = GmshDiscreteModel(fileName_mesh)

F, V = GridapToComodo(model)

GLMakie.closeall()

M = GeometryBasics.Mesh(V, F)
fig = Figure(size=(800, 600))
ax = Axis(fig[1, 1], aspect=DataAspect(), xlabel="X", ylabel="Y",title="Mesh with Boundary Conditions",
xgridvisible = false,ygridvisible = false)
meshplot!(ax, M, color=(Gray(0.95), 0.4), strokecolor=:black, strokewidth= 1., shading =  true, transparency = false)
display(GLMakie.Screen(), fig)