using Random, JSON, Statistics

noFunc() = nothing


include("utils/GeneticProgramming/nodes.jl")
include("utils/GeneticProgramming/nodeSetsParser.jl")
include("utils/miscFunctions.jl")
include("tools/individual.jl")
include("tools/experimentSummary.jl")



"
Auxiliary structure that keeps some generic information for GP experiments.
It is the abstract type from which every other GP experiment info inherits.

See also: [`ExperimentInfo`](@ref), [`CGPInfo`](@ref), [`STGPInfo`](@ref),
[`GEPInfo`](@ref), [`GEInfo`](@ref)
"
abstract type GPExperimentInfo end
# abstract type



"""
    getVariables(gpExperimentInfo::GPExperimentInfo)

Gets the identifiers of the variables of GP problem.

# Arguments
- `gpExperimentInfo::GPExperimentInfo`: information about the GP experiment.

# Returns
Array with variables' identifiers as `strings`.
"""
getVariables(gpExperimentInfo::GPExperimentInfo) = gpExperimentInfo._variables
# function



"
Auxiliary structure that keeps some generic information for experiments.

# Fields
- `_individualType::DataType`: type of the individual that determines which
    methods are going to be used.
- `_GPExperimentInfo::GPExperimentInfo`: if the problem to solve is GP, this field
    will contain its information.
- `_randomSeed::UInt`: seed used for rand functions. By default, it will be 1234.
- `_rng::Random.AbstractRNG`: random number generator used by the system. By
    default, it will be set to Random.GLOBAL_RNG.
- `_algorithm::Function`: genetic algorithm used for the experiment. By default,
    it will be set to the classic genetic algorithm (see [`basicExperiment`](@ref)).
- `_algorithmArgs::Array{Any}`: arguments for the genetic algorithm, if needed.

See also: [`GeneticJulia`](@ref)
"
mutable struct ExperimentInfo
    _individualType::DataType
    _GPExperimentInfo::GPExperimentInfo
    _experimentSummary::ExperimentSummary
    _randomSeed::UInt
    _rng::Random.AbstractRNG
    _algorithm::Function
    _algorithmArgs::Array{Any}

    ExperimentInfo() = new()
end # struct



include("tools/stopCondition.jl")
include("tools/evaluator.jl")
include("tools/initialization.jl")
include("tools/selector.jl")
include("tools/crossover.jl")
include("tools/mutation.jl")
include("tools/replacement.jl")



"
Main structure of the system, gathers all the tools necessary to run a
population-based algorithm. By default, the main structure for `code users` is
called `GenJ`.

# Fields
- `_experimentInfo::ExperimentInfo`: auxiliary structure that keeps some generic
    information for experiments.
- `_stopCondition::StopCondition`: tool that defines the stop conditions and
    checks them throughout the experiment.
- `_population::Array{Individual}`: array that stores the population as Individual.
- `_evaluator::Evaluator`: defines the methods and structure for evaluate individuals.
- `_generator::Generator`: defines the methods and structure for generate individuals.
- `_selector::SelectionOperator`: defines the methods and structure for select
    \"parents\" among the population.
- `_crossoverOp::CrossoverOperator`: defines the methods and structure for cross
    \"parents\" and obtain the offspring.
- `_mutationOp::MutationOperator`: defines the methods and structure for mutate
    an offspring's individual.
- `_replacementOp::ReplacementOperator`: defines the methods and structure for
    replace the old population with the offspring.
"
mutable struct GeneticJuliaStructure
    _experimentInfo::ExperimentInfo
    _stopCondition::StopCondition
    _population::Array{Individual}
    _evaluator::Evaluator
    _generator::Generator
    _selector::SelectionOperator
    _crossoverOp::CrossoverOperator
    _mutationOp::MutationOperator
    _replacementOp::ReplacementOperator

    GeneticJuliaStructure() = new()
end # struct


# Global structure generation for code user transparency.
GenJ = GeneticJuliaStructure()

# Due to optional options, it is created here.
GenJ._experimentInfo = ExperimentInfo()
GenJ._experimentInfo._randomSeed = 1234
GenJ._experimentInfo._rng = Random.GLOBAL_RNG

include("utils/GeneticProgramming/includes.jl")
include("utils/GeneticAlgorithms/includes.jl")
include("utils/algorithms.jl")
include("utils/defaultSettings.jl")
include("utils/error.jl")
include("utils/parser.jl")
include("utils/verboseFunctions.jl")
include("interface/includes.jl")



"""
    getIndividualType(experimentInfo::ExperimentInfo)

Gets the individual type of the main structure.
"""
getIndividualType(experimentInfo::ExperimentInfo) = experimentInfo._individualType
 # function

"""
    getIndividualType(genj::GeneticJulia)

Gets the individual type of the main structure.
"""
getIndividualType(genj::GeneticJuliaStructure) = getIndividualType(genj._experimentInfo)
 # function



"""
    setIndividualType(type::DataType; genj::GeneticJulia = GenJ)

Sets the type of the individuals' representation for the experiment.

# Arguments
- `type::DataType`: data type of the individuals of the experiment. Should be
    one of the implemented ones (see [`IndividualRep`](@ref)). The user could
    provide their own type, as long as they also provide their own methods for
    population generation, crossover and mutation.

# Keyword Arguments
- `genj::GeneticJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> setIndividualType(BinaryGenotype)
BinaryGenotype
```
"""
function setIndividualType(type::DataType; genj::GeneticJuliaStructure = GenJ)

    if findfirst(x->type <: x, [BinaryGenotype, IntegerGenotype, CGPGenotype,
                                          STGPGenotype, GEPGenotype, GEGenotype]) == nothing
        @warn "The individual type provided does not match any of the predefined
               ones. Personalized methods for generation, crossover and mutation
               shall be provided"
    end

    genj._experimentInfo._individualType = type
