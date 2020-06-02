"""
    setDefaultAlgorithm(genj::GeneticJuliaStructure)

documentation
"""
function setDefaultAlgorithm(genj::GeneticJuliaStructure)
    genj._experimentInfo._algorithm = basicExperiment
    genj._experimentInfo._algorithmArgs = Array{Any}(undef, 0)
end # function

"""
    setDefaultStopCondition(genj::GeneticJuliaStructure)

documentation
"""
function setDefaultStopCondition(genj::GeneticJuliaStructure)
    setStopCondition(genj = genj, maxEvaluations = -1, maxIterations = 500, maxIterNotImproving = -1, maxTime = Inf)
end # function

"""
    setDefaultSelector()

documentation
"""
function setDefaultSelector(genj::GeneticJuliaStructure)
    aux = getDefaultSelector()
    setSelector(aux[1], aux[2]..., nSelected=genj._generator._popSize, genj=genj)
end # function

"""
    setDefaultCrossoverOp(genj::GeneticJuliaStructure)

documentation
"""
function setDefaultCrossoverOp(genj::GeneticJuliaStructure)
    aux = getDefaultCrossoverOp(genj._experimentInfo._individualType)
    setCrossoverOperator(aux[1], aux[2]..., genj=genj)
end # function


"""
    setDefaultMutationOp(genj::GeneticJuliaStructure)

documentation
"""
function setDefaultMutationOp(genj::GeneticJuliaStructure)
    aux = getDefaultMutationOp(genj._experimentInfo._individualType)
    setMutationOperator(aux[1], aux[2]..., genj=genj)
end # function

"""
    setDefaultReplacementOp(genj::GeneticJuliaStructure)

documentation
"""
function setDefaultReplacementOp(genj::GeneticJuliaStructure)
    aux = getDefaultReplacementOp()
    setReplacementOperator(aux[1], aux[2]..., genj=genj)
end # function


"""
    setDefaultSettings(; genj::GeneticJuliaStructure = GenJ)

documentation
"""
function setDefaultSettings(; genj::GeneticJuliaStructure = GenJ, i::Integer=0)

    if !isdefined(genj._experimentInfo, :_algorithm)
        setDefaultAlgorithm(genj)
    end

    if !isdefined(genj, :_stopCondition)
        setDefaultStopCondition(genj)
    end

    if isdefined(genj._experimentInfo, :_individualType)
        if isPredefinedType(genj._experimentInfo._individualType)
            if !isdefined(genj, :_crossoverOp)
                setDefaultCrossoverOp(genj)
            end

            if !isdefined(genj, :_mutationOp)
                setDefaultMutationOp(genj)
            end
        end
    else
        if i == 0
            error("individualType is mandatory and must be set")
        else
            error("individualType is mandatory and must be set in experiment $i")
        end
    end

    if !isdefined(genj, :_selector)
        setDefaultSelector(genj)
    else
        if !(typeof(genj._selector._nSelectedParents) <: Integer)
            popSize = genj._generator._popSize
            nSelectedParents = genj._selector._nSelectedParents
            nParents = genj._crossoverOp._nParents

            nSelectedParents = convert(Integer, round(nSelectedParents * popSize))
            remainder = nSelectedParents % nParents

            if remainder != 0
                nSelectedParents = nSelectedParents + nParents - remainder
            end
            if !genj._selector._samplingWithRep
                if nSelectedParents > popSize
                    nSelectedParents -= nParents
                end
            end

            genj._selector = SelectionOperator(genj._selector._method, nSelectedParents,
                                               genj._selector._needsComparison,
                                               genj._selector._samplingWithRep,
                                               genj._selector._varArgs)
        end
    end

    if !isdefined(genj, :_replacementOp)
        setDefaultReplacementOp(genj)
    end
end # function
