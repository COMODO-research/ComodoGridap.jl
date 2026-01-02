using Revise
using ComodoGridap
using ComodoGridap.Gridap
using Gridap.Geometry
## Mesh   
domain = (0, 1.0, 0,1.0)                                  
partition = (2,2)                                         
model = CartesianDiscreteModel(domain, partition)           

## Boundary Condition
labels = get_face_labeling(model)
add_tag_from_tags!(labels, "left", [1, 3, 7])   
add_tag_from_tags!(labels, "right", [2, 4, 8])  

## 
degree = 2
Ω  = Triangulation(model)
dΩ = Measure(Ω, degree)
Γ  = BoundaryTriangulation(model, tags="right")
dΓ = Measure(Γ, degree)

# --------------------
# FE Spaces
# --------------------
order = 1
reffe = ReferenceFE(lagrangian, VectorValue{2,Float64}, order)
V = TestFESpace(model, reffe, conformity=:H1, dirichlet_tags=["left"])
U = TrialFESpace(V, VectorValue(0.0, 0.0))


t(x) = VectorValue(1e10, 0.0)   # traction on "right" boundary

b(v) = ∫( v ⋅ t )*dΓ


const E = 210e9
const ν = 0.3
λ3d = (E*ν)/((1+ν)*(1-2*ν))
const μ = E/(2*(1+ν))
const λ = 2*μ*λ3d/(λ3d+2*μ)

σ(ε) = λ*tr(ε)*one(ε) + 2*μ*ε

a(u, v) = ∫( ε(v) ⊙ (σ ∘ ε(u)) ) * dΩ

op = AffineFEOperator(a, b, U, V)
uh = solve(op)


node_coords = Geometry.get_node_coordinates(model)
u_full = uh.(node_coords)          # Vector{VectorValue{2,Float64}}

ux = transpose(getindex.(u_full, 1))          # Vector{Float64}
uy = transpose(getindex.(u_full, 2))           # Vector{Float64}
u_vals = uh.(node_coords)
for (i, coord) in enumerate(node_coords)
    println("Node $i at $coord: ux = $(u_vals[i][1]), uy = $(u_vals[i][2])")
end

F , V = GridapToComodo(model, quad4)
nothing