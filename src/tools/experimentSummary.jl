struct ExperimentSummary
    _outputFile::String
    _batchSize::Int16
    _printDuringExperiment::Bool

    _fitnessValues::Array{Float64}
    _bestFitnessValues::Array{Float64}
    _meanFitness::Array{Float64}
    _stdFitness::Array{Float64}
    _bestIndividuals::Array{Any}
end # struct



"""
    getOutputFile(summary::ExperimentSummary)::String

Obtains the output file for the experiment summary.
"""
getOutputFile(summary::ExperimentSummary)::String = summary._outputFile
# function



"""
    getBatchSize(summary::ExperimentSummary)::Int16

Obtains the batch size for results collection.
"""
getBatchSize(summary::ExperimentSummary)::Int16 = summary._batchSize
# function



"""
    printDuringExperiment(summary::ExperimentSummary)::Bool

Checks if printing during the experiment is enabled.
"""
printDuringExperiment(summary::ExperimentSummary)::Bool = summary._printDuringExperiment
# function



"""
    displayFitness(summary::ExperimentSummary)

Checks if the user wants to display the fitness values of the individuals
throughout the generations.
"""
displayFitness(summary::ExperimentSummary) = !(isempty(summary._fitnessValues))
# function



"""
    displayBestFitness(summary::ExperimentSummary)

Checks if the user wants to display the best fitness values of the individuals
throughout the generations.
"""
displayBestFitness(summary::ExperimentSummary) = !(isempty(summary._bestFitnessValues))
# function



"""
    displayMeanFitness(summary::ExperimentSummary)

Checks if the user wants to display the mean of the fitness values of the individuals
throughout the generations.
"""
displayMeanFitness(summary::ExperimentSummary) = !(isempty(summary._meanFitness))
# function



"""
    displaySTDFitness(summary::ExperimentSummary)

Checks if the user wants to display the standard deviation of the fitness values
of the individuals throughout the generations.
"""
displaySTDFitness(summary::ExperimentSummary) = !(isempty(summary._stdFitness))
# function



"""
    somethingToDisplay(summary::ExperimentSummary)

Checks if there is something to display from the summary.
"""
function somethingToDisplay(summary::ExperimentSummary)
    return getBatchSize(summary) >= 0 && (displayFitness(summary) ||
           displayBestFitness(summary) || displayMeanFitness(summary) ||
           displaySTDFitness(summary))
end # function



"""
    anyToDisplay(summary::ExperimentSummary)

Returns the first thing that can be displayed.
"""
function displayAnything(summary::ExperimentSummary)
    if displayFitness(summary)
        return summary._fitnessValues
    elseif displayBestFitness(summary)
        return summary._bestFitnessValues
    elseif displayMeanFitness(summary)
        return summary._meanFitness
    elseif displaySTDFitness(summary)
        return summary._stdFitness
    end
end # function



"""
    saveFitness(summary::ExperimentSummary, fitnesses::Array{Float64},
                currIter::Int16)

Saves the fitness values of the individuals of a generation.
"""
function saveFitness(summary::ExperimentSummary, fitnesses::Array{Float64},
                     currIter::Int, globalFitnesses::Array{Float64} = Array{Float64}(undef, 0))

    index = div(currIter, getBatchSize(summary))

    if !(isempty(globalFitnesses))
        # CAMBIAR ESTO CUANDO SE MODIFIQUE LA ESTRUCTURA DE FILAS Y COLUMNAS DE LOS FITNESS
        # CAMBIARÍA A: summary._fitnessValues[:, i, index] = vcat(fitnesses[:, i], globalFitnesses[i])
        for i = eachindex(globalFitnesses)
            summary._fitnessValues[:, i, index] = vcat(fitnesses[i, :], globalFitnesses[i])
        end
    else
        # CAMBIAR ESTO CUANDO SE MODIFIQUE LA ESTRUCTURA DE FILAS Y COLUMNAS DE LOS FITNESS
        # CAMBIARÍA A: summary._fitnessValues[:, :, index] = fitnesses
        summary._fitnessValues[:, :, index] = transpose(fitnesses)
    end

    return nothing
end # function



