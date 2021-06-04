using Test
using GmshSDK

@testset "Basic tests" begin
    @gmsh begin
        # try some basic things just to make sure it does not error
        gmsh.model.geo.addPoint(0,0,0)    # test native CAO
        gmsh.model.occ.addSphere(0,0,0,1) # test occ is available
        gmsh.model.occ.synchronize()
        gmsh.model.mesh.generate(3)
        gmsh.model.mesh.partition(5) # test metis is available
        @test true == true #
    end
end

@testset "IO" begin
    GmshSDK.clear_entities!()
    Ω,M = GmshSDK.sphere(;h=0.5)
    Γ_mesh = view(M,GmshSDK.external_boundary(Ω))
    @test true == true #
end
