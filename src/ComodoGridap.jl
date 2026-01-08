module ComodoGridap

using Gridap
using Gridap.Geometry
using GeometryBasics
using Gridap.ReferenceFEs
using Comodo

export Comodo
export Gridap

struct quad4 end
struct tri3 end
export quad4
export tri3

# struct Hex8 end
# export Hex8

export GridapToComodo
export boundary_nodes
include("functions.jl")

end
