
function uniformMutation(genotype::IntegerGenotype, rng::Random.AbstractRNG,
                         min::Integer, max::Integer, nGens::Integer=1)

    if min > max
        min, max = max, min
    end

    indRep = genotype._representation
    genLen = length(indRep)
    mutatedIndRep = Array{Integer}(undef, genLen)

    if nGens > genLen
        nGens = genLen
    end

    indexes = randomIndexSelection(genLen, nGens, rng)

    mutatedIndRep = copy(indRep)
    range = max-min

    for i=1:nGens
        mutatedIndRep[indexes[i]] = (rand(rng, UInt64)%range)+1+min
    end

    return IntegerGenotype(mutatedIndRep)
end
