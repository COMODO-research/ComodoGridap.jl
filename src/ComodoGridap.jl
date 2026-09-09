module ComodoGridap

using Gridap
using Gridap.Geometry
using GeometryBasics
using Gridap.ReferenceFEs
using Gridap.Arrays
using Comodo
using Gridap.Geometry: GridTopology, FaceLabeling
using Gridap.ReferenceFEs: get_faces, num_faces, num_cell_dims
using Gridap.Arrays: UNSET

export Comodo
export Gridap

export ComodoGridap_dir
export GridapToComodo
export boundary_nodes
export ComodoToGridap
export face_labeling_from_faces
include("functions.jl")

end
