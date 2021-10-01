# GmshSDK.jl
*Julia artifacts for [Gmsh Software Development
Kit](https://gmsh.info/#Download)*

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://WaveProp.github.io/GmshSDK/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://WaveProp.github.io/GmshSDK/dev)
[![Build
Status](https://github.com/WaveProp/GmshSDK/workflows/CI/badge.svg)](https://github.com/WaveProp/GmshSDK/actions)
[![codecov](https://codecov.io/gh/WaveProp/GmshSDK/branch/main/graph/badge.svg?token=codJo03vp6)](https://codecov.io/gh/WaveProp/GmshSDK)


## Installation
Install from the Pkg REPL:
```
pkg> add https://github.com/WaveProp/GmshSDK
```

## Usage

This package provides in its `Artifacts.toml` the information required to
download and use the *Gmsh Software Development Toolkit*, as well as some
convenience functions to interface meshes and domains created by *Gmsh* with
solvers in the [WaveProp](https://github.com/WaveProp) organization.

To simply use the `Gmsh` API, you can do the following:

```julia
using GmshSDK
gmsh.initialize()
# do gmsh-fu
gmsh.finalize()
```
where *gmsh-fu* stands for anything described on the official [gmsh api
    manual](https://gmsh.info/doc/texinfo/gmsh.html#Gmsh-API).

As mentioned, the package also provides some convenience functions for
converting meshes and/or domains created in *Gmsh* to internal representations
defined in [`WavePropBase`](https://github.com/WaveProp/WavePropBase). An
example of such a usage would be:

```julia
using GmshSDK, Plots
Ω,M = GmshSDK.sphere() # create and mesh a unit sphere
Γ   = Geometry.boundary(Ω) # extract the boundary
plot(view(M,Γ)) # plot the elements of the mesh on Γ
```

For more information, see the documentation for the functions in the
`src/gmshIO.jl` file and the `Geometry` and `Mesh` modules on [`WavePropBase`](https://github.com/WaveProp/WavePropBase).


## Version and Artifact generation

The version of `gmsh` used is stored in the `GmshSDK.GMSH_VERSION` variable. You
can also query the *Gmsh* version through `gmsh.GMSH_API_VERSION`,
`gmsh.GMSH.API_VERSION_MAJOR`, and `gmsh.GMSH_API_VERSION_MINOR`. If you need a
specific version of *Gmsh*, you can run `scripts/generate_artifacts.jl` to
create your own `Artifacts.toml` file locally.

## Related packages

If you simply need a wrapper for the *Gmsh* api, see also:

- [Gmsh.jl](https://github.com/JuliaFEM/Gmsh.jl)
- [GmshTools.jl](https://github.com/shipengcheng1230/GmshTools.jl)


## Issues

Please [file an issue](https://github.com/WaveProp/GmshSDK/issues) if you run
into a problem when trying to install this package.


