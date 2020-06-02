include("../base.jl")
import Random


f(x, y) = (y/5.5)+x^2


println("hola")
println("hola")
x = collect(-5:0.5:5)
y = collect(0:0.5:10)
nvalues = length(x)
objs = Array{Number}(undef, nvalues)
for i=1:nvalues
    objs[i] = f(x[i], y[i])
end

setIndividualType(GEPGenotype)
setRandomSeed(34)
setGPExperimentInfo()
setStopCondition(maxIterations=50)
setEvaluator([FitnessFunction(compareFunctions, objs, x, y, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 4)
setCrossoverOperator(kPointRecombinationCross, 2, probability=0.9)
setMutationOperator(geneMutation, probability=0.2)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=5, printDuringExperiment=true)


@time runGenJ(verbose=false)
