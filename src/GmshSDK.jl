module GmshSDK

using Artifacts
using StaticArrays
using RecipesBase
using OrderedCollections
using Printf

using WavePropBase
using WavePropBase.Geometry
using WavePropBase.Interpolation
using WavePropBase.Mesh

const GMSH_VERSION   = "4.8.4"

const GMSH_PATH = artifact"gmsh4.8.4"

const dirs      = readdir(GMSH_PATH,join=true)

@assert length(dirs)==1 "there should be only one directory for the untared gmsh file. Got $dirs"

include(joinpath(first(dirs),"lib","gmsh.jl"))

include("gmshIO.jl")

export
    gmsh,
    # re-export useful modules from WavePropBase
    Geometry,
    Mesh,
    # macros
    @gmsh
    # methods

end # module
