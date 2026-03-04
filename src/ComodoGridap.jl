module ComodoGridap

using Gridap
using Gridap.Geometry
using GeometryBasics
using Gridap.ReferenceFEs
using Gridap.Arrays
using Comodo

export Comodo
export Gridap

export ComodoGridap_dir
export GridapToComodo
export boundary_nodes
export ComodoToGridap
export comodo_faces_to_gridap_ids
export add_boundary_tag!
include("functions.jl")

end
