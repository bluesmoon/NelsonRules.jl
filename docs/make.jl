using Documenter, NelsonRules

makedocs(
    sitename="NelsonRules.jl Documentation",
    format=Documenter.HTML(
        prettyurls = false,
        edit_link="main",
    ),
    modules=[NelsonRules],
)

deploydocs(
    repo = "github.com/bluesmoon/NelsonRules.jl.git",
)
