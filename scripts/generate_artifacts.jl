# This script automates the genenration of the Artifacts.toml file given a
# version of gmsh. It is essentially run once per release when the gmsh version
# is updated.

using Artifacts
using ArtifactUtils
using Pkg.BinaryPlatforms: Linux, MacOS, Windows, FreeBSD

const version = "4.8.4"

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
    # NOTE: the url for windows is currently set to a "personal" file on the
    # WaveProp organization. The reason is that Artifacts do not play well with
    # zipped files, and the official version of gmsh provided for windows on the
    # gmsh website is zipped. The files below are just the decompressed and
    # tarred version of the official files.
    "Windows32" => "https://github.com/WaveProp/.github/raw/main/gmsh-4.8.4-Windows32-sdk.tgz",
    "Windows64" => "https://github.com/WaveProp/.github/raw/main/gmsh-4.8.4-Windows64-sdk.tgz"
)

artifact_toml = joinpath(@__DIR__,"..","Artifacts.toml") |> normpath

artifact_name = "gmsh$version"

for (platform,dist) in platform_to_dist
    url                  = dist_to_url[dist]
    add_artifact!(artifact_toml,artifact_name,url;clear=true,platform=platform,force=true,lazy=true)
end
