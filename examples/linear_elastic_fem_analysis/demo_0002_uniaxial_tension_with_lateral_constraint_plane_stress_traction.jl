using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Gridap.Geometry
using ComodoGridap.GeometryBasics
using ComodoGridap.Comodo
using ComodoGridap.Comodo.GLMakie

GLMakie.closeall()
domain = (0, 1.0, 0,1.0)                                  
partition = (20,20)                                         
model = CartesianDiscreteModel(domain, partition)
        
F , V = GridapToComodo(model)

labels = get_face_labeling(model)
add_tag_from_tags!(labels, "left", [1, 3, 7])   
add_tag_from_tags!(labels, "right", [2, 4, 8])  
add_tag_from_tags!(labels, "bottom", [1, 2, 5]) 

degree = 2
Ω  = Triangulation(model)
dΩ = Measure(Ω, degree)
Γ  = BoundaryTriangulation(model, tags="right")
dΓ = Measure(Γ, degree)

order = 1
reffe = ReferenceFE(lagrangian, VectorValue{2,Float64}, order)
V_0 = TestFESpace(model, reffe, conformity=:H1, 
    dirichlet_tags = ["left", "bottom"],
    dirichlet_masks = [(true, false), (false, true)]) 

g1(x) = VectorValue(0.0, 0.0)
g2(x) = VectorValue(0.0, 0.0)
U_0 = TrialFESpace(V_0, [g1, g2])

function solveLinearElasticSteps(E, ν, model, traction_vector, numSteps)

    λ3d = (E * ν) / ((1 + ν) * (1 - 2 * ν))
    μ = E / (2 * (1 + ν))
    λ = 2 * μ * λ3d / (λ3d + 2 * μ)

    σ(ε) = λ * tr(ε) * one(ε) + 2 * μ * ε
    a(u, v) = ∫(ε(v) ⊙ (σ ∘ ε(u))) * dΩ

    node_coords = Geometry.get_node_coordinates(model)
    numNodes = length(node_coords)
    

    U0 = zeros(GeometryBasics.Point{2,Float64}, numNodes)
    U0_mag = zeros(Float64, numNodes)

    UT = [copy(U0) for _ in 1:numSteps]
    UT_mag = [copy(U0_mag) for _ in 1:numSteps]
    ut_mag_max = zeros(Float64, numSteps)

    for step = 1:numSteps-1
        println("Solving step $step of $numSteps")

        t(x) = (step / (numSteps - 1)) * traction_vector
        b(v) = ∫(v ⋅ t) * dΓ

        op = AffineFEOperator(a, b, U_0, V_0)
        uh = solve(op)

        u_vals = uh.(node_coords)

        disp_points = Vector{GeometryBasics.Point{2,Float64}}(undef, length(u_vals))

        disp_points = [GeometryBasics.Point(u[1], u[2]) for u in vec(u_vals)]

        UT[step+1] = disp_points
        UT_mag[step+1] = norm.(disp_points)
        ut_mag_max[step+1] = maximum(UT_mag[step+1])
    end

    return UT, UT_mag, ut_mag_max
end


E = 210e9
ν = 0.3
traction_vector = VectorValue(1e10, 0.0)
numSteps = 10

UT, UT_mag, ut_mag_max =solveLinearElasticSteps(E, ν, model, traction_vector, numSteps)

## Visualisation

scale = 3.5

VV = [GeometryBasics.Point{2,Float64}(p[1], p[2]) for p in V]
VT = [VV .+ scale .* U  for U in UT]

min_p = minp([minp(V) for V in VT])
max_p = maxp([maxp(V) for V in VT])

fig_disp = Figure(size=(1000, 600))
stepStart = numSteps
ax1 = Axis(fig_disp[1, 1], title="Step: $stepStart", limits=(min_p[1], max_p[1], min_p[2], max_p[2]), aspect = DataAspect())

hp = meshplot!(ax1, F, VT[stepStart], 
    strokewidth=1.0,
    color=UT_mag[stepStart],    
    colormap=Reverse(:Spectral),
    colorrange=(0.0, maximum(ut_mag_max)), 
    shading=false)

Colorbar(fig_disp[1, 2], hp, label="Displacement magnitude [mm]")

incRange = 1:numSteps
hSlider = Slider(fig_disp[2, 1], range=incRange, startvalue=stepStart, linewidth=30)

on(hSlider.value) do stepIndex
    hp[1] = GeometryBasics.Mesh(VT[stepIndex], F)
    hp.color = UT_mag[stepIndex]
    ax1.title = "Step: $stepIndex"
end

# slidercontrol(hSlider, ax1)
display(GLMakie.Screen(), fig_disp)