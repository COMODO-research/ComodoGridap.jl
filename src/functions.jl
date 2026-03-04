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


function comodo_faces_to_gridap_ids(Fb, topo)
    nnodes = length(Fb[1])
    
    if nnodes == 2
        # 2D boundary: edges
        edge_to_nodes = get_faces(topo, 1, 0)
        pair_to_eid = Dict{Tuple{Int,Int}, Int}()
        for (eid, enodes) in enumerate(edge_to_nodes)
            key = (min(enodes[1], enodes[2]), max(enodes[1], enodes[2]))
            pair_to_eid[key] = eid
        end
        ids = Int32[]
        for e in Fb
            key = (min(Int(e[1]), Int(e[2])), max(Int(e[1]), Int(e[2])))
            if haskey(pair_to_eid, key)
                push!(ids, Int32(pair_to_eid[key]))
            end
        end
        return ids, :edge

    elseif nnodes == 3 || nnodes == 4
        # 3D boundary: tri or quad facets
        facet_to_nodes = get_faces(topo, 2, 0)
        tuple_to_fid = Dict{NTuple{nnodes,Int}, Int}()
        for (fid, fnodes) in enumerate(facet_to_nodes)
            if length(fnodes) == nnodes
                key = Tuple(sort(collect(Int, fnodes)))
                tuple_to_fid[key] = fid
            end
        end
        ids = Int32[]
        for face in Fb
            nodes = sort([Int(face[i]) for i in 1:nnodes])
            key = Tuple(nodes)
            if haskey(tuple_to_fid, key)
                push!(ids, Int32(tuple_to_fid[key]))
            end
        end
        return ids, :facet

    else
        error("Unsupported boundary face with $nnodes nodes")
    end
end

function add_boundary_tag!(labels, topo, Fb, name)
    ids, kind = comodo_faces_to_gridap_ids(Fb, topo)
    entity_id = Int32(maximum(vcat(labels.d_to_dface_to_entity...)) + 1)

    if kind == :edge
        # 2D: tag edges (d=1, index 2)
        for eid in ids
            labels.d_to_dface_to_entity[2][eid] = entity_id
        end

    elseif kind == :facet
        # 3D: tag facets (d=2, index 3)
        for fid in ids
            labels.d_to_dface_to_entity[3][fid] = entity_id
        end

        # Tag edges belonging to these facets
        facet_to_edges = get_faces(topo, 2, 1)
        edge_set = Set{Int}()
        for fid in ids
            for eid in facet_to_edges[fid]
                push!(edge_set, eid)
            end
        end
        for eid in edge_set
            if labels.d_to_dface_to_entity[2][eid] == 0
                labels.d_to_dface_to_entity[2][eid] = entity_id
            end
        end
    end

    # Collect and tag nodes
    node_set = Set{Int}()
    for face in Fb
        for i in 1:length(face)
            push!(node_set, Int(face[i]))
        end
    end

    entities_for_tag = Int32[entity_id]
    for nid in node_set
        current = labels.d_to_dface_to_entity[1][nid]
        if current == 0
            labels.d_to_dface_to_entity[1][nid] = entity_id
        else
            shared_entity = Int32(maximum(vcat(labels.d_to_dface_to_entity...)) + 1)
            labels.d_to_dface_to_entity[1][nid] = shared_entity
            push!(entities_for_tag, shared_entity)
            for (ti, ents) in enumerate(labels.tag_to_entities)
                if current in ents
                    push!(labels.tag_to_entities[ti], shared_entity)
                end
            end
        end
    end

    add_tag!(labels, name, entities_for_tag)
end