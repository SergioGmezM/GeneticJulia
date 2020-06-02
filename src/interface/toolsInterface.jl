"""
    genPopulation!(genj::GeneticJuliaStructure)

Generates the initial population if it has not been previously generated. If it
has already been generated from a previous experiment, it does nothing. This is
to continue evolving a previously evolved population.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which specified the generation method
    and its arguments, if any.

See also: [`setGenerator`](@ref)
"""
function genPopulation!(genj::GeneticJuliaStructure)
    if !isdefined(genj, :_population)
        genj._population = genPopulation_(genj._generator, genj._experimentInfo)
    end
end # function



"""
    evaluate!(genj::GeneticJuliaStructure, population::Array{Individual})

Evaluates the fitness of the individuals of a population and sets their values.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which contains the Evaluator that
    specifies the fitness functions to evaluate for each individual.
- `population::Array{Individual}`: the population that is going to be evaluated.

See also: [`setEvaluator`](@ref)
"""
function evaluate!(genj::GeneticJuliaStructure, population::Array{Individual})
    evaluate!_(genj._evaluator, genj._experimentInfo, population, genj._stopCondition)
end # function



"""
    selectParents(genj::GeneticJuliaStructure)

Selects a set of individuals of the population.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which specifies the selection method,
    its arguments, if any, and the number of individuals to select.

# Returns
The set of selected individuals.

See also: [`setSelector`](@ref)
"""
function selectParents(genj::GeneticJuliaStructure)
    selectParents_(genj._selector, genj._population, genj._evaluator, genj._experimentInfo._rng)
end # function



"""
    selectParents(genj::GeneticJuliaStructure, population::Array{Individual})

Selects a set of individuals of a population.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which specifies the selection method,
    its arguments, if any, and the number of individuals to select.
- `population::Array{Individual}`: the population from which individuals are
    going to be selected.

# Returns
The set of selected individuals.

See also: [`setSelector`](@ref)
"""
function selectParents(genj::GeneticJuliaStructure, population::Array{Individual})
    selectParents_(genj._selector, population, genj._evaluator, genj._experimentInfo._rng)
end # function



"""
    cross(genj::GeneticJuliaStructure, selected::Array{Individual})

Performs a crossover method between a set of selected individuals. If crossover
probability is set to 0, it returns the selected individuals unchanged.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which specifies the crossover method,
    its arguments, if any, the number of parents it takes and the number of children
    it returns.
- `selected::Array{Individual}`: the selected individuals that are going to
    be crossed one another.

# Returns
The offspring after crossing the selected individuals. The selected individuals
unchanged if crossover probability equals 0.

See also: [`setCrossoverOperator`](@ref)
"""
function cross(genj::GeneticJuliaStructure, selected::Array{Individual})
    if genj._crossoverOp._probability > 0.0
        return cross_(genj._crossoverOp, selected, genj._experimentInfo)
    else
        return selected
    end
end # function



"""
    cross(genj::GeneticJuliaStructure, selected::Array{Individual})

Performs a mutation method over a set of selected individuals. If mutation
probability is set to 0, it returns the selected individuals unchanged.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which specifies the mutation method
    and its arguments, if any.
- `selected::Array{Individual}`: the selected individuals that are going to
    be mutated.

# Returns
The mutated offspring. The selected individuals unchanged if mutation
probability equals 0.

See also: [`setMutationOperator`](@ref)
"""
function mutate(genj::GeneticJuliaStructure, offspring::Array{Individual})
    if genj._mutationOp._probability > 0.0
        mutate_(genj._mutationOp, offspring, genj._experimentInfo)
    else
        return offspring
    end
end # function



