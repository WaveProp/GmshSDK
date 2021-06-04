# GmshSDK.jl
*Julia artifacts for [Gmsh Software Development
Kit](https://gmsh.info/#Download)*

![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://WaveProp.github.io/GmshSDK/stable)
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
download a given version of *Gmsh Software Development Toolkit*. It then exports
the *gmsh* module so that you can interact with the Gmsh API. It also provides
basic functionality for integrating with the mesh format in `WavePropBase`.

```julia
using GmshSDK
gmsh.initialize()
# do gmsh-fu
gmsh.finalize()
```

See the [gmsh api manual](https://gmsh.info/doc/texinfo/gmsh.html#Gmsh-API) for more
information on what you can with `gmsh`.
