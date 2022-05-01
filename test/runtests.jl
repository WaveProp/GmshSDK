using Test
using GmshSDK
import WavePropBase as WPB

@testset "Basic tests" begin
    @gmsh begin
        WPB.clear_entities!()
        # try some basic things just to make sure it does not error
        gmsh.model.geo.addPoint(0,0,0)    # test native CAO
        gmsh.model.occ.addSphere(0,0,0,1) # test occ is available
        gmsh.model.occ.synchronize()
        gmsh.model.mesh.generate(3)
        gmsh.model.mesh.partition(5) # test metis is available
        @test true == true #
    end
    # read domain from a model
    @gmsh begin
        WPB.clear_entities!()
        gmsh.model.occ.addSphere(0,0,0,1)
        gmsh.model.occ.synchronize()
        Ω = GmshSDK.domain()
        @test WPB.geometric_dimension(Ω) == 3
    end
    # read domain and mesh from a model
    Ω,M = @gmsh begin
        WPB.clear_entities!()
        gmsh.model.occ.addDisk(0,0,0,1,1)
        gmsh.model.occ.synchronize()
        gmsh.model.mesh.generate(2)
        Ω = GmshSDK.domain(dim=2)
        M = GmshSDK.meshgen(Ω,dim=2)
        return Ω,M
    end
    Ω,M = @gmsh begin
        WPB.clear_entities!()
        gmsh.model.occ.addRectangle(0,0,0,1,1)
        gmsh.model.occ.synchronize()
        gmsh.model.mesh.generate(2)
        Ω = GmshSDK.domain(dim=2)
        M = GmshSDK.meshgen(Ω,dim=2)
        return Ω,M
    end
    # read domain from a file
    @gmsh begin
        fname = joinpath(GmshSDK.PROJECT_ROOT,"test","circle.geo")
        Ω =  GmshSDK.read_geo(fname;dim=2)
    end
    # read domain and mesh from a file
    Ω, msh = @gmsh begin
        WPB.clear_entities!()
        dir = @__DIR__
        fname = joinpath(dir,"circle.msh")
        GmshSDK.read_msh(fname;dim=2)
    end
end
