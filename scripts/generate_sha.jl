# This script automates the genenration of the Artifacts.toml file given a version of gmsh. 

using ArtifactUtils, Pkg.Artifacts
using Pkg.BinaryPlatforms: Linux, MacOS, Windows, FreeBSD

const version = "4.7.0"

platform_to_dist = Dict(
        # glibc Linuces
        Linux(:i686,libc=:glibc)        => "Linux32",
        Linux(:armv7l,libc=:glibc)      => "Linux32",
        Linux(:x86_64,libc=:glibc)      => "Linux64",
        Linux(:aarch64,libc=:glibc)     => "Linux64",
        Linux(:powerpc64le,libc=:glibc) => "Linux64",

        # # musl Linuces
        Linux(:i686, libc=:musl)        => "Linux32",
        Linux(:x86_64, libc=:musl)      => "Linux64",
        Linux(:aarch64, libc=:musl)     => "Linux64",
        Linux(:armv7l, libc=:musl)      => "Linux32",

        # BSDs
        MacOS(:x86_64)                  => "MacOSX",
        FreeBSD(:x86_64)                => "Linux64",

        # # Windows
        Windows(:i686)                    => "Windows32",
        Windows(:x86_64)                  => "Windows64"
)

dist_to_url = Dict(
    "Linux32"   => "https://gmsh.info/bin/Linux/gmsh-$version-Linux32-sdk.tgz",
    "Linux64"   => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",
    "MacOSX"     => "https://gmsh.info/bin/MacOSX/gmsh-$version-MacOSX-sdk.tgz",
    "Windows32" => "https://gmsh.info/bin/Windows/gmsh-$version-Windows32-sdk.zip",
    "Windows64" => "https://gmsh.info/bin/Windows/gmsh-$version-Windows64-sdk.zip"
)

artifact_toml = joinpath(@__DIR__,"..","Artifacts.toml") |> normpath

artifact_name = "gmsh$version"

# write Artifacts.toml file
for (platform,dist) in platform_to_dist
    url                  = dist_to_url[dist]
    add_artifact!(artifact_toml,artifact_name,url;clear=true,platform=platform,force=true,lazy=true)
    # Artifacts.bind_artifact!(artifact_toml,artifact_name,Base.SHA1(sha1_str),platform=platform,download_info=download_info,force=true,lazy=true)
end 


