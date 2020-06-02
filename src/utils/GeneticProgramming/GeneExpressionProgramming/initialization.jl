"""
    growGenerator(gpExperimentInfo::GEPInfo, rng::Random.AbstractRNG)

documentation
"""
function growGenerator(gpExperimentInfo::GEPInfo, rng::Random.AbstractRNG)
    functionSet = gpExperimentInfo._functionSet
    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    headSize = gpExperimentInfo._head
    tailSize = gpExperimentInfo._tail
    repSize = headSize + tailSize

    representation = Array{Node}(undef, repSize)
    prob = length(terminalSet)/(length(terminalSet) + length(functionSet))

    for i=1:headSize
        if rand(rng) < prob
            representation[i] = rand(rng, terminalSet)
        else
            representation[i] = rand(rng, functionSet)
        end
    end

    for i=headSize+1:repSize
        representation[i] = rand(rng, terminalSet)
    end

    return GEPGenotype(representation)
end # function



"""
    fullGenerator(gpExperimentInfo::GEPInfo, rng::Random.AbstractRNG)

documentation
"""
function fullGenerator(gpExperimentInfo::GEPInfo, rng::Random.AbstractRNG)
    functionSet = gpExperimentInfo._functionSet
    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    headSize = gpExperimentInfo._head
    tailSize = gpExperimentInfo._tail
    repSize = headSize + tailSize

    representation = Array{Node}(undef, repSize)

    for i=1:headSize
        representation[i] = rand(rng, functionSet)
    end

    for i=headSize+1:repSize
        representation[i] = rand(rng, terminalSet)
    end

    return GEPGenotype(representation)
end # function
