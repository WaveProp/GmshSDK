using GmshSDK
using Documenter

DocMeta.setdocmeta!(GmshSDK, :DocTestSetup, :(using GmshSDK); recursive=true)

makedocs(;
    modules=[GmshSDK],
    authors="Luiz M. Faria <maltezfaria@gmail.com> and contributors",
    repo="https://github.com/WaveProp/GmshSDK.jl/blob/{commit}{path}#{line}",
    sitename="GmshSDK.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://WaveProp.github.io/GmshSDK.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/WaveProp/GmshSDK.jl",
    devbranch="main",
)
