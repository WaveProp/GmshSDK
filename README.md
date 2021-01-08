# GmshSDK.jl
*Julia artifacts for [Gmsh Software Development Kit](https://gmsh.info/#Download)*

![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![CI](https://github.com/WaveProp/GmshSDK/workflows/CI/badge.svg?branch=main)

## Installation
Install from the Pkg REPL:
```
pkg> add GmshSDK
```

## Usage

This package provides in its `Artifacts.toml` the information required to
download a given version of *Gmsh Software Development Toolkit*. It then exports
the *gmsh* module so that you can interact with the Gmsh API. In summary, it is
just a convenience tool for interacting with the *Julia API* from *Gmsh*, and
all credits go to the *gmsh* developers. Basic usage:

```julia
using GmshSDK
gmsh.initialize()
# do gmsh-fu
gmsh.finalize()
```

See the [gmsh api manual](https://gmsh.info/doc/texinfo/gmsh.html#Gmsh-API) for more
information on what you can with `gmsh`.
