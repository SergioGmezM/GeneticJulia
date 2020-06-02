"""
    setExperimentSummary(genj::GeneticJuliaStructure = GenJ; batchSize::UInt16 = -1)

documentation
"""
function setExperimentSummary(genj::GeneticJuliaStructure = GenJ; batchSize::Integer = 0,
                              displayFitness::Bool = true, displayBestFitness::Bool = true,
                              displayFitnessMean::Bool = true, displayFitnessSTD::Bool = true,
                              printDuringExperiment::Bool = false, outputFile::String = "")

    if batchSize < 0
        GenJ._experimentInfo._experimentSummary = ExperimentSummary(outputFile,
                                                                    -1, false,
                                                                    Array{Float64}(undef, 0),
                                                                    Array{Float64}(undef, 0),
                                                                    Array{Float64}(undef, 0),
                                                                    Array{Float64}(undef, 0),
                                                                    Array{Any}(undef, 0))
    else
        if !(isdefined(genj, :_generator))
            error("Generator must be defined first")
        elseif !(isdefined(genj, :_evaluator))
            error("Evaluator must be defined first")
        elseif !(isdefined(genj, :_stopCondition))
            error("StopCondition must be defined first")
        end

        popSize = getPopSize(genj._generator)
        nFitness = getNumberFitness(genj._evaluator)
        maxIter = getMaxIterations(genj._stopCondition)

        if batchSize == 0
            batchSize = maxIter
        end

        intDiv = div(maxIter, batchSize)

        # Using column-first order for higher performance
        if displayFitness
            if hasGlobalFitnessFunction(genj._evaluator)
                fitnessValues = Array{Float64}(undef, (nFitness+1, popSize, intDiv))
            else
                fitnessValues = Array{Float64}(undef, (nFitness, popSize, intDiv))
            end
        else
            fitnessValues = Array{Float64}(undef, 0)
        end

        if displayBestFitness
            if hasGlobalFitnessFunction(genj._evaluator)
                bestFitnessValues = Array{Float64}(undef, (nFitness+1, intDiv))
            else
                bestFitnessValues = Array{Float64}(undef, (nFitness, intDiv))
            end
            bestIndividuals = Array{Any}(undef, intDiv)
        else
            bestFitnessValues = Array{Float64}(undef, 0)
            bestIndividuals = Array{Any}(undef, 0)
        end

        if displayFitnessMean
            if hasGlobalFitnessFunction(genj._evaluator)
                meanFitness = Array{Float64}(undef, (nFitness+1, intDiv))
            else
                meanFitness = Array{Float64}(undef, (nFitness, intDiv))
            end
        else
            meanFitness = Array{Float64}(undef, 0)
        end

        if displayFitnessSTD
            if hasGlobalFitnessFunction(genj._evaluator)
                stdFitness = Array{Float64}(undef, (nFitness+1, intDiv))
            else
                stdFitness = Array{Float64}(undef, (nFitness, intDiv))
            end
        else
            stdFitness = Array{Float64}(undef, 0)
        end

        GenJ._experimentInfo._experimentSummary = ExperimentSummary(outputFile,
                                                                    batchSize,
                                                                    printDuringExperiment,
                                                                    fitnessValues,
                                                                    bestFitnessValues,
                                                                    meanFitness,
                                                                    stdFitness,
                                                                    bestIndividuals)
    end

    return nothing
end # function



"""
    printInformation_(summary::ExperimentSummary)

Prints all the information in the summary.
"""
function printInformation_(summary::ExperimentSummary; printFitness::Bool = true,
                           printBestFitness::Bool = true, printMeanFitness::Bool = true,
                           printSTDFitness::Bool = true, outputFile::String = "")
    if somethingToDisplay(summary) && (printFitness || printBestFitness ||
        printMeanFitness || printSTDFitness)

        if outputFile == ""
            outputFile = getOutputFile(summary)
        elseif outputFile == "Base.stdout"
            outputFile = ""
        end
        io = outputFile != "" ? open(outputFile, "a") : Base.stdout
        flush(io)

        batchSize = getBatchSize(summary)
        anyDisplayable = displayAnything(summary)
        nGens = axes(anyDisplayable)[end]

        for gen = nGens
            println(io, "GENERATION ", batchSize * gen, ":")
            println(io)

            if displayFitness(summary) && printFitness
                println(io, "  RESULTS OF ALL THE INDIVIDUALS")
                println(io, "  ------------------------------")
                for ind = eachindex(view(summary._fitnessValues, 1, :, 1))
                    println(io, "\tIndividual ", ind, ":")
                    for fit = eachindex(view(summary._fitnessValues, :, 1, 1))
                        println(io, "\t  Fitness Value ", fit, ": ", summary._fitnessValues[fit, ind, gen])
                    end
                    println(io)
                end
                println(io)
            end

            if displayBestFitness(summary) && printBestFitness
                println(io, "  RESULTS OF THE BEST INDIVIDUAL")
                println(io, "  ------------------------------")
                for fit = eachindex(view(summary._bestFitnessValues, :, 1))
                    println(io, "\tFitness ", fit, " of the Best Individual: ", summary._bestFitnessValues[fit, gen])
                end
                println(io, "\tBest Individual: ", summary._bestIndividuals[gen])
                println(io)
            end

            if displayMeanFitness(summary) && printMeanFitness
                println(io, "  MEAN OF THE RESULTS")
                println(io, "  -------------------")
                for fit = eachindex(view(summary._meanFitness, :, 1))
                    println(io, "\tMean of Fitness ", fit, ": ", summary._meanFitness[fit, gen])
                end
                println(io)
            end

            if displayBestFitness(summary) && printSTDFitness
                println(io, "  STANDARD DEVIATION OF THE RESULTS")
                println(io, "  ---------------------------------")
                for fit = eachindex(view(summary._stdFitness, :, 1))
                    println(io, "\tStandard Deviation of Fitness ", fit, ": ", summary._stdFitness[fit, gen])
                end
                println(io)
            end

            println(io, "============================")
            println(io)
            println(io)

            io == Base.stdout || close(io)
        end
    elseif !(somethingToDisplay(summary))
        println("Nothing to display! Set the information that you want to display by calling setExperimentSummary function")
    else
        println("Nothing to display!")
    end

    return nothing
