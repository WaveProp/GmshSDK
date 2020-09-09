module Gmsh

using Pkg.Artifacts

gmsh_path = artifact"gmsh"
tmp = readdir(gmsh_path,join=true)[1]

include(joinpath(tmp,"lib","gmsh.jl"))

end # module
