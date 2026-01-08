"""
    GridapToComodo(model, quad4)

Convert a Gridap model to Comodo-style quadrilateral (quad4) mesh data.

Returns a tuple `(F, V)` where `F` is a vector of quad faces (with node ordering adjusted)
and `V` is a vector of 2D vertex coordinates.
"""
function GridapToComodo(model, ::Type{quad4})

    node_coords = Gridap.Geometry.get_node_coordinates(model)
    cell_node_ids = get_cell_node_ids(model)

    F = QuadFace{Int}[]
    for c in cell_node_ids
        push!(F, c[[1, 2, 4, 3]])
    end

    V = GeometryBasics.Point{2,Float64}[]
    for x in node_coords
        push!(V, (x[1], x[2]))
    end

    return F, V
end

"""
    boundary_nodes(model, tags="", ::Type{T}) where {T<:Union{quad4,tri3}}

Extract boundary node coordinates for the given boundary `tags` and element type,
returning them as `GeometryBasics.Point{2}` for plotting.
"""
function boundary_nodes(model, ::Type{T}; tags="") where {T<:Union{quad4,tri3}}

    node_coords = Gridap.Geometry.get_node_coordinates(model)
    trian_boundary = BoundaryTriangulation(model, tags=tags)
    trian_node_ids = unique(vcat(get_cell_node_ids(trian_boundary)...))

    xb = [node_coords[n][1] for n in trian_node_ids]
    yb = [node_coords[n][2] for n in trian_node_ids]

    nodes = GeometryBasics.Point{2,Float64}[]
    nn = length(xb)
    for i in 1:nn
        push!(nodes, (xb[i], yb[i]))
    end
    return nodes
end

"""
    GridapToComodo(model, Hex8)

Convert a Gridap model to Comodo-style Hex8 mesh data.

"""

function GridapToComodo(model, ::Type{Comodo.Hex8})

    node_coords = Gridap.Geometry.get_node_coordinates(model)
    cell_node_ids = get_cell_node_ids(model)

    V = GeometryBasics.Point{3,Float64}[]
    for x in node_coords
        push!(V, (x[1], x[2], x[3]))
    end

    E = Comodo.Hex8{Int}[]
    for c in cell_node_ids
        push!(E, c[[1, 2, 4, 3, 5, 6, 8, 7]])
    end

    numElements = length(cell_node_ids)
    F = element2faces(E)

    CF_type = repeat(1:6, numElements) # Allocate face color/label data

    F_uni, indUni, c_uni = gunique(F, return_index=Val(true), return_counts=Val(true), sort_entries=true)
    Lb = isone.(c_uni)
    Fb = F_uni[Lb]
    CF_type_uni = CF_type[indUni]
    CFb_type = CF_type_uni[Lb]

    return E , V, F, Fb, CFb_type
end