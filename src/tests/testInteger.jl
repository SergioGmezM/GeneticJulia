include("../base.jl")
include("fitnessFunctions.jl")


setIndividualType(IntegerGenotype{Int64})
setRandomSeed(9)
setStopCondition(maxIterations = 1000)
setEvaluator(llegar50, -1)
setGenerator(randomIntegerGenerator, 10, 0, 10, popSize = 100)
setSelector(tournamentSelector, 3, samplingWithRep = true, nSelected = 1.0)
setCrossoverOperator(uniformCross, nChildren = 2)
setMutationOperator(uniformMutation, 0, 10, 1)
setReplacementOperator(replaceAllPopulation)
setExperimentSummary(displayFitness=false, printDuringExperiment=true, outputFile="hola.txt")


@time runGenJ(verbose=false)
