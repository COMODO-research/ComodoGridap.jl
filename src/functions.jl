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


function ComodoToGridap(connectivity, V)

    CellType = eltype(connectivity)

    if CellType == QuadFace{Int64}
        F = connectivity
        node_coords = [VectorValue(Float64(v[1]), Float64(v[2])) for v in V]
        conn = [Int32.([f[1], f[4], f[2], f[3]]) for f in F]
        cell_node_ids = Table(conn)
        reffes = [LagrangianRefFE(Float64, QUAD, 1)]
        cell_type = Int8[1 for _ in 1:length(conn)]

        grid = UnstructuredGrid(node_coords, cell_node_ids, reffes, cell_type)
        model = UnstructuredDiscreteModel(grid)

    elseif CellType == TriangleFace{Int64}

        F = connectivity
        node_coords = [VectorValue(Float64(v[1]), Float64(v[2])) for v in V]
        conn = [Int32.([f[1], f[2], f[3]]) for f in F]
        cell_node_ids = Table(conn)
        reffes = [LagrangianRefFE(Float64, TRI, 1)]
        cell_type = Int8[1 for _ in 1:length(conn)]

        grid = UnstructuredGrid(node_coords, cell_node_ids, reffes, cell_type)
        model = UnstructuredDiscreteModel(grid)

    elseif CellType == Hex8{Int64}

        E = connectivity
        node_coords = [VectorValue(Float64(v[1]), Float64(v[2]), Float64(v[3])) for v in V]
        conn = [Int32.([e[1], e[2], e[4], e[3], e[5], e[6], e[8], e[7]]) for e in E]
        cell_node_ids = Table(conn)
        reffes = [LagrangianRefFE(Float64, HEX, 1)]
        cell_type = Int8[1 for _ in 1:length(conn)]

        grid = UnstructuredGrid(node_coords, cell_node_ids, reffes, cell_type)
        model = UnstructuredDiscreteModel(grid)

    elseif CellType == Tet4{Int64}
        E = connectivity
        node_coords = [VectorValue(Float64(v[1]), Float64(v[2]), Float64(v[3])) for v in V]
        conn = [Int32.([e[1], e[2], e[3], e[4]]) for e in E]
        cell_node_ids = Table(conn)
        reffes = [LagrangianRefFE(Float64, TET, 1)]
        cell_type = Int8[1 for _ in 1:length(conn)]

        grid = UnstructuredGrid(node_coords, cell_node_ids, reffes, cell_type)
        model = UnstructuredDiscreteModel(grid)

    else
        error("Unsupported CellType: $CellType")
    end
    return model
end

"""
    face_labeling_from_faces(topo, name, faces)

FaceLabeling tagging the given boundary faces (given as vertex-index tuples,
e.g. Comodo's `QuadFace`/`TriangleFace`), plus all their sub-faces.
Facet-list analogue of `face_labeling_from_vertex_filter`.
"""
function face_labeling_from_faces(topo::GridTopology, name::String, faces)
    D = num_cell_dims(topo)
    d_to_dface_to_entity = [fill(UNSET, num_faces(topo, d)) for d in 0:D]

    facet_to_vertices = get_faces(topo, D-1, 0)
    key_to_facet = Dict{Set{Int},Int}()
    for facet in 1:length(facet_to_vertices)
        key_to_facet[Set{Int}(facet_to_vertices[facet])] = facet
    end

    selected = map(faces) do f
        key = Set{Int}(Int.(f))
        haskey(key_to_facet, key) || error("face $f is not a facet of the topology")
        key_to_facet[key]
    end

    d_to_dface_to_entity[D][selected] .= 1
    for d in 0:D-2
        facet_to_dfaces = get_faces(topo, D-1, d)
        dface_to_entity = d_to_dface_to_entity[d+1]
        for facet in selected
            dface_to_entity[facet_to_dfaces[facet]] .= 1
        end
    end

    return FaceLabeling(d_to_dface_to_entity, [Int32[1]], [name])
end



