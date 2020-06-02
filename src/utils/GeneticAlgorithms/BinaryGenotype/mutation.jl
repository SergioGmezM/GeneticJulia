"""
    standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                     probability::AbstractFloat = 0.1)::BinaryGenotype

Mutates a **binary individual**, modifying each gene with a `probability`.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::BinaryGenotype`: genotype that will be mutated.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `probability::AbstractFloat`: lower limit for random generation.
"""
function standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                          probability::AbstractFloat)::BinaryGenotype

    indRep = genotype._representation
    genLen = length(indRep)
    mutatedIndRep = Array{Bool}(undef, genLen)

    for i=eachindex(mutatedIndRep)
        random = rand(rng)
        if random < probability
            mutatedIndRep[i] = !indRep[i]
        else
            mutatedIndRep[i] = indRep[i]
        end
    end
    return BinaryGenotype(mutatedIndRep)
end # function



"""
    standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                     nGens::Integer=1)::BinaryGenotype

Mutates a **binary individual**, modifying a fixed set of genes.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::BinaryGenotype`: genotype that will be mutated.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `nGens::Integer=1`: number of genes of the genotype that will be mutated.
"""
function standardMutation(genotype::BinaryGenotype, rng::Random.AbstractRNG,
                          nGens::Integer=1)::BinaryGenotype

    indRep = genotype._representation
    genLen = length(indRep)
    mutatedIndRep = Array{Bool}(undef, genLen)

    if nGens>50
        indexes = randomIndexSelection2(genLen, nGens, rng)
    else
        indexes = randomIndexSelection(genLen, nGens, rng)
    end

    mutatedIndRep = copy(indRep)

    for i=1:nGens
        mutatedIndRep[i] = !indRep[indexes[i]]
    end

    return BinaryGenotype(mutatedIndRep)
end # function
