include("../base.jl")
include("fitnessFunctions.jl")

setRandomSeed(5)
setIndividualType(BinaryGenotype)
setStopCondition(maxIterations=500)
setEvaluator(FitnessFunction(countBinaryOnes))
setGenerator(randomBinaryGenerator, 50, popSize = 100)
setSelector(tournamentSelector, 20, samplingWithRep=true, nSelected=2.)
setCrossoverOperator(uniformCross, nChildren=2)
setMutationOperator(standardMutation, 0.1)
setReplacementOperator(replaceAllPopulation)

println("HOla")
println("HOla")
a=typeof(precompile(cross_, (CrossoverOperator, Array{Individual}, ExperimentInfo)))

runGenJ(verbose=false)


"""
genPopulation!(GenJ)

evaluate!(GenJ, GenJ._population) # TODO Tarda mas, revisar

setSelector(tournamentSelector, 20, samplingWithRep=true, nSelected=200)

selected = selectParents(GenJ)

@time offspring = cross(GenJ, selected) # TODO Tarda maxSymbols

offspring = mutate(GenJ, offspring)


evaluate!(GenJ, offspring)

replacePopulation!(GenJ, offspring) # TODO Tarda maxSymbols
"""

"""
setIndividualType(BinaryGenotype)
setAlgorithm(SPEA, 20)
setStopCondition(maxIterations=100)
setEvaluator(countBinaryOnes, 1, countBinaryZeros, 1, globalFitnessFunction=FitnessFunction(pareto))
setGenerator(randomBinaryGenerator, 50, popSize = 100)
setSelector(tournamentSelector, 4)
setCrossoverOperator(uniformCross)
setMutationOperator(standardMutation, 0.1)
setReplacementOperator(replaceAllPopulation)

@time runGenJ(verbose=false)

#a = GenJ._evaluator._compareFitness([10, 5], [7, 10], 1, 2)

population = genPopulation(GenJ._generator, GenJ._experimentInfo)
evaluate!(GenJ._evaluator, GenJ._experimentInfo, population, GenJ._stopCondition)
weights = getWeights(GenJ._evaluator)



conjunto1 = Array{Individual}(undef, 10)
conjunto2 = [population[2], population[3], population[1]]

launion=(union(conjunto1,conjunto2))


paretoLevel = pareto(population, weights)




"""
