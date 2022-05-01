"""
macro gmsh(ex)

Use a `try` block to initialize `gmsh`, execute `ex`, and finalize `gmsh`
regardless of how `ex` exits.
"""
macro gmsh(ex)
    return quote
        gmsh.initialize()
        try
            set_verbosity(0)
            $(esc(ex))
        finally
            # make sure we finalize gmsh if something goes wrong
            gmsh.finalize()
        end
    end
end

"""
    domain(;dim=3)

Construct a `Domain` from the current `gmsh` model with all entities of
dimension `dim`.

!!! note
    This function assumes that `gmsh` has been initialized, and
    does not handle its finalization.
"""
function domain(;dim=3)
    Ω = WPB.Domain() # Create empty domain
    domain!(Ω;dim)
    return Ω
end

"""
    domain!(Ω::Domain;[dim=3])

Like [`domain`](@ref), but appends entities to `Ω` instead of
creating a new domain.

!!! note
    This function assumes that `gmsh` has been initialized, and does not handle its
    finalization.
"""
function domain!(Ω::WPB.Domain;dim=3)
    dim_tags = gmsh.model.getEntities(dim)
    for (_, tag) in dim_tags
        # FIXME: create a temporary GMSH_TAGS to first import all tags from
        # gmsh, then check that there are no duplicates with already existing tags?
        # if haskey(ENTITIES,(dim,tag))
        #     ent = ENTITIES[(dim,tag)]
        # else
        ent = WPB.ElementaryEntity(dim, tag)
        _fill_entity_boundary!(ent)
        # end
        push!(Ω, ent)
    end
    return Ω
end

"""
    meshgen(Ω;[dim=3])

Create a `GenericMesh` for the entities in `Ω` using the curent `gmsh` model.
Passing `d=2` will create a two-dimensional mesh by projecting the original mesh
into the `x,y` plane.

!!! danger
    This function assumes that `gmsh` has been initialized, and does not handle its
    finalization.
"""
function meshgen(Ω::WPB.Domain;dim=3)
    msh = WPB.GenericMesh{3,Float64}()
    meshgen!(msh,Ω)
    if dim == 3
        return msh
    elseif dim == 2
        return WPB.convert_to_2d(msh)
        # return msh
    else
        error("`dim` value must be `2` or `3`")
    end
end

"""
    meshgen!(msh,Ω)

Similar to [`meshgen`](@ref), but append information to `msh` instead of
creating a new mesh.

!!! danger
    This function assumes that `gmsh` has been initialized, and does not handle its
    finalization.
"""
function meshgen!(msh::WPB.GenericMesh,Ω::WPB.Domain)
    tags, coord, _ = gmsh.model.mesh.getNodes()
    # NOTE: maybe use something like "unsafe_convert" to avoid having to
    # allocate new points for the nodes?
    nodes = reinterpret(SVector{3,Float64}, coord) |> collect
    append!(msh.nodes,nodes)
    els = WPB.elements(msh)
    e2t = WPB.ent2tags(msh)
    # Recursively populate the dictionaries
    _domain_to_mesh!(els, e2t, Ω)
    return msh
end

"""
    read_geo(fname::String;dim=3)

Read a `.geo` file and generate a [`Domain`](@ref) with all entities of
dimension `dim`.

!!! danger
    This function assumes that `gmsh` has been initialized, and does not handle its
    finalization.
"""
function read_geo(fname;dim=3)
    Ω = WPB.Domain() # Create empty domain
    try
        gmsh.open(fname)
    catch
        @error "could not open $fname"
    end
    domain!(Ω;dim)
    return Ω
end

"""
    read_msh(fname::String;dim=3)

Read `fname` and create a `Domain` and a `GenericMesh` structure with all
entities in `Ω` of dimension `dim`.

!!! danger
    This function assumes that `gmsh` has been initialized, and does not handle its
    finalization.
"""
function read_msh(fname;dim=3)
    Ω = WPB.Domain()
    try
        gmsh.open(fname)
    catch
        @error "could not open $fname"
    end
    Ω = domain(;dim)
    msh = meshgen(Ω;dim)
    return Ω,msh
