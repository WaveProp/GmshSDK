# This script automates the genenration of the Artifacts.toml file given a version of gmsh. 

using Tar, Inflate, SHA, Pkg.Artifacts
using Pkg.BinaryPlatforms: Linux, MacOS, Windows, FreeBSD

const version = 4.7

platform_to_dist = Dict(
        # glibc Linuces
        Linux(:i686,libc=:glibc)        => "Linux32",
        Linux(:armv7l,libc=:glibc)      => "Linux32",
        Linux(:x86_64,libc=:glibc)      => "Linux64",
        Linux(:aarch64,libc=:glibc)     => "Linux64",
        Linux(:powerpc64le,libc=:glibc) => "Linux64",

        # musl Linuces
        Linux(:i686, libc=:musl)        => "Linux32",
        Linux(:x86_64, libc=:musl)      => "Linux64",
        Linux(:aarch64, libc=:musl)     => "Linux64",
        Linux(:armv7l, libc=:musl)      => "Linux32",

        # BSDs
        MacOS(:x86_64)                  => "MacOSX",
        FreeBSD(:x86_64)                => "Linux64",

        # # Windows
        # Windows(:i686)                    => "Windows32",
        # Windows(:x86_64)                  => "Windows64"
)

function compute_sha(url)
    tmp_file   = download(url)
    sha1_str   = Tar.tree_hash(IOBuffer(inflate_gzip(tmp_file)))
    sha256_str = bytes2hex(open(sha256, tmp_file))
    return sha1_str, sha256_str
end

dist_to_url = Dict(
    "Linux32"   => "https://gmsh.info/bin/Linux/gmsh-$version-Linux32-sdk.tgz",
    "Linux64"   => "https://gmsh.info/bin/Linux/gmsh-$version-Linux64-sdk.tgz",
    "MacOSX"     => "https://gmsh.info/bin/MacOSX/gmsh-$version-MacOSX-sdk.tgz",
    "Windows32" => "https://gmsh.info/bin/Windows/gmsh-$version-Windows32-sdk.zip",
    "Windows64" => "https://gmsh.info/bin/Windows/gmsh-$version-Windows64-sdk.zip"
)

dist_to_sha = Dict()

for dist in ("Linux32","Linux64","MacOSX")
    url = dist_to_url[dist]
    sha1_str,sha256_str = compute_sha(url)
    push!(dist_to_sha,dist=>(sha1_str,sha256_str))
end 

artifact_toml = joinpath(@__DIR__,"..","Artifacts.toml") |> normpath

artifact_name = "gmsh$version"

# write Artifacts.toml file
for (platform,dist) in platform_to_dist
    sha1_str, sha256_str = dist_to_sha[dist]
    url                  = dist_to_url[dist]
    download_info        = [(url,sha256_str)]
    Artifacts.bind_artifact!(artifact_toml,artifact_name,Base.SHA1(sha1_str),platform=platform,download_info=download_info,force=true,lazy=true)
end 


