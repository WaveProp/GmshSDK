using Tar, Inflate, SHA

filename = "gmsh-4.6.0-Linux64-sdk.tgz"
println("sha256: ", bytes2hex(open(sha256, filename)))
println("git-tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(filename))))
