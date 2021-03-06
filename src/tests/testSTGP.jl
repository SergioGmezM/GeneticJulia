include("../base.jl")
import Random



patrones = [
    [2, 4],
    [1, 6],
    [8, 2],
    [5, 5],
    [0, 9],
    [12, 4],
    [10, 4],
    [1, 9],
    [8, 3],
    [10, 20],
    [7, 5],
]

x = Array{Int}(undef, 11)
y = Array{Int}(undef, 11)

for i = 1:11
    x[i] = patrones[i][1]
    y[i] = patrones[i][2]
end

clases = [true, true, false, true, true, false, false, true, false, true, false]

function CCR(genotype::STGPGenotype, gpExperimentInfo::STGPInfo, clases::Array{Bool}, x::Array{Int}, y::Array{Int})

    aciertos = 0

    fenotipo = getPhenotype(genotype)

    for i=1:11
        clase_estimada = evaluate(fenotipo, ["x", "y"], x[i], y[i])
        if typeof(clase_estimada) <: Bool
            if clases[i] == clase_estimada
                aciertos += 1
            end
        end
    end

    return (aciertos/11)*100
end


println("hola")
"""
rng = Random.MersenneTwister(142)

setIndividualType(STGPGenotype)
setRNG(rng)
setGPExperimentInfo()

setStopCondition(maxIterations = 50)
setEvaluator([FitnessFunction(CCR, clases, x, y, weight=1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 5)
setCrossoverOperator(subtreeCross, probability = 0.9)
setMutationOperator(onePointMutation, probability = 0.2)
setReplacementOperator(replaceAllPopulation)

genPopulation!(GenJ)
evaluate!(GenJ, GenJ._population)
#phenotype, fenotipo = getPhenotype(GenJ._population[1]._genotype, GenJ._experimentInfo._GPExperimentInfo)
#evaluate!(GenJ, GenJ._population)
#children = onePointCross(GenJ._population[1]._genotype, GenJ._population[2]._genotype, GenJ._experimentInfo._GPExperimentInfo, rng)
#mutated = pointMutation(GenJ._population[1]._genotype, GenJ._experimentInfo._GPExperimentInfo, rng, 0.2)


"""

setIndividualType(STGPGenotype)
setRandomSeed(2)
setGPExperimentInfo()

setStopCondition(maxIterations = 50)
setEvaluator([FitnessFunction(CCR, clases, x, y, weight=1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 5)
setCrossoverOperator(subtreeCross, probability = 0.9)
setMutationOperator(onePointMutation, probability = 0.2)
setReplacementOperator(replaceAllPopulation)

@time runGenJ(verbose = false)
