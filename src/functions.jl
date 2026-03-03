"""

ComodoGridap_dir()

This function simply returns the string for the ComodoGridap.jl path.
This is helpful for instance to load items, such as meshes, from the `assets`` folder. 

"""
function ComodoGridap_dir()
    joinpath(@__DIR__, "..")
end


function GridapToComodo(model)
    node_coords = Gridap.Geometry.get_node_coordinates(model)
    cell_node_ids = get_cell_node_ids(model)

    # Detect dimensionality and element type from first cell
    ndims = length(node_coords[1])
    nnodes_per_cell = length(cell_node_ids[1])

    if ndims == 2 && nnodes_per_cell == 4
        # QUAD4
        F = QuadFace{Int}[]
        for c in cell_node_ids
            push!(F, c[[1, 2, 4, 3]])
        end
        V = GeometryBasics.Point{2,Float64}[]
        for x in node_coords
            push!(V, (x[1], x[2]))
        end
        return F, V

    elseif ndims == 2 && nnodes_per_cell == 3
        # TRI3
        F = TriangleFace{Int}[]
        for c in cell_node_ids
            push!(F, c)
        end
        V = GeometryBasics.Point{2,Float64}[]
        for x in node_coords
            push!(V, (x[1], x[2]))
        end
        return F, V

    elseif ndims == 3 && nnodes_per_cell == 8
        # HEX8
        V = GeometryBasics.Point{3,Float64}[]
        for x in node_coords
            push!(V, (x[1], x[2], x[3]))
        end
        E = Comodo.Hex8{Int}[]
        for c in cell_node_ids
            push!(E, c[[1, 2, 4, 3, 5, 6, 8, 7]])
        end
        F = element2faces(E)
        numElements = length(cell_node_ids)
        CF_type = repeat(1:6, numElements)
        F_uni, indUni, c_uni = gunique(F, return_index=Val(true), return_counts=Val(true), sort_entries=true)
        Lb = isone.(c_uni)
        Fb = F_uni[Lb]
        CF_type_uni = CF_type[indUni]
        CFb_type = CF_type_uni[Lb]
        return E, V, F, Fb, CFb_type

    elseif ndims == 3 && nnodes_per_cell == 4
        # TET4
        V = GeometryBasics.Point{3,Float64}[]
        for x in node_coords
            push!(V, (x[1], x[2], x[3]))
        end
        E = Comodo.Tet4{Int}[]
        for c in cell_node_ids
            push!(E, c)
        end
        F = element2faces(E)
        numElements = length(cell_node_ids)
        CF_type = repeat(1:6, numElements)
        F_uni, indUni, c_uni = gunique(F, return_index=Val(true), return_counts=Val(true), sort_entries=true)
        Lb = isone.(c_uni)
        Fb = F_uni[Lb]
        CF_type_uni = CF_type[indUni]
        CFb_type = CF_type_uni[Lb]
        return E, V, F, Fb, CFb_type

    else
        error("Unsupported element type: ndims=$ndims, nodes_per_cell=$nnodes_per_cell")
    end
end

function boundary_nodes(model; tags="")
    node_coords = Gridap.Geometry.get_node_coordinates(model)
    trian_boundary = BoundaryTriangulation(model, tags=tags)
    trian_node_ids = unique(vcat(get_cell_node_ids(trian_boundary)...))

    ndims = length(node_coords[1])

    if ndims == 2
        nodes = GeometryBasics.Point{2,Float64}[]
        for n in trian_node_ids
            push!(nodes, (node_coords[n][1], node_coords[n][2]))
        end
    elseif ndims == 3
        nodes = GeometryBasics.Point{3,Float64}[]
        for n in trian_node_ids
            push!(nodes, (node_coords[n][1], node_coords[n][2], node_coords[n][3]))
        end
    else
        error("Unsupported dimensionality: $ndims")
    end

    return nodes
end


