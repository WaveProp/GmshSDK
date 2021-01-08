using Test
using GmshSDK

gmsh.initialize()
    # try some basic things just to make sure it does not error
    gmsh.model.geo.addPoint(0,0,0)
    gmsh.model.occ.addSphere(0,0,0,1)
    gmsh.model.occ.synchronize()
    gmsh.model.mesh.generate(3)
    @test true == true # gmsh was initialized without errors
gmsh.finalize()

gmsh.initialize()
    # try some basic things just to make sure it does not error
    gmsh.model.geo.addPoint(0,0,0)
    gmsh.model.occ.addSphere(0,0,0,1)
    gmsh.model.occ.synchronize()
    gmsh.model.mesh.generate(3)
    gmsh.model.mesh.partition(5)
    @test true == true # gmsh was initialized without errors
gmsh.finalize()