end

"""
    _fill_entity_boundary!

Use the `gmsh` API to add the boundary of an `ElementaryEntity`.

This is a helper function, and should not be called by itself.
"""
function _fill_entity_boundary!(ent)
    combine  = true # FIXME: what should we use here?
    oriented = false
    dim_tags = gmsh.model.getBoundary((ent.dim, ent.tag),combine,oriented)
    for (d, t) in dim_tags
        if haskey(WPB.ENTITIES,(d,t))
            bnd = WPB.ENTITIES[(d,t)]
        else
            bnd = WPB.ElementaryEntity(d, t)
            _fill_entity_boundary!(bnd)
        end
        push!(ent.boundary, bnd)
    end
    return ent
end

"""
    _domain_to_mesh!(elements, ent2tag, Ω::Domain)

Recursively populating the dictionaries `elements` and `ent2tag`.
"""
function _domain_to_mesh!(elements, ent2tag, Ω::WPB.Domain)
    isempty(Ω) && (return elements, ent2tag)
    for ω in Ω
        _ent_to_mesh!(elements, ent2tag, ω)
    end
    Γ = WPB.skeleton(Ω)
    _domain_to_mesh!(elements, ent2tag, Γ)
end

"""
    _ent_to_mesh!(elements, ent2tag, ω::ElementaryEntity)

For each element type used to mesh `ω`:
- push into `elements::Dict` the pair `etype=>ntags`;
- push into `ent2tag::Dict` the pair `etype=>etags`;

where:
- `etype::DataType` determines the type of the element (see
    [`_type_tag_to_etype`](@ref));
- `ntags::Matrix{Int}` gives the indices of the nodes defining those
    elements;
- `etags::Vector{Int}` gives the indices of those elements in `elements`.
"""
function _ent_to_mesh!(elements, ent2tag, ω::WPB.ElementaryEntity)
    ω in keys(ent2tag) && (return elements, ent2tag)
    etypes_to_etags = Dict{DataType,Vector{Int}}()
    # Loop on GMSH element types (integer)
    type_tags, _, ntagss = gmsh.model.mesh.getElements(WPB.geometric_dimension(ω),WPB.tag(ω))
    for (type_tag, ntags) in zip(type_tags, ntagss)
        _, _, _, Np, _ = gmsh.model.mesh.getElementProperties(type_tag)
        ntags = reshape(ntags, Int(Np), :)
        etype = _type_tag_to_etype(type_tag)
        if etype in keys(elements)
            etag = size(elements[etype], 2) .+ collect(1:size(ntags,2))
            ntags = hcat(elements[etype], ntags)
        else
            etag = collect(1:size(ntags, 2))
        end
        push!(elements, etype => ntags)
        push!(etypes_to_etags, etype => etag)
    end
    push!(ent2tag, ω => etypes_to_etags)
    return elements, ent2tag
end

function set_meshsize(hmax, hmin=hmax)
    gmsh.option.setNumber("Mesh.CharacteristicLengthMin", hmin)
    gmsh.option.setNumber("Mesh.CharacteristicLengthMax", hmax)
end

function set_meshorder(order)
    gmsh.option.setNumber("Mesh.ElementOrder", order)
end

function set_verbosity(i)
    gmsh.option.setNumber("General.Verbosity",i)
end

function summary(model)
    gmsh.model.setCurrent(model)
    @printf("List of entities in model `%s`: \n", model)
    @printf("|%10s|%10s|%10s|\n","name","dimension","tag")
    ents = gmsh.model.getEntities()
    # pgroups = gmsh.model.getPhysicalGroups()
    for ent in ents
        name = gmsh.model.getEntityName(ent...)
        dim, tag = ent
        @printf("|%10s|%10d|%10d|\n", name, dim, tag)
    end
    println()
end

function summary()
    models = gmsh.model.list()
    for model in models
        summary(model)
    end
end

