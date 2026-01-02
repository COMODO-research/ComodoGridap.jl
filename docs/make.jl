using ComodoGridap
using Documenter

DocMeta.setdocmeta!(ComodoGridap, :DocTestSetup, :(using ComodoGridap); recursive=true)

makedocs(;
    modules=[ComodoGridap],
    authors="Aminofa70 <amin.alibakhshi@upm.es> and contributors",
    sitename="ComodoGridap.jl",
    format=Documenter.HTML(;
        canonical="https://COMODO-research.github.io/ComodoGridap.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/COMODO-research/ComodoGridap.jl",
    devbranch="main",
)