"""
    saveBestFitness(summary::ExperimentSummary, fitnesses::Array{Float64},
                    currIter::Int16)

Saves the best fitness values of a generation.
"""
function saveBestFitness(summary::ExperimentSummary, bestFitness::Union{Array{Float64}, Float64},
                         representation::Union{Array, Expr}, currIter::Integer,
                         bestGlobalFitness::Float64 = NaN)

    index = div(currIter, getBatchSize(summary))
    if !(isnan(bestGlobalFitness))
        if length(axes(bestFitness)) == 0
            summary._bestFitnessValues[:, index] = [bestFitness, bestGlobalFitness]
        else
            #println(size(transpose(bestFitness)))
            #println(size([bestGlobalFitness]))
            summary._bestFitnessValues[:, index] = vcat(bestFitness, [bestGlobalFitness])
        end
    else
        if length(axes(bestFitness)) == 0
            summary._bestFitnessValues[:, index] .= bestFitness
        else
            # CAMBIAR ESTO CUANDO SE MODIFIQUE LA ESTRUCTURA DE FILAS Y COLUMNAS DE LOS FITNESS
            # CAMBIARÍA A: summary._fitnessValues[:, :, index] = fitnesses
            summary._bestFitnessValues[:, index] = transpose(bestFitness)
        end
    end

    summary._bestIndividuals[index] = representation

    return nothing
end # function



"""
    saveMeanFitness(summary::ExperimentSummary, fitnesses::Array{Float64},
                    currIter::Int16)

Saves the mean of fitness values of the individuals of a generation.
"""
function saveMeanFitness(summary::ExperimentSummary, fitness::Array{Float64},
                         currIter::Integer, globalFitnesses::Array{Float64} = Array{Float64}(undef, 0))

    index = div(currIter, getBatchSize(summary))
    # CAMBIAR ESTO CUANDO SE MODIFIQUE LA ESTRUCTURA DE FILAS Y COLUMNAS DE LOS FITNESS
    # CAMBIARÍA A: mean(fitness, dims=2)
    if !(isempty(globalFitnesses))
        if length(axes(fitness)) == 1
            summary._meanFitness[:, index] = [Statistics.mean(fitness), Statistics.mean(globalFitnesses)]
        else
            summary._meanFitness[:, index] = vcat(transpose(Statistics.mean(fitness, dims=1)), [Statistics.mean(globalFitnesses)])
        end
    else
        if length(axes(fitness)) == 1
            summary._meanFitness[:, index] .= Statistics.mean(fitness)
        else
            summary._meanFitness[:, index] = transpose(Statistics.mean(fitness, dims=1))
        end
    end

    return nothing
end # function



"""
    saveSTDFitness(summary::ExperimentSummary, fitnesses::Array{Float64},
                   currIter::Int16)

Saves the standard deviation of fitness values of the individuals of a generation.
"""
function saveSTDFitness(summary::ExperimentSummary, fitness::Array{Float64},
                        currIter::Integer, globalFitnesses::Array{Float64} = Array{Float64}(undef, 0))

    index = div(currIter, getBatchSize(summary))
    # CAMBIAR ESTO CUANDO SE MODIFIQUE LA ESTRUCTURA DE FILAS Y COLUMNAS DE LOS FITNESS
    # CAMBIARÍA A: std(fitness, dims=2)
    if !(isempty(globalFitnesses))
        if length(axes(fitness)) == 1
            if displayMeanFitness(summary)
                summary._stdFitness[:, index] = [Statistics.std(fitness,
                                                                mean=summary._meanFitness[1, index]),
                                                Statistics.std(globalFitnesses,
                                                                mean=summary._meanFitness[2, index])]
            else
                summary._stdFitness[:, index] = [Statistics.std(fitness),
                                                Statistics.std(globalFitnesses)]
            end
        else
            if displayMeanFitness(summary)
                summary._stdFitness[:, index] = vcat(transpose(Statistics.std(fitness,
                                                                              mean=summary._meanFitness[1:end-1, index],
                                                                              dims=1)),
                                                     Statistics.std(globalFitnesses,
                                                                    mean=summary._meanFitness[end:end, index],
                                                                    dims=1))
            else
                summary._stdFitness[:, index] = vcat(transpose(Statistics.std(fitness,
                                                                              dims=1)),
                                                     Statistics.std(globalFitnesses,
                                                                    dims=1))
            end
        end
    else
        if length(axes(fitness)) == 1
            if displayMeanFitness(summary)
                summary._stdFitness[:, index] .= Statistics.std(fitness,
                                                                mean=summary._meanFitness[1, index])
            else
                summary._stdFitness[:, index] .= Statistics.std(fitness)
            end
        else
            if displayMeanFitness(summary)
                summary._stdFitness[:, index] = transpose(Statistics.std(fitness,
                                                                         mean=summary._meanFitness[:, index],
                                                                         dims=1))
            else
                summary._stdFitness[:, index] = transpose(Statistics.std(fitness,
                                                                         dims=1))
            end
        end
    end

    return nothing
end # function
