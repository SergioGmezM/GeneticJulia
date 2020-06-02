"""
    onePointMutation(genotype::CGPGenotype, gpExperimentInfo::CGPInfo,
                     rng::Random.AbstractRNG)

Selects a node from a tree and mutates it into another one.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::CGPGenotype`: genotype of the individual that is going to be mutated.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
None

# Returns
The instance of type `STGPGenotype` mutated.
"""
function onePointMutation(genotype::STGPGenotype, gpExperimentInfo::STGPInfo,
                          rng::Random.AbstractRNG)

    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    functionSet = gpExperimentInfo._functionSet

    representation = genotype._representation
    mutatedChild = deepcopy(representation)

    # Choose a mutation point
    lenRep = length(representation)
    indexes = collect(1:lenRep)
    mutIndex = rand(rng, indexes)

    # Replace the selected node with one of the same arity
    if (chosenNode = chooseAnotherNode(representation[mutIndex], terminalSet,
        functionSet, rng, getType(representation[mutIndex]))) != nothing
        mutatedChild[mutIndex] = chosenNode
    end

    return STGPGenotype(mutatedChild)
end # function



"""
    pointMutation(genotype::CGPGenotype, gpExperimentInfo::CGPInfo,
                  rng::Random.AbstractRNG, probability::AbstractFloat)

Mutates the nodes of a tree with a certain probability.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::CGPGenotype`: genotype of the individual that is going to be mutated.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
- `probability::AbstractFloat`: probability of mutation for each node.

# Returns
The instance of type `STGPGenotype` mutated.
"""
function pointMutation(genotype::STGPGenotype, gpExperimentInfo::STGPInfo,
                       rng::Random.AbstractRNG, probability::AbstractFloat)

    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    functionSet = gpExperimentInfo._functionSet

    representation = deepcopy(genotype._representation)
    lenRep = length(representation)
    mutatedChild = Array{Node}(undef, lenRep)

    for i=1:lenRep
        prob = rand(rng)

        if prob < probability
            if (chosenNode = chooseAnotherNode(representation[i], terminalSet,
                functionSet, rng, getType(representation[i]))) != nothing
                mutatedChild[i] = chosenNode
            else
                mutatedChild[i] = representation[i]
            end
        else
            mutatedChild[i] = representation[i]
        end
    end

    return STGPGenotype(mutatedChild)
end # function
