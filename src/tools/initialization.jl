"
Generator represents the way that a population is going to be generated.

# Fields
-`_popSize::UInt32`: size of the population, number of individuals.
-`_generateOneByOne::Bool`: specifies wether the generation method generates
    a single individual each run or the whole population at a time.
-`_method::Function`: method used for generating the individuals.
-`_varArgs::Array{Any}`: arguments necessary for the generation method.
"
mutable struct Generator
    _popSize::UInt32
    _generateOneByOne::Bool
    _method::Function
    _varArgs::Array{Any}
end # struct



"""
    getPopSize(gen::Generator)::UInt32

Returns the population size assigned.
"""
getPopSize(gen::Generator)::UInt32 = gen._popSize
# function



"""
    getMethod(gen::Generator)::Function

Returns the method for generate the population.
"""
getMethod(gen::Generator)::Function = gen._method
# function



"""
    isGeneratedOneByOne(gen::Generator)::Bool

Returns whether the method generates individual one by one or all individuals in a single call
"""
isGeneratedOneByOne(gen::Generator)::Bool = gen._generateOneByOne
#function



"""
    getFunctionArgs(gen::Generator)::Array

Obtains the aditional arguments associated to initialization method.
"""
getFunctionArgs(gen::Generator)::Array = gen._varArgs
#function



"""
    genPopulation_(generator::Generator, experimentInfo::ExperimentInfo)::Array{Individual}

Generates a population of individuals according to the method given by the Generator.
"""
function genPopulation_(generator::Generator, experimentInfo::ExperimentInfo)::Array{Individual}

    popSize = getPopSize(generator)
    population = Array{Individual}(undef, popSize)
    rng = getRNG(experimentInfo)

    method = getMethod(generator)
    functionArgs = getFunctionArgs(generator)

    if getIndividualType(experimentInfo) <: GAGenotype
        if isGeneratedOneByOne(generator)
            for i = 1:popSize
                genotype = method(rng, functionArgs...)
                population[i] = Individual(genotype)
            end
        else
            populationGenotype = method(popSize, rng, functionArgs...)
            map!(x->Individual(x), population, populationGenotype)
        end
    else
        if isGeneratedOneByOne(generator)
            for i = 1:popSize
                genotype = method(experimentInfo._GPExperimentInfo, rng, functionArgs...)
                population[i] = Individual(genotype)
            end
        else
            populationGenotype = method(experimentInfo._GPExperimentInfo, popSize, rng, functionArgs...)
            map!(x->Individual(x), population, populationGenotype)
        end
    end

    return population
end # function
