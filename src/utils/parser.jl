"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseCGPInfo(GPInfoDict::Dict, experiment::GeneticJuliaStructure)
    nodesFile = get(GPInfoDict, "nodesFile", "")
    if !(typeof(nodesFile) <: String)
        error("nodesFile field must be a string with the path of the file containing the information about the nodes")
    end

    maxTreeDepth = get(GPInfoDict, "maxTreeDepth", false)
    if experiment._experimentInfo._individualType <: GAGenotype
        if maxTreeDepth != false
            @warn "Maximum tree depth set in a non Genetic Programming problem, maximum depth field will be dismissed"
        end
    elseif experiment._experimentInfo._individualType <: GPGenotype
        if maxTreeDepth != false
            if !(typeof(maxTreeDepth) <: Integer)
                error("Maximum tree depth must be an integer number greater than 0")
            end
        else
            @warn "Maximum tree depth not set in a Genetic Programming problem, maximum depth will be set to 3 by default"
            maxTreeDepth = 3
        end
    end

    setCGPInfo(nodesFile=nodesFile, maxTreeDepth=maxTreeDepth, genj=experiment)
end


"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseSTGPInfo(GPInfoDict::Dict, experiment::GeneticJuliaStructure)
    nodesFile = get(GPInfoDict, "nodesFile", "")
    if !(typeof(nodesFile) <: String)
        error("nodesFile field must be a string with the path of the file containing the information about the nodes")
    end

    maxTreeDepth = get(GPInfoDict, "maxTreeDepth", false)
    if experiment._experimentInfo._individualType <: GAGenotype
        if maxTreeDepth != false
            @warn "Maximum tree depth set in a non Genetic Programming problem, maximum depth field will be dismissed"
        end
    elseif experiment._experimentInfo._individualType <: GPGenotype
        if maxTreeDepth != false
            if !(typeof(maxTreeDepth) <: Integer)
                error("Maximum tree depth must be an integer number greater than 0")
            end
        else
            @warn "Maximum tree depth not set in a Genetic Programming problem, maximum depth will be set to 3 by default"
            maxTreeDepth = 3
        end
    end

    setSTGPInfo(nodesFile=nodesFile, maxTreeDepth=maxTreeDepth, genj=experiment)
end


"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseGEPInfo(GEPInfoDict::Dict, experiment::GeneticJuliaStructure)
    nodesFile = get(GEPInfoDict, "nodesFile", "")
    if !(typeof(nodesFile) <: String)
        error("nodesFile field must be a string with the path of the file containing the information about the nodes")
    end

    head = get(GEPInfoDict, "head", false)
    if experiment._experimentInfo._individualType <: GAGenotype
        if head != false
            @warn "head length set in a non Genetic Programming problem, head field will be dismissed"
        end
    elseif experiment._experimentInfo._individualType <: GPGenotype
        if head != false
            if !(typeof(head) <: Integer)
                error("head field must be an integer number greater than 0")
            end
        else
            @warn "head field not set in a GEP problem, head length will be set to 7 by default"
            head = 7
        end
    end

    setGEPInfo(nodesFile=nodesFile, head=head, genj=experiment)
end