"""
    replacePopulation!(genj::GeneticJuliaStructure, offspring::Array{Individual})

Replaces the population selecting individuals from the current population and its
offspring according to a criterium.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which specifies the replacement method
    and its arguments, if any.
- `offspring::Array{Individual}`: the individuals that resulted from crossover and
    mutation operations.

See also: [`setReplacementOperator`](@ref)
"""
function replacePopulation!(genj::GeneticJuliaStructure, offspring::Array{Individual})
    genj._population = replacePopulation_(genj._replacementOp, genj._population,
        offspring, genj._evaluator, genj._experimentInfo._rng)
end # function



"""
    reached(genj::GeneticJuliaStructure)

Checks if any of the stop conditions has been fulfilled.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which contains the stop conditions.

# Returns
`true` if any of the stop conditions has been fulfilled, `false` otherwise.

See also: [`setStopCondition`](@ref)
"""
function reached(genj::GeneticJuliaStructure)

    if genj._stopCondition._maxIterations != -1
        notifyIteration(genj._stopCondition)
    end

    if genj._stopCondition._maxIterNotImproving != -1
        currentBestFitness = genj._population[getBestIndividual(genj._population, genj._evaluator._compareFunction)]

        if !genj._evaluator._compareFunction(currentBestFitness, GenJ._stopCondition._bestFitness)
            notifyIterNotImproving(genj._stopCondition)
        else
            genj._stopCondition._bestFitness = currentBestFitness
            resetIterNotImproving(genj._stopCondition)
        end
    end

    reached_(genj._stopCondition)
end # function



"""
    initTime(genj::GeneticJuliaStructure)

Initiates the timer.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure, which contains the time as a stop condition.

See also: [`setStopCondition`](@ref), [`reached`](@ref)
"""
function initTime(genj::GeneticJuliaStructure)
    if genj._stopCondition._maxTime != Inf
        setTime(genj._stopCondition, time())
    end
end # function



"""
    initBestFitness(genj::GeneticJuliaStructure)

Sets the best fitness of the current population.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure.

See also: [`setStopCondition`](@ref), [`reached`](@ref)
"""
function initBestFitness(genj::GeneticJuliaStructure)
    if genj._stopCondition._maxIterNotImproving != -1
        fitnesses = getFitness(genj._population)
        genj._stopCondition._bestFitness = fitnesses[getBestIndividual(genj._population, genj._evaluator._compareFunction)]
    end
end # function



"""
    getBestIndividual(genj::GeneticJuliaStructure, n::Integer = 1)

Returns the indexes of the best individuals of the population.

# Arguments
- `genj::GeneticJuliaStructure`: the main structure.
- `n::Integer = 1`: number of best individuals to be returned.
"""
function getBestIndividual(genj::GeneticJuliaStructure, n::Integer = 1)
    return getBestIndividual(genj._population, genj._evaluator._compareFunction, n)
end # function



"""
    printInformation(genj::GeneticJuliaStructure; printFitness::Bool = true,
                     printBestFitness::Bool = true, printMeanFitness::Bool = true,
                     printSTDFitness::Bool = true)

Prints all the information of the experiment.
"""
function printInformation(genj::GeneticJuliaStructure; printFitness::Bool = true,
                          printBestFitness::Bool = true, printMeanFitness::Bool = true,
                          printSTDFitness::Bool = true, outputFile::String = "")
    if isdefined(genj._experimentInfo, :_experimentSummary)
        if hasGlobalFitnessFunction(genj._evaluator)
            printInformationWithGlobal_(genj._experimentInfo._experimentSummary, printFitness=printFitness,
                                        printBestFitness=printBestFitness, printMeanFitness=printMeanFitness,
                                        printSTDFitness=printSTDFitness, outputFile=outputFile)
        else
            printInformation_(genj._experimentInfo._experimentSummary, printFitness=printFitness,
                              printBestFitness=printBestFitness, printMeanFitness=printMeanFitness,
                              printSTDFitness=printSTDFitness, outputFile=outputFile)
        end
    else
        error("The experiment has not been set with an information summary (See \"setExperimentSummary\")")
    end

    return nothing