end # function



"""
    printInformation_(summary::ExperimentSummary)

Prints all the information in the summary.
"""
function printInformationWithGlobal_(summary::ExperimentSummary; printFitness::Bool = true,
                                     printBestFitness::Bool = true, printMeanFitness::Bool = true,
                                     printSTDFitness::Bool = true, outputFile::String = "")
    if somethingToDisplay(summary) && (printFitness || printBestFitness ||
        printMeanFitness || printSTDFitness)

        if outputFile == ""
            outputFile = getOutputFile(summary)
        elseif outputFile == "Base.stdout"
            outputFile = ""
        end
        io = outputFile != "" ? open(outputFile, "a") : Base.stdout
        flush(io)

        batchSize = getBatchSize(summary)
        anyDisplayable = displayAnything(summary)
        nGens = axes(anyDisplayable)[end]

        for gen = nGens
            println(io, "GENERATION ", batchSize * gen, ":")
            println(io)

            if displayFitness(summary) && printFitness
                println(io, "  RESULTS OF ALL THE INDIVIDUALS")
                println(io, "  ------------------------------")
                for ind = eachindex(view(summary._fitnessValues, 1, :, 1))
                    println(io, "\tIndividual ", ind, ":")
                    for fit = eachindex(view(summary._fitnessValues, :, 1, 1))
                        if fit != lastindex(view(summary._fitnessValues, :, 1, 1))
                            println(io, "\t  Fitness Value ", fit, ": ", summary._fitnessValues[fit, ind, gen])
                        else
                            println(io, "\t  Global Fitness Value: ", summary._fitnessValues[fit, ind, gen])
                        end
                    end
                    println(io)
                end
                println(io)
            end

            if displayBestFitness(summary) && printBestFitness
                println(io, "  RESULTS OF THE BEST INDIVIDUAL")
                println(io, "  ------------------------------")
                for fit = eachindex(view(summary._bestFitnessValues, :, 1))
                    if fit != lastindex(view(summary._bestFitnessValues, :, 1))
                        println(io, "\tFitness Value ", fit, " of the Best Individual: ", summary._bestFitnessValues[fit, gen])
                    else
                        println(io, "\tGlobal Fitness Value of the Best Individual: ", summary._bestFitnessValues[fit, gen])
                    end
                end
                println(io, "\tBest Individual: ", summary._bestIndividuals[gen])
                println(io)
            end

            if displayMeanFitness(summary) && printMeanFitness
                println(io, "  MEAN OF THE RESULTS")
                println(io, "  -------------------")
                for fit = eachindex(view(summary._meanFitness, :, 1))
                    if fit != lastindex(view(summary._meanFitness, :, 1))
                        println(io, "\tMean of Fitness ", fit, ": ", summary._meanFitness[fit, gen])
                    else
                        println(io, "\tMean of Global Fitness: ", summary._meanFitness[fit, gen])
                    end
                end
                println(io)
            end

            if displayBestFitness(summary) && printSTDFitness
                println(io, "  STANDARD DEVIATION OF THE RESULTS")
                println(io, "  ---------------------------------")
                for fit = eachindex(view(summary._stdFitness, :, 1))
                    if fit != lastindex(view(summary._stdFitness, :, 1))
                        println(io, "\tStandard Deviation of Fitness ", fit, ": ", summary._stdFitness[fit, gen])
                    else
                        println(io, "\tStandard Deviation of Global Fitness: ", summary._stdFitness[fit, gen])
                    end
                end
                println(io)
            end

            println(io, "============================")
            println(io)
            println(io)

            io == Base.stdout || close(io)
        end
    elseif !(somethingToDisplay(summary))
        println("Nothing to display! Set the information that you want to display by calling setExperimentSummary function")
    else
        println("Nothing to display!")
    end

    return nothing
end # function