"""
    parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseGPExperimentInfo(GPExperimentInfoDict::Dict, experiment::GeneticJuliaStructure)
    if experiment._experimentInfo._individualType <: GAGenotype
        @warn "Information about Genetic Programming problem has been given for a non-GP problem ($individualType), this information will be dismissed"
    elseif experiment._experimentInfo._individualType <: CGPGenotype
        parseCGPInfo(GPExperimentInfoDict, experiment)
    elseif experiment._experimentInfo._individualType <: STGPGenotype
        parseSTGPInfo(GPExperimentInfoDict, experiment)
    elseif experiment._experimentInfo._individualType <: GEPGenotype
        parseGEPInfo(GPExperimentInfoDict, experiment)
    #elseif experiment._experimentInfo._individualType <: GEGenotype
        #parseGEInfo(GPExperimentInfoDict, experiment)
    end
end # function



"""
    parseExperimentInfo(experimentInfo::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseExperimentInfo(experimentInfoDict::Dict, experiment::GeneticJuliaStructure)
    individualType = get(experimentInfoDict, "individualType", false)
    if individualType != false
        individualType = eval(Meta.parse(individualType))
        setIndividualType(individualType, genj=experiment)
    else
        error("individualType field in ExperimentInfo is mandatory and must be set")
    end

    gpExperimentInfoDict = get(experimentInfoDict, "GPExperimentInfo", false)
    if individualType <: GPGenotype && gpExperimentInfoDict == false
        @warn "Information about Genetic Programming problem has not been given for a GP problem ($individualType), this information must be specified in the 'GPExperimentInfo' field, default information will be used for the experiment (see setGPExperimentInfo documentation)"
        setGPExperimentInfo(genj=experiment)
    elseif individualType <: GPGenotype && gpExperimentInfoDict != false
        parseGPExperimentInfo(gpExperimentInfoDict, experiment)
    elseif gpExperimentInfoDict != false
        @warn "Information about Genetic Programming problem has been given for a non-GP problem ($individualType), this information will be dismissed"
    end

    randomSeed = get(experimentInfoDict, "randomSeed", false)
    if randomSeed != false
        if !(typeof(randomSeed) <: Integer) || randomSeed < 0
            error("Random seed must be an integer number greater or equal than 0")
        end
        setRandomSeed(randomSeed, genj=experiment)
    end

    rng = get(experimentInfoDict, "rng", false)
    if rng != false
        try
            aux = eval(Meta.parse(rng))
        catch e
            error("The following random number generator is not defined: '$rng'")
        end
        if typeof(aux) <: Random.AbstractRNG
            rng = aux
            setRNG(rng, genj=experiment)
        else
            error("The following random number generator is not a random number generator: '$rng'")
        end
    end

    if rng != false && randomSeed != false
        @warn "Random number generator and random seed have been provided, random seed will be dismissed"
    elseif rng == false && randomSeed == false
        setRNG(Random.GLOBAL_RNG, genj=experiment)
    end

    algorithm = get(experimentInfoDict, "algorithm", false)

    if algorithm == false
        algorithm = basicExperiment
    else
        aux = 0
        try
            aux = eval(Meta.parse(algorithm))
        catch e
            error("The following function of ExperimentInfo is not defined: '$algorithm'")
        end
        if typeof(aux) <: Function
            algorithm = aux
        else
            error("The following function of ExperimentInfo is not a function: '$algorithm'")
        end
    end

    varArgs = get(experimentInfoDict, "arguments", [])

    if !(typeof(varArgs) <: Array)
        varArgs = [varArgs]
    end

    setAlgorithm(algorithm, varArgs..., genj=experiment)
end # function


"""
    parseFitnessFunction(fitnessFunctionDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseFitnessFunction(fitnessFunctionDict::Dict, index::Integer)
    aux = 0

    fitnessFunction = get(fitnessFunctionDict, "function", false)
    if fitnessFunction == false
        error("No function specified for FitnessFunction dictionary number $index")
    end

    weight = get(fitnessFunctionDict, "weight", 1.0)
    if !(typeof(weight) <: Real)
        error("weight field in fitness function number $index must be a real number")
    end

    varArgs = get(fitnessFunctionDict, "arguments", [])

    if !(typeof(varArgs) <: Array)
        varArgs = [varArgs]
    end
    for i=1:length(varArgs)
        try
            arg = Meta.parse(varArgs[i])
            varArgs[i] = eval(arg)
        catch e
            # Empty
        end
    end

    try
        aux = eval(Meta.parse(fitnessFunction))
    catch e
        error("The following function of Evaluator is not defined in FitnessFunction dictionary number $index: '$(fitnessFunction)'")
    end
    if typeof(aux) <: Function
        fitnessFunction = aux
    else
        error("The following function of Evaluator is not a function in FitnessFunction dictionary number $index: '$(fitnessFunction)'")
    end

    return FitnessFunction(fitnessFunction, varArgs..., weight = weight)
end # function


"""
    parseEvaluator(evaluatorDict::Dict)

documentation
"""
function parseEvaluator(evaluatorDict::Dict, experiment::GeneticJuliaStructure)

    aux = 0

    globalFitnessFunction = get(evaluatorDict, "globalFitnessFunction", false)
    globalFitnessFunctionArgs = get(evaluatorDict, "globalFitnessFunctionArgs", [])

    if !(typeof(globalFitnessFunctionArgs) <: Array)
        globalFitnessFunctionArgs = [globalFitnessFunctionArgs]
    end

    if globalFitnessFunction != false
        try
            aux = eval(Meta.parse(globalFitnessFunction))
        catch e
            error("The following function of Evaluator is not defined: '$(globalFitnessFunction)'")
        end
        if typeof(aux) <: Function
            globalFitnessFunction = FitnessFunction(aux, globalFitnessFunctionArgs...)
        else
            error("The following function of Evaluator is not a function: '$(globalFitnessFunction)'")
        end
    else
        globalFitnessFunction = FitnessFunction(noFunc)
    end

    fitnessComparisonMode = get(evaluatorDict, "fitnessComparisonMode", "rawW")
    if !(typeof(fitnessComparisonMode) <: String)
        error("fitnessComparisonMode field in Evaluator must be a string: ($fitnessComparisonMode)")
    end

    fitnessFunctionsStrings = get(evaluatorDict, "fitnessFunctions", [])

    if !(typeof(fitnessFunctionsStrings) <: Array)
        fitnessFunctionsStrings = [fitnessFunctionsStrings]
    end

    lenFitnessFunctions = length(fitnessFunctionsStrings)
    if lenFitnessFunctions == 0
        error("A fitness function must be provided in JSON-> GeneticJuliaStructure-> Evaluator")
    end

    if typeof(fitnessFunctionsStrings[1]) <: Dict
        nFitnessFunctions = length(fitnessFunctionsStrings)
        fitnessFunctions = Array{FitnessFunction}(undef, nFitnessFunctions)
        for i=1:nFitnessFunctions
            fitnessFunctions[i] = parseFitnessFunction(fitnessFunctionsStrings[i]["FitnessFunction"], i)
        end

        setEvaluator(fitnessFunctions, genj=experiment, globalFitnessFunction=globalFitnessFunction, compareFunctionArgs=fitnessComparisonMode)
    else
        weights = Array{Real}(undef,1)
        weightsNumber = get(evaluatorDict, "weights", [])

        if !(typeof(weightsNumber) <: Array)
            weightsNumber = [weightsNumber]
        end
        try
            weights = convert(Array{Real}, weightsNumber)
        catch e
            if isa(e, MethodError)
                error("weights field must be an array of numbers")
            end
        end

        fitnessFunctions = Array{Function}(undef, lenFitnessFunctions)

        for i=1:lenFitnessFunctions
            try
                aux = eval(Meta.parse(fitnessFunctionsStrings[i]))
            catch e
                error("The following function of Evaluator is not defined: '$(fitnessFunctionsStrings[i])'")
            end
            if typeof(aux) <: Function
                fitnessFunctions[i] = aux
            else
                error("The following function of Evaluator is not a function: '$(fitnessFunctionsStrings[i])'")
            end
        end

        lenWeights = length(weights)

        if lenWeights != 0 && lenWeights != lenFitnessFunctions
            error("If weights are provided, they must be in the same amount as fitness functions")
        end

        if lenWeights == 0
            setEvaluator(fitnessFunctions, genj=experiment,
                         globalFitnessFunction=globalFitnessFunction,
                         compareFunctionArgs=fitnessComparisonMode)
        else
            setEvaluator(fitnessFunctions, weights, genj=experiment,
                         globalFitnessFunction=globalFitnessFunction,
                         compareFunctionArgs=fitnessComparisonMode)
        end
    end
end # function


"""
    parseGenerator(generatorDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseGenerator(generatorDict::Dict, experiment::GeneticJuliaStructure)
    popSize = get(generatorDict, "popSize", 100)
    if !(typeof(popSize) <: Integer)
        error("popSize field ($popSize) must be an integer number")
    end

    method = get(generatorDict, "method", false)
    if method == false
        error("Generation method must always be provided")
    end

    generateOneByOne = get(generatorDict, "generateOneByOne", true)
    if generateOneByOne == 1
        generateOneByOne = true
    elseif generateOneByOne == 0
        generateOneByOne = false
    end
    if !(typeof(generateOneByOne) <: Bool)
        error("generateOneByOne field must be boolean, true if generation method creates individuals one by one or false if it generates the whole population")
    end

    aux = 0
    try
        aux = eval(Meta.parse(method))
    catch e
        error("The following function of Generator: '$method', is not defined")
    end
    if typeof(aux) <: Function
        method = aux
    else
        error("The following function of Generator: '$method', is not a function")
    end

    varArgs = get(generatorDict, "arguments", [])

    if !(typeof(varArgs) <: Array)
        varArgs = [varArgs]
    end

    setGenerator(method, varArgs..., genj=experiment, popSize=popSize, generateOneByOne=generateOneByOne)
end # function


"""
    parseSelector(selectorDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseSelector(selectorDict::Dict, experiment::GeneticJuliaStructure)

    method = get(selectorDict, "method", false)
    if method == false
        aux = getDefaultSelector()
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for selection has not been provided, functionArgs or individualMode introduced will be dismissed, '$method' will be the default selection method"

        nSelected = get(selectorDict, "nSelected", 1.0)

        if !(typeof(nSelected) <: Real)
            error("nSelected field ($nSelected) must be a number")
        end

        samplingWithRep = get(selectorDict, "samplingWithRep", true)

        if samplingWithRep == 1
            samplingWithRep = true
        elseif samplingWithRep == 0
            samplingWithRep = false
        end

        if !(typeof(samplingWithRep) <: Bool)
            error("samplingWithRep field in Selector must be boolean")
        end

        setSelector(method,varArgs..., genj=experiment, nSelected=nSelected,
                    samplingWithRep=samplingWithRep)
    else
        aux = 0
        try
            aux = eval(Meta.parse(method))
        catch e
            error("The following function of Selector: '$method', is not defined")
        end
        if typeof(aux) <: Function
            method = aux
        else
            error("The following function of Selector: '$method', is not a function")
        end

        nSelected = get(selectorDict, "nSelected", 1.0)

        if !(typeof(nSelected) <: Real)
            error("nSelected field ($nSelected) must be a number")
        end

        needsComparison = get(selectorDict, "needsComparison", true)

        if needsComparison == 1
            needsComparison = true
        elseif needsComparison == 0
            needsComparison = false
        end

        if !(typeof(needsComparison) <: Bool)
            error("needsComparison field in Selector must be boolean")
        end

        individualMode = get(selectorDict, "individualMode", "fitness")

        if !(typeof(individualMode) <: String)
            error("individualMode field in Selector ($individualMode) must be a string")
        end

        samplingWithRep = get(selectorDict, "samplingWithRep", true)

        if samplingWithRep == 1
            samplingWithRep = true
        elseif samplingWithRep == 0
            samplingWithRep = false
        end

        if !(typeof(samplingWithRep) <: Bool)
            error("samplingWithRep field in Selector must be boolean")
        end

        varArgs = get(selectorDict, "arguments", [])

        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end

        setSelector(method, varArgs..., genj=experiment, nSelected=nSelected,
                    needsComparison=needsComparison, samplingWithRep=samplingWithRep)
    end
end # function


"""
    parseCrossover(crossoverDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseCrossover(crossoverDict::Dict, experiment::GeneticJuliaStructure)

    method = get(crossoverDict, "method", false)
    if method == false
        type = experiment._experimentInfo._individualType
        if !isdefined(experiment._experimentInfo, :_individualType) || !isPredefinedType(type)
            error("Either a crossover method or one of the predefined types(BinaryGA, IntegerGA, CanonicalGP) must be provided. The predefined types can be set in individualType field.")
        end
        aux = getDefaultCrossoverOp(type)
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for crossover has not been provided, functionArgs introduced will be dismissed, '$method' will be the default crossover method"

        probability = get(crossoverDict, "probability", 0.7)

        if !(typeof(probability) <: AbstractFloat)
            error("probability field ($probability) must be a floating point number")
        end

        nParents = get(crossoverDict, "nParents", 2)

        if !(typeof(nParents) <: Integer)
            error("nParents field ($nParents) must be an integer number")
        end

        nChildren = get(crossoverDict, "nChildren", -1)

        if !(typeof(nChildren) <: Integer)
            error("nChildren field ($nChildren) must be an integer number")
        end

        setCrossoverOperator(method, varArgs..., genj=experiment, probability=probability, nParents=nParents, nChildren=nChildren)

    else
        aux = 0
        try
            aux = eval(Meta.parse(method))
        catch e
            error("The following function of Crossover: '$method', is not defined")
        end
        if typeof(aux) <: Function
            method = aux
        else
            error("The following function of Crossover: '$method', is not a function")
        end

        probability = get(crossoverDict, "probability", 0.7)

        if !(typeof(probability) <: AbstractFloat)
            error("probability field ($probability) must be a floating point number")
        end

        nParents = get(crossoverDict, "nParents", 2)

        if !(typeof(nParents) <: Integer)
            error("nParents field ($nParents) must be an integer number")
        end

        nChildren = get(crossoverDict, "nChildren", -1)

        if !(typeof(nChildren) <: Integer)
            error("nChildren field ($nChildren) must be an integer number")
        end

        varArgs = get(crossoverDict, "arguments", [])

        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end

        setCrossoverOperator(method, varArgs..., genj=experiment, probability=probability, nParents=nParents, nChildren=nChildren)

    end
end # function


"""
    parseMutation(mutationDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseMutation(mutationDict::Dict, experiment::GeneticJuliaStructure)

    method = get(mutationDict, "method", false)
    if method == false
        type = experiment._experimentInfo._individualType
        if !isdefined(experiment._experimentInfo, :_individualType) || !isPredefinedType(type)
            error("Either a mutation method or one of the predefined types(BinaryGA, IntegerGA, CanonicalGP) must be provided. The predefined types can be set in individualType field.")
        end
        aux = getDefaultMutationOp(type)
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for mutation has not been provided, functionArgs introduced will be dismissed, '$method' will be the default mutation method"

        probability = get(mutationDict, "probability", 0.7)

        if !(typeof(probability) <: AbstractFloat)
            error("probability field ($probability) must be a floating point number")
        end

        setMutationOperator(method, varArgs..., genj=experiment, probability=probability)

    else
        aux = 0
        try
            aux = eval(Meta.parse(method))
        catch e
            error("The following function of Mutation: '$method', is not defined")
        end
        if typeof(aux) <: Function
            method = aux
        else
            error("The following function of Mutation: '$method', is not a function")
        end

        probability = get(mutationDict, "probability", 0.7)

        if !(typeof(probability) <: AbstractFloat)
            error("probability field ($probability) must be a floating point number")
        end

        varArgs = get(mutationDict, "arguments", [])

        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end

        setMutationOperator(method, varArgs..., genj=experiment, probability=probability)

    end
end # function


"""
    parseReplacement(replacementDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseReplacement(replacementDict::Dict, experiment::GeneticJuliaStructure)

    method = get(replacementDict, "method", false)
    if method == false
        type = experiment._experimentInfo._individualType
        if !isdefined(experiment._experimentInfo, :_individualType) || !isPredefinedType(type)
            error("Either a replacement method or one of the predefined types(BinaryGA, IntegerGA, CanonicalGP) must be provided. The predefined types can be set in individualType field.")
        end
        aux = getDefaultMutationOp(type)
        method = aux[1]
        varArgs = aux[2]
        @warn "Method for replacement has not been provided, functionArgs introduced will be dismissed, '$method' will be the default replacement method"

        setReplacementOperator(method, varArgs..., genj=experiment)

    else
        aux = 0
        try
            aux = eval(Meta.parse(method))
        catch e
            error("The following function of Replacement: '$method', is not defined")
        end
        if typeof(aux) <: Function
            method = aux
        else
            error("The following function of Replacement: '$method', is not a function")
        end

        needsComparison = get(replacementDict, "needsComparison", false)

        if needsComparison == 1
            needsComparison = true
        elseif needsComparison == 0
            needsComparison = false
        end

        if !(typeof(needsComparison) <: Bool)
            error("needsComparison field in Replacement must be boolean")
        end

        eliteSize = get(replacementDict, "eliteSize", 0)

        if !(typeof(eliteSize) <: Integer)
            error("eliteSize field in Replacement must be an integer number")
        end

        individualMode = get(replacementDict, "individualMode", "fitness")

        if !(typeof(individualMode) <: String)
            error("individualMode field in Replacement ($individualMode) must be a string")
        end

        varArgs = get(replacementDict, "arguments", [])

        if !(typeof(varArgs) <: Array)
            varArgs = [varArgs]
        end

        setReplacementOperator(method, varArgs..., genj=experiment, needsComparison=needsComparison, eliteSize=eliteSize)
    end
end # function

"""
    parseStopCondition(stopConditionDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseStopCondition(stopConditionDict::Dict, experiment::GeneticJuliaStructure)

    maxEvaluations = get(stopConditionDict, "maxEvaluations", -1)

    if !(typeof(maxEvaluations) <: Integer)
        error("maxEvaluations field ($maxEvaluations) must be an integer number")
    end

    maxIterations = get(stopConditionDict, "maxIterations", -1)

    if !(typeof(maxIterations) <: Integer)
        error("maxIterations field ($maxIterations) must be an integer number")
    end

    maxIterNotImproving = get(stopConditionDict, "maxIterNotImproving", -1)

    if !(typeof(maxIterNotImproving) <: Integer)
        error("maxIterNotImproving field ($maxIterNotImproving) must be an integer number")
    end

    maxTime = get(stopConditionDict, "maxTime", Inf)

    if !(typeof(maxTime) <: AbstractFloat)
        error("maxTime field ($maxTime) must be a number")
    end

    setStopCondition(genj=experiment, maxEvaluations=maxEvaluations, maxIterations=maxIterations, maxIterNotImproving=maxIterNotImproving, maxTime=maxTime)
end # function



"""
    parseExperimentSummary(summaryDict::Dict, experiment::GeneticJuliaStructure)

documentation
"""
function parseExperimentSummary(summaryDict::Dict, experiment::GeneticJuliaStructure)
    outputFile = get(summaryDict, "outputFile", "")
    if !(typeof(outputFile) <: String)
        error("outputFile field in Experiment Summary must be a string")
    end

    batchSize = get(summaryDict, "batchSize", 0)
    if !(typeof(batchSize) <: Integer)
        error("batchSize field in Experiment Summary must be an integer number")
    end

    printDuringExperiment = get(summaryDict, "printDuringExperiment", false)
    if !(typeof(printDuringExperiment) <: Bool)
        error("printDuringExperiment field in Experiment Summary must be either true or false")
    end

    displayFitness = get(summaryDict, "displayFitness", false)
    if !(typeof(displayFitness) <: Bool)
        error("displayFitness field in Experiment Summary must be either true or false")
    end

    displayBestFitness = get(summaryDict, "displayBestFitness", false)
    if !(typeof(displayBestFitness) <: Bool)
        error("displayBestFitness field in Experiment Summary must be either true or false")
    end

    displayFitnessMean = get(summaryDict, "displayFitnessMean", false)
    if !(typeof(displayFitnessMean) <: Bool)
        error("displayFitnessMean field in Experiment Summary must be either true or false")
    end

    displayFitnessSTD = get(summaryDict, "displayFitnessSTD", false)
    if !(typeof(displayFitnessSTD) <: Bool)
        error("displayFitnessSTD field in Experiment Summary must be either true or false")
    end

    setExperimentSummary(experiment, outputFile=outputFile, batchSize=batchSize,
                         printDuringExperiment=printDuringExperiment, displayFitness=displayFitness,
                         displayBestFitness=displayBestFitness, displayFitnessMean=displayFitnessMean,
                         displayFitnessSTD=displayFitnessSTD)
end # function



"""
    generateMainStructure(genJ::GeneticJuliaStructure, jsonFile::String)

documentation
"""
function generateMainStructure(jsonFile::String; verbose::Bool = true)
    file=open(jsonFile)
    dictionary = JSON.parse(file)
    close(file)

    nExperiments = length(dictionary["Experiments"])
    experiments = Array{GeneticJuliaStructure}(undef, nExperiments)

    if verbose
        println("\n")
        println("Reading JSON file")
        println("##########################")
    end
    for i=1:nExperiments
        if verbose
            print("\t· Experiment $i ")
        end
        experiments[i] = GeneticJuliaStructure()

        experiments[i]._experimentInfo = ExperimentInfo()

        experimentInfoDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "ExperimentInfo", false)
        if experimentInfoDict != false
            parseExperimentInfo(experimentInfoDict, experiments[i])
        end

        evaluator = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "Evaluator", false)
        if evaluator != false
            parseEvaluator(evaluator, experiments[i])
        else
            error("Evaluator is a mandatory field in GeneticJuliaStructure")
        end

        generatorDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "Generator", false)
        if generatorDict != false
            parseGenerator(generatorDict, experiments[i])
        else
            error("Generator is a mandatory field in GeneticJuliaStructure")
        end

        selectorDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "Selector", false)
        if selectorDict != false
            parseSelector(selectorDict, experiments[i])
        end

        crossoverDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "Crossover", false)
        if crossoverDict != false
            parseCrossover(crossoverDict, experiments[i])
        end

        mutationDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "Mutation", false)
        if mutationDict != false
            parseMutation(mutationDict, experiments[i])
        end

        replacementDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "Replacement", false)
        if replacementDict != false
            parseReplacement(replacementDict, experiments[i])
        end

        stopConditionDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "StopConditions", false)
        if stopConditionDict != false
            parseStopCondition(stopConditionDict, experiments[i])
        end

        summaryDict = get(dictionary["Experiments"][i]["GeneticJuliaStructure"], "ExperimentSummary", false)
        if summaryDict != false
            parseExperimentSummary(summaryDict, experiments[i])
        end

        if verbose
            println("→ Experiment correctly read ✔")
        end
    end
    if verbose
        println("##########################\n")
    end

    return experiments
end # function
