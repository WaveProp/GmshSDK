using Test
using GmshSDK

gmsh.initialize()
    @test true == true # gmsh was initialized without errors
gmsh.finalize()
