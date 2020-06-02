import GeneticJulia
include("fitnessFunctions.jl")

GeneticJulia.setRandomSeed(5)
GeneticJulia.setIndividualType(GeneticJulia.BinaryGenotype)
GeneticJulia.setStopCondition(maxIterations=500)
GeneticJulia.setEvaluator(GeneticJulia.FitnessFunction(countBinaryOnes))
GeneticJulia.setGenerator(GeneticJulia.randomBinaryGenerator, 50, popSize = 100)
GeneticJulia.setSelector(GeneticJulia.tournamentSelector, 20, samplingWithRep=true, nSelected=2.)
GeneticJulia.setCrossoverOperator(GeneticJulia.uniformCross, nChildren=2)
GeneticJulia.setMutationOperator(GeneticJulia.standardMutation, 0.1)
GeneticJulia.setReplacementOperator(GeneticJulia.replaceAllPopulation)




@time GeneticJulia.runGenJ(verbose=false)