"""
    printLastInformation_(summary::ExperimentSummary)

Prints the last bit of information collected of the summary.
"""
function printLastInformation_(summary::ExperimentSummary, currGeneration::Integer)
    if somethingToDisplay(summary)

        outputFile = getOutputFile(summary)
        io = outputFile != "" ? open(outputFile, "a") : Base.stdout
        flush(io)
        currGeneration = div(currGeneration, getBatchSize(summary))

        if displayFitness(summary)
            println(io, "  RESULTS OF ALL THE INDIVIDUALS")
            println(io, "  ------------------------------")
            for ind = eachindex(view(summary._fitnessValues, 1, :, 1))
                println(io, "\tIndividual ", ind, ":")
                for fit = eachindex(view(summary._fitnessValues, :, 1, 1))
                    println(io, "\t  Fitness Value ", fit, ": ", summary._fitnessValues[fit, ind, currGeneration])
                end
                println(io)
            end
            println(io)
        end

        if displayBestFitness(summary)
            println(io, "  RESULTS OF THE BEST INDIVIDUAL")
            println(io, "  ------------------------------")
            for fit = eachindex(view(summary._bestFitnessValues, :, 1))
                println(io, "\tFitness Value ", fit, " of the Best Individual: ", summary._bestFitnessValues[fit, currGeneration])
            end
            println(io, "\tBest Individual: ", summary._bestIndividuals[currGeneration])
            println(io)
        end

        if displayMeanFitness(summary)
            println(io, "  MEAN OF THE RESULTS")
            println(io, "  -------------------")
            for fit = eachindex(view(summary._meanFitness, :, 1))
                println(io, "\tMean of Fitness ", fit, ": ", summary._meanFitness[fit, currGeneration])
            end
            println(io)
        end

        if displayBestFitness(summary)
            println(io, "  STANDARD DEVIATION OF THE RESULTS")
            println(io, "  ---------------------------------")
            for fit = eachindex(view(summary._stdFitness, :, 1))
                println(io, "\tStandard Deviation of Fitness ", fit, ": ", summary._stdFitness[fit, currGeneration])
            end
            println(io)
        end

        io == Base.stdout || close(io)
    end

    return nothing
end # function



"""
    printLastInformation_(summary::ExperimentSummary)

Prints the last bit of information collected of the summary.
"""
function printLastInformationWithGlobal_(summary::ExperimentSummary, currGeneration::Integer)
    if somethingToDisplay(summary)

        outputFile = getOutputFile(summary)
        io = outputFile != "" ? open(outputFile, "a") : Base.stdout
        flush(io)
        currGeneration = div(currGeneration, getBatchSize(summary))

        if displayFitness(summary)
            println(io, "  RESULTS OF ALL THE INDIVIDUALS")
            println(io, "  ------------------------------")
            for ind = eachindex(view(summary._fitnessValues, 1, :, 1))
                println(io, "\tIndividual ", ind, ":")
                for fit = eachindex(view(summary._fitnessValues, :, 1, 1))
                    if fit != lastindex(view(summary._fitnessValues, :, 1, 1))
                        println(io, "\t  Fitness Value ", fit, ": ", summary._fitnessValues[fit, ind, currGeneration])
                    else
                        println(io, "\t  Global Fitness Value: ", summary._fitnessValues[fit, ind, currGeneration])
                    end
                end
                println(io)
            end
            println(io)
        end

        if displayBestFitness(summary)
            println(io, "  RESULTS OF THE BEST INDIVIDUAL")
            println(io, "  ------------------------------")
            for fit = eachindex(view(summary._bestFitnessValues, :, 1))
                if fit != lastindex(view(summary._bestFitnessValues, :, 1))
                    println(io, "\tFitness Value", fit, " of the Best Individual: ", summary._bestFitnessValues[fit, currGeneration])
                else
                    println(io, "\tGlobal Fitness Value of the Best Individual: ", summary._bestFitnessValues[fit, currGeneration])
                end
            end
            println(io, "\tBest Individual: ", summary._bestIndividuals[currGeneration])
            println(io)
        end

        if displayMeanFitness(summary)
            println(io, "  MEAN OF THE RESULTS")
            println(io, "  -------------------")
            for fit = eachindex(view(summary._meanFitness, :, 1))
                if fit != lastindex(view(summary._meanFitness, :, 1))
                    println(io, "\tMean of Fitness ", fit, ": ", summary._meanFitness[fit, currGeneration])
                else
                    println(io, "\tMean of Global Fitness: ", summary._meanFitness[fit, currGeneration])
                end
            end
            println(io)
        end

        if displayBestFitness(summary)
            println(io, "  STANDARD DEVIATION OF THE RESULTS")
            println(io, "  ---------------------------------")
            for fit = eachindex(view(summary._stdFitness, :, 1))
                if fit != lastindex(view(summary._stdFitness, :, 1))
                    println(io, "\tStandard Deviation of Fitness ", fit, ": ", summary._stdFitness[fit, currGeneration])
                else
                    println(io, "\tStandard Deviation of Global Fitness: ", summary._stdFitness[fit, currGeneration])
                end
            end
            println(io)
        end

        io == Base.stdout || close(io)
    end

    return nothing
end # function
