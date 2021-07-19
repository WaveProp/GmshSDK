module GmshSDK

using Pkg.Artifacts
using StaticArrays
using RecipesBase
using OrderedCollections
using Printf

using WavePropBase
using WavePropBase.Geometry
using WavePropBase.Interpolation
using WavePropBase.Mesh

const gmsh_path = artifact"gmsh4.7.0"

const dirs      = readdir(gmsh_path,join=true)

@assert length(dirs)==1 "there should be only one directory for the untared gmsh file. Got $dirs"

include(joinpath(first(dirs),"lib","gmsh.jl"))

include("gmshIO.jl")

export
    # macros
    @gmsh,
    # methods
    gmsh

end # module
