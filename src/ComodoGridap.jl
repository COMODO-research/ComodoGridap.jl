module ComodoGridap

# Load used packages 
using Gridap
using Gridap.Geometry
using Gridap.ReferenceFEs
using Gridap.Arrays
using Gridap.Geometry: GridTopology, FaceLabeling
using Gridap.ReferenceFEs: get_faces, num_faces, num_cell_dims
using Gridap.Arrays: UNSET
using Comodo
using Comodo.GeometryBasics

# Export packages 
export Comodo
export Gridap

# Include functions 
include("functions.jl")

# Export functions 
export ComodoGridap_dir
export GridapToComodo
export boundary_nodes
export ComodoToGridap
export face_labeling_from_faces

end
