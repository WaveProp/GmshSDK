module GmshSDK

using Pkg.Artifacts

const version = "4.6.0"

gmsh_path = artifact"gmsh4.6.0"

dirs      = readdir(gmsh_path,join=true)

@assert length(dirs)==1 "there should be only one directory for the untared gmsh file. Got $dirs"

include(joinpath(first(dirs),"lib","gmsh.jl"))

export gmsh

end # module