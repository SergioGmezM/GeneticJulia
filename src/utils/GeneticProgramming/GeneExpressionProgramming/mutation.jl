"""
    geneMutation(genotype::GEPGenotype,
                 gpExperimentInfo::GEPInfo,
                 rng::Random.AbstractRNG)

documentation
"""
function geneMutation(genotype::GEPGenotype,
                      gpExperimentInfo::GEPInfo,
                      rng::Random.AbstractRNG)

    representation = genotype._representation
    functionSet = gpExperimentInfo._functionSet
    terminalSet = gpExperimentInfo._terminalSet
    headSize = gpExperimentInfo._head
    tailSize = gpExperimentInfo._tail
    lenRep = headSize + tailSize
    prob = lenRep < 5 ? 1/lenRep : 4/lenRep
    probTer = length(terminalSet) / (length(terminalSet) + length(functionSet))

    mutatedGenotype = Array{Node}(undef, lenRep)

    for i=1:headSize
        if (rand(rng) - (lenRep-i+1)*prob/(2*lenRep)) < prob
            if rand(rng) < probTer
                mutatedGenotype[i] = rand(rng, terminalSet)
            else
                mutatedGenotype[i] = rand(rng, functionSet)
            end
        else
            mutatedGenotype[i] = representation[i]
        end
    end

    for i=headSize+1:lenRep
        if (rand(rng) - (lenRep-i+1)*prob/(2*lenRep)) < prob
            mutatedGenotype[i] = rand(rng, terminalSet)
        else
            mutatedGenotype[i] = representation[i]
        end
    end

    return GEPGenotype(mutatedGenotype)
end # function