end # function



"""
    setAlgorithm(algorithm::Function, varArgs...; genj::GeneticJulia = GenJ)

Sets the genetic algorithm that is going to be run for the experiment.

# Arguments
- `algorithm::Function`: genetic algorithm that is going to run the experiment.
    By default, it is set to the classic one, which follows this steps:
    - Generation of the population.
    - Fitness evaluation.
    - Parent selection.
    - Crossover.
    - Mutation.
    - Fitness evaluation.
    - Replacement of the population.
- `varArgs`: arguments for the algorithm, if needed.

# Keyword Arguments
- `genj::GeneticJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> setAlgorithm(basicExperiment)
```
"""
function setAlgorithm(algorithm::Function, varArgs...; genj::GeneticJuliaStructure = GenJ)
    genj._experimentInfo._algorithm = algorithm
    varArgs = [i for i in varArgs]
    genj._experimentInfo._algorithmArgs = varArgs
end # function



"""
    setRandomSeed(seed::UInt; genj::GeneticJulia = GenJ)

Sets the random number generator as a MersenneTwister generator initialized with
the specified seed.

# Arguments
- `seed::Integer`: seed to initialize the random number generator with.

# Keyword Arguments
- `genj::GeneticJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> setRandomSeed(2)
```
"""
function setRandomSeed(seed::Integer; genj::GeneticJuliaStructure = GenJ)
    if seed < 0
        error("RandomSeed ($seed) must be a positive integer")
    end
    genj._experimentInfo._randomSeed = convert(UInt, seed)
    genj._experimentInfo._rng = Random.MersenneTwister(seed)
end # function



"""
    getRNG(experimentInfo::ExperimentInfo)

Gets the individual type of the main structure.
"""
getRNG(experimentInfo::ExperimentInfo) = experimentInfo._rng
 # function


"""
    getRNG(genj::GeneticJulia)

Gets the random number generator of the main structure.
"""
getRNG(genj::GeneticJuliaStructure) = getRNG(genj._experimentInfo)
# function



"""
    setRNG(rng::Random.AbstractRNG; genj::GeneticJulia = GenJ)

Sets the random number generator for the system to run the experiment.

# Arguments
- `seed::Integer`: seed to initialize the random number generator with.

# Keyword Arguments
- `genj::GeneticJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> rng = Random.MersenneTwister()

julia> setRNG(rng)
```
"""
function setRNG(rng::Random.AbstractRNG; genj::GeneticJuliaStructure = GenJ)
    genj._experimentInfo._rng = rng
end # function



"""
    runGenJ(jsonFile::String; verbose::Bool = true, outputFile::String = "")

Runs the experiments specified in the configuration file.

# Arguments
- `configFile::String`: the configuration file (in JSON format) with all the information about the
    experiments that are going to be run.

# Keyword Arguments
- `verbose::Bool = true`: specifies wether information about the experiment is going
    to be displayed or not.
- `outputFile::String = ""`: specifies the output stream in which the information
    displayed by verbose is going to be dumped.

# Returns
The array of experiments run.

For guidance about how to create the information file about the experiments
visit our GitHub repository at:
[https://github.com/SergioGmezM/Evolutionary\\_Computation\\_Julia](https://github.com/SergioGmezM/Evolutionary_Computation_Julia)
"""
function runGenJ(configFile::String; verbose::Bool = true, outputFile::String = "")
    experiments = generateMainStructure(configFile)
    nExperiments = length(experiments)

    if !verbose
        verbose = outputFile != ""
    end

    for i=1:nExperiments
        # Sets the default settings according to the individual type provided in the experiment
        setDefaultSettings(genj=experiments[i], i=i)
        # Checks that all has been set
        checkParametersDefined(experiments[i], i)
        # Checks that all has been set correctly
        checkParametersCorrect(experiments[i], i)
    end

    for i=1:nExperiments
        println("Experiment $i \n==========================")
        # Prints the information about the experiment
        verbose && printExperimentInfo(outputFile, experiments[i])
        # Runs the experiment
        experiments[i]._experimentInfo._algorithm(experiments[i]._experimentInfo._algorithmArgs..., genj=experiments[i])
    end

    return experiments
end # function



"""
    runGenJ(genj::GeneticJulia = GenJ; verbose::Bool = true, outputFile::String = "")

Runs a single experiment for `code users`.

# Arguments
- `genj::GeneticJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Keyword Arguments
- `verbose::Bool = true`: specifies wether information about the experiment is going
    to be displayed or not.
- `outputFile::String = ""`: specifies the output stream in which the information
    displayed by verbose is going to be dumped.

For guidance about how to create the information file about the experiments
visit our GitHub repository at:
[https://github.com/SergioGmezM/Evolutionary\\_Computation\\_Julia](https://github.com/SergioGmezM/Evolutionary_Computation_Julia)
"""
function runGenJ(genj::GeneticJuliaStructure = GenJ; verbose::Bool = true, outputFile::String = "")

    if !verbose
        verbose = outputFile != ""
    end

    # Sets the default settings according to the individual type provided in the experiment
    setDefaultSettings(genj=genj)
    # Checks that all has been set
    checkParametersDefined(genj)
    # Checks that all has been set correctly
    checkParametersCorrect(genj)
    # Prints the information about the experiment
    verbose && printExperimentInfo(outputFile, genj)
    # Runs the experiment
    genj._experimentInfo._algorithm(genj._experimentInfo._algorithmArgs..., genj=GenJ)
end # function
