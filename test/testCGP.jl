import GeneticJulia
include("fitnessFunctions.jl")
import Random
println("hola")
println("hola")
println("hola")
"""
rng = Random.MersenneTwister(6)

setIndividualType(CGPGenotype)
setRNG(rng)
setGPExperimentInfo()
setGenerator(rampedHalfHalfGenerator, popSize = 10, generateOneByOne=false)
genPopulation!(GenJ)
gen1, gen2 = getGenotype(GenJ._population[1]), getGenotype(GenJ._population[6])
phen1 = getPhenotype(gen1)
phen2 = getPhenotype(gen2)
_,_, pointDepth = selectCrossPoint(gen1, rng)
selectCrossPoint(gen2, rng, minDepth=pointDepth, maxDepth=3)
#children = subtreeCross(gen1, gen2, GenJ._experimentInfo._GPExperimentInfo, rng)
#mutatedParent = subtreeMutation(parent1, GenJ._experimentInfo._GPExperimentInfo._functionSet, GenJ._experimentInfo._GPExperimentInfo._terminalSet, 3, GenJ._experimentInfo._rng, canonicalFullGenerator)
#fenotipo = getPhenotype(parent1, GenJ._experimentInfo._GPExperimentInfo)




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

GeneticJulia.setIndividualType(GeneticJulia.CGPGenotype)
GeneticJulia.setRandomSeed(2)
GeneticJulia.setCGPInfo(nodesFile="GeneticJulia/src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
GeneticJulia.setAlgorithm(GeneticJulia.SPEA, 10)
GeneticJulia.setStopCondition(maxIterations=50)
GeneticJulia.setEvaluator([GeneticJulia.FitnessFunction(GeneticJulia.compareFunctions, objs, x, y, weight=-1), GeneticJulia.FitnessFunction(nNodes, weight=-0.2)],
            globalFitnessFunction=GeneticJulia.FitnessFunction(GeneticJulia.pareto), compareFunctionArgs="global")
GeneticJulia.setGenerator(GeneticJulia.rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
GeneticJulia.setSelector(GeneticJulia.tournamentSelector, 2)
GeneticJulia.setCrossoverOperator(GeneticJulia.subtreeCross, probability=0.9)
GeneticJulia.setMutationOperator(GeneticJulia.subtreeMutation, probability=0.2)
GeneticJulia.setReplacementOperator(GeneticJulia.replaceAllPopulation, eliteSize=5)
GeneticJulia.setExperimentSummary(batchSize=20, printDuringExperiment=true)

@time GeneticJulia.runGenJ(verbose=false)
"""


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

GeneticJulia.setIndividualType(GeneticJulia.CGPGenotype)
GeneticJulia.setRandomSeed(54)
GeneticJulia.setCGPInfo(nodesFile="src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
GeneticJulia.setStopCondition(maxIterations=50)
GeneticJulia.setEvaluator([GeneticJulia.FitnessFunction(GeneticJulia.compareFunctions, objs, x, y, weight=-1)])
GeneticJulia.setGenerator(GeneticJulia.rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
GeneticJulia.setSelector(GeneticJulia.tournamentSelector, 4)
GeneticJulia.setCrossoverOperator(GeneticJulia.subtreeCross, probability=0.9)
GeneticJulia.setMutationOperator(GeneticJulia.pointMutation, 0.2, probability=0.1)
GeneticJulia.setReplacementOperator(GeneticJulia.replaceAllPopulation, eliteSize=5)
GeneticJulia.setExperimentSummary(batchSize=-1)


@time GeneticJulia.runGenJ(verbose=false)
