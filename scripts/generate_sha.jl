# This script automates the genenration of the Artifacts.toml file given a version of gmsh. 

using Tar, Inflate, SHA, Pkg.Artifacts
using Pkg.BinaryPlatforms: Linux, MacOS, Windows, FreeBSD

version = "4.6.0"

platform_url = Dict(
        # glibc Linuces
        Linux(:i686,libc=:glibc)        => "https://gmsh.info/bin/Linux/gmsh-$version-Linux32-sdk.tgz",
        Linux(:armv7l,libc=:glibc)      => "https://gmsh.info/bin/Linux/gmsh-$version-Linux32-sdk.tgz",
        Linux(:x86_64,libc=:glibc)      => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",
        Linux(:aarch64,libc=:glibc)     => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",
        Linux(:powerpc64le,libc=:glibc) => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",

        # musl Linuces
        Linux(:i686, libc=:musl)        => "https://gmsh.info/bin/Linux/gmsh-$version-Linux32-sdk.tgz",
        Linux(:x86_64, libc=:musl)      => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",
        Linux(:aarch64, libc=:musl)     => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",
        Linux(:armv7l, libc=:musl)      => "https://gmsh.info/bin/Linux/gmsh-$version-Linux32-sdk.tgz",

        # BSDs
        MacOS(:x86_64)                  => "https://gmsh.info/bin/MacOSX/gmsh-$version-MacOSX-sdk.tgz",
        FreeBSD(:x86_64)                => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",

        # Windows
        # Windows(:i686)                    => "https://gmsh.info/bin/Windows/gmsh-$version-Windows32-sdk.zip",
        # Windows(:x86_64)                  => "https://gmsh.info/bin/Windows/gmsh-$version-Windows64-sdk.zip"
)

function compute_sha(url)
    tmp_file   = download(url)
    sha1_str   = Tar.tree_hash(IOBuffer(inflate_gzip(tmp_file)))
    sha256_str = bytes2hex(open(sha256, tmp_file))
    return sha1_str, sha256_str
end

artifact_toml = joinpath(@__DIR__,"..","Artifacts.toml") |> normpath

artifact_name = "gmsh$version"

for (platform,url) in platform_url
    sha1_str,sha256_str = compute_sha(url)
    download_info = [(url,sha256_str)]
Artifacts.bind_artifact!(artifact_toml,artifact_name,Base.SHA1(sha1_str),
                             platform=platform,
download_info=download_info,force=true,lazy=true)
end 