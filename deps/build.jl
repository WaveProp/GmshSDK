using Tar, Inflate, SHA

# This is the path to the Artifacts.toml we will manipulate
artifact_toml = joinpath(@__DIR__,"..","Artifacts.toml") |> normpath

# using Tar, Inflate, SHA

version = "4.6.0"
# url_root = "https://gmsh.info/bin/Linux/gmsh-4.6.0-Linux64-sdk.tgz"
url_root = "https://gmsh.info/bin/"
platform = Linux
wsize = 64
for platform in (Linux,)
    for wsize in (64,)
        fname = "gmsh-$version-$(platform)$wsize-sdk.tgz"
        download_url = "$(url_root)/$platform/$fname"
        tmp_file = download(download_url)
        _sha256 = bytes2hex(open(sha256, tmp_file))
        _sha1   = Tar.tree_hash(IOBuffer(inflate_gzip(tmp_file)))
        # println("sha256: ", _sha256)
        # println("git-tree-sha1: ", _sha1)
        download_info = [(download_url,_sha256)]
        Artifacts.bind_artifact!(artifact_toml,"gmsh",Base.SHA1("73dcca3f4136dde3813cab497eb3c41eb35f5468"),
                                 platform=platform, download_info=download_info,
                                 force=true)
    end
end
