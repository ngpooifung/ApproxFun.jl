versioninfo()

using ApproxFun,Base.Test


println("Multivariate tests")
include("MultivariateTest.jl")
println("PDE tests")
include("PDETest.jl")
println("Speed tests")
include("SpeedTest.jl")
include("SpeedODETest.jl")
include("SpeedPDETest.jl")


println("Example tests")
if isdir(Pkg.dir("Gadfly"))
    include("ExamplesTest.jl")
    include("ReadmeTest.jl")
else
    warn("Unable to do Examples since Gadfly.jl is not installed")
end
