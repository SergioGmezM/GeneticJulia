include("../base.jl")
include("algorithms.jl")
include("fitnessFunctions.jl")

function f(x, y)
    (y/5.5)+x^2
end

function g(x, y)
    2*x + y
end

x = collect(-5:0.5:5)
y = collect(0:0.5:10)
nvalues = length(x)
objs1 = Array{Number}(undef, nvalues)
for i=1:nvalues
    objs1[i] = f(x[i], y[i])
end

nvalues = length(x)
objs2 = Array{Number}(undef, nvalues)
for i=1:nvalues
    objs2[i] = g(x[i], y[i])
end

mirng = Random.MersenneTwister(5)

@time experimentos=runGenJ("ECJ/tests/example.json", verbose=false)