end # function



"""
    printLastInformation(genj::GeneticJuliaStructure)

Prints the last bit of information collected of the experiment.
"""
function printLastInformation(genj::GeneticJuliaStructure, currGen::Integer = 0)
    if currGen == 0
        currGen = getCurrentIteration(genj._stopCondition)
    end
    if hasGlobalFitnessFunction(genj._evaluator)
        printLastInformationWithGlobal_(genj._experimentInfo._experimentSummary, currGen)
    else
        printLastInformation_(genj._experimentInfo._experimentSummary, currGen)
    end

    return nothing
end # function



"""
    saveResults(genj::GeneticJuliaStructure)

documentation
"""
function saveResults(genj::GeneticJuliaStructure)
    if isdefined(genj._experimentInfo, :_experimentSummary)
        batchSize = getBatchSize(genj._experimentInfo._experimentSummary)
        currIter = getCurrentIteration(genj._stopCondition)

        if batchSize == 0 && reached_(genj._stopCondition) || currIter%batchSize == 0
            if displayFitness(genj._experimentInfo._experimentSummary)
                if hasGlobalFitnessFunction(genj._evaluator)
                    saveFitness(genj._experimentInfo._experimentSummary,
                                getFitness(genj._population),
                                currIter, getGlobalFitness(genj._population))
                else
                    saveFitness(genj._experimentInfo._experimentSummary,
                                getFitness(genj._population),
                                currIter)
                end
            end

            if displayBestFitness(genj._experimentInfo._experimentSummary)
                bestIndividual = genj._population[getBestIndividual(genj)[1]]
                bestFitness = getFitness(bestIndividual, all=true)
                bestGenotype = getGenotype(bestIndividual)

                if typeof(bestGenotype) <: GAGenotype
                    bestRep = getRepresentation(bestGenotype)
                elseif typeof(bestGenotype) <: GEGenotype
                    bestRep = getPhenotype(genj._experimentInfo._gpExperimentInfo._grammar, bestGenotype)
                else
                    bestRep = getPhenotype(bestGenotype)
                end

                if hasGlobalFitnessFunction(genj._evaluator)
                    saveBestFitness(genj._experimentInfo._experimentSummary,
                                    bestFitness, bestRep,
                                    currIter, getGlobalFitness(bestIndividual))
                else
                    saveBestFitness(genj._experimentInfo._experimentSummary,
                                    bestFitness, bestRep,
                                    currIter)
                end
            end

            if displayMeanFitness(genj._experimentInfo._experimentSummary)
                if hasGlobalFitnessFunction(genj._evaluator)
                    saveMeanFitness(genj._experimentInfo._experimentSummary,
                                    getFitness(genj._population),
                                    currIter, getGlobalFitness(genj._population))
                else
                    saveMeanFitness(genj._experimentInfo._experimentSummary,
                                    getFitness(genj._population),
                                    currIter)
                end
            end

            if displaySTDFitness(genj._experimentInfo._experimentSummary)
                if hasGlobalFitnessFunction(genj._evaluator)
                    saveSTDFitness(genj._experimentInfo._experimentSummary,
                                    getFitness(genj._population),
                                    currIter, getGlobalFitness(genj._population))
                else
                    saveSTDFitness(genj._experimentInfo._experimentSummary,
                                    getFitness(genj._population),
                                    currIter)
                end
            end

            if printDuringExperiment(genj._experimentInfo._experimentSummary)
                outputFile = getOutputFile(genj._experimentInfo._experimentSummary)
                io = outputFile != "" ? open(outputFile, "a") : Base.stdout
                flush(io)

                println(io, "GENERATION ", currIter, ":")
                println(io)
                io == Base.stdout || close(io)

                printLastInformation(genj, currIter)

                println(io, "============================")
                println(io)
                println(io)

                io == Base.stdout || close(io)
            end
        end
    end

    return nothing
end # function