"""
    _type_tag_to_etype(tag)

Mapping of `gmsh` element types, encoded as an integer, to the internal
equivalent of those. This function assumes `gmsh` has been initilized.
"""
function _type_tag_to_etype(tag)
    T = SVector{3,Float64} # point type
    name,dim,order,num_nodes,ref_nodes,num_primary_nodes  = gmsh.model.mesh.getElementProperties(tag)
    num_nodes = Int(num_nodes) #convert to Int64
    if occursin("Point",name)
        etype = WPB.LagrangePoint{3,Float64}
    elseif occursin("Line",name)
    etype = WPB.LagrangeLine{num_nodes,T}
    elseif occursin("Triangle",name)
        etype = WPB.LagrangeTriangle{num_nodes,T}
    elseif occursin("Quadrilateral",name)
        etype = WPB.LagrangeSquare{num_nodes,T}
    elseif occursin("Tetrahedron",name)
        etype = WPB.LagrangeTetrahedron{num_nodes,T}
    else
        error("gmsh element of family $name does not an internal equivalent")
    end
    return etype
end

"""
    _etype_to_type_tag(etype)

Mapping of internal element types, to the integer tag of `gmsh` elements. This
function assumes `gmsh` has been initialized.
"""
function _etype_to_type_tag(el::WPB.LagrangeElement)
    etype = typeof(el)
    tag = 1
    while true
        E   = _type_tag_to_etype(tag)
        E === etype && (return tag)
        tag = tag + 1
    end
end

"""
    struct GmshParametricEntity{M} <: AbstractEntity

An attempt to wrap a `gmsh` entity into an internal object which can access the
underlying entity parametrization.

The interface implements a somewhat *hacky* way to use `gmsh` as a `CAD` reader.
Some important points to keep in mind (which make this *hacky*):
- Each call `el(x)` entails calling a function on the `gmsh` library (linked
  dynamically). In particular the call signature for the `gmsh`'s `getValue`
  method requires passing a `Vector` for the input point, and therefore some
  unnecessary allocations are incurred. Overall, this means **this interface is inneficient**.
- Only untrimmed surfaces should be considered; thus **this interface is
  limited** to somewhat simple surfaces.
- **No guarantee is given on the quality of the parametrization**. For instance, a
  sphere may be parametrized using spherical coordinates, for which a geometric
  singularity exists at the poles. For complex surfaces, it is typically much
  better to simply mesh the surface using `gmsh` and then import the file.


!!! warning
  This is an experimental feature and should be used with caution.
"""
struct GmshParametricEntity{M} <: WPB.AbstractEntity
    tag::Int
    domain::WPB.HyperRectangle{M,Float64}
    function GmshParametricEntity{M}(tag,domain) where {M}
        dim = M
        ent = new{M}(dim,domain)
        WPB.global_add_entity!(ent)
        return ent
    # TODO: throw a warning if the surface is trimmed
    end
end

function GmshParametricEntity(dim::Int,tag::Int,model=gmsh.model.getCurrent())
    low_corner,high_corner = gmsh.model.getParametrizationBounds(dim,tag)
    rec = WPB.HyperRectangle(low_corner,high_corner)
    return GmshParametricEntity{dim}(tag,rec)
end
GmshParametricEntity(dim::Integer,tag::Integer,args...;kwargs...) = GmshParametricEntity(Int(dim),Int(tag),args...;kwargs...)

function (par::GmshParametricEntity{N})(x) where {N}
    if N === 1
        return gmsh.model.getValue(N,par.tag,x)
    elseif N===2
        return gmsh.model.getValue(N,par.tag,[x[1],x[2]])
    else
        error("got N=$N, values must be 1 or 2")
    end
end

function WPB.jacobian(psurf::GmshParametricEntity{N},s::SVector) where {N}
    if N==1
        jac = gmsh.model.getDerivative(N,psurf.tag,s)
        return SMatrix{3,1}(jac)
    elseif N==2
        jac = gmsh.model.getDerivative(N,psurf.tag,[s[1],s[2]])
        return SMatrix{3,2}(jac)
    else
        error("got N=$N, values must be 1 or 2")
    end
end
