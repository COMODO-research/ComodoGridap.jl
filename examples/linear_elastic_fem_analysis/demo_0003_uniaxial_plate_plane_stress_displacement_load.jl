using Revise
using ComodoGridap
using ComodoGridap.Gridap
using ComodoGridap.Gridap.Geometry
using ComodoGridap.GeometryBasics
using Comodo.GLMakie
using Comodo.GLMakie.Colors
using Comodo
GLMakie.closeall()
domain = (0, 1.0, 0, 1.0)                                  
partition = (20,20)                                         
model = CartesianDiscreteModel(domain, partition)           


F , V = GridapToComodo(model)


labels = get_face_labeling(model)
add_tag_from_tags!(labels, "left", [1, 3, 7])   
add_tag_from_tags!(labels, "right", [2, 4, 8])  

degree = 2
Ω  = Triangulation(model)
dΩ = Measure(Ω, degree)


order = 1
reffe = ReferenceFE(lagrangian, VectorValue{2,Float64}, order)
V_0 = TestFESpace(model, reffe, conformity=:H1, 
    dirichlet_tags = ["left", "right"],
    dirichlet_masks = [(true, true), (true, false)]) 

function solveLinearElasticSteps(E, ν, model, displacement, numSteps)

    λ3d = (E * ν) / ((1 + ν) * (1 - 2 * ν))
    μ = E / (2 * (1 + ν))
    λ = 2 * μ * λ3d / (λ3d + 2 * μ)

    σ(ε) = λ * tr(ε) * one(ε) + 2 * μ * ε
    a(u, v) = ∫(ε(v) ⊙ (σ ∘ ε(u))) * dΩ

    
    b(v) = 0.0

    node_coords = Geometry.get_node_coordinates(model)
    numNodes = length(node_coords)
    

    U0 = zeros(GeometryBasics.Point{2,Float64}, numNodes)
    U0_mag = zeros(Float64, numNodes)

    UT = [copy(U0) for _ in 1:numSteps]
    UT_mag = [copy(U0_mag) for _ in 1:numSteps]
    ut_mag_max = zeros(Float64, numSteps)

    for step = 1:numSteps-1
        println("Solving step $step of $numSteps")

        
        disp_x = (step / (numSteps - 1)) * displacement
        g0 = VectorValue(0.0,0.0)
        g1 = VectorValue(disp_x,0.0)
        U_0 = TrialFESpace(V_0, [g0,g1])
    
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


E = 500.0e3
ν = 0.3
displacement = 1.0
numSteps = 10

UT, UT_mag, ut_mag_max = solveLinearElasticSteps(E, ν, model, displacement, numSteps)


scale = 1.0

VV = [GeometryBasics.Point{2,Float64}(e[1], e[2]) for e in V]
VT = [VV .+ scale .* UT[i] for i in 1:numSteps]

min_p = minp([minp(V) for V in VT])
max_p = maxp([maxp(V) for V in VT])

fig_disp = Figure(size=(1000, 600))
stepStart = 2  
ax3 = Axis(fig_disp[1, 1], title="Step: $stepStart")

xlims!(ax3, min_p[1], max_p[1])
ylims!(ax3, min_p[2], max_p[2])
hp = poly!(ax3, GeometryBasics.Mesh(VT[stepStart], F),
    strokewidth=2,
    color=UT_mag[stepStart],
    transparency=false,
    colormap=Reverse(:Spectral),
    colorrange=(0, maximum(ut_mag_max)))

Colorbar(fig_disp[1, 2], hp.plots[1], label="Displacement magnitude [mm]")

incRange = 1:numSteps
hSlider = Slider(fig_disp[2, 1], range=incRange, startvalue=stepStart - 1, linewidth=30)

on(hSlider.value) do stepIndex
    hp[1] = GeometryBasics.Mesh(VT[stepIndex], F)
    hp.color = UT_mag[stepIndex]
    ax3.title = "Step: $stepIndex"
end

slidercontrol(hSlider, ax3)
display(GLMakie.Screen(), fig_disp)