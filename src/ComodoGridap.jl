module ComodoGridap

using Gridap
using Gridap.Geometry
using GeometryBasics
using Gridap.ReferenceFEs
using Comodo

export Comodo
export Gridap

export ComodoGridap_dir



export GridapToComodo
export boundary_nodes

include("functions.jl")

end
