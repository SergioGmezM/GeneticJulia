"""
    proteinMutation(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                        rng::Random.AbstractRNG, integerMutation::Function, varargs...)

Perform codons based mutation a **Grammatical Evolution** Individual, by means of
an integer mutation.

# Self-provided Arguments
- `genotype::GEGenotype`: individual genotype.
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `integerMutation::Function`: integer mutation function.
- `varargs`: arguments for integerMutation.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function proteinMutation(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                        rng::Random.AbstractRNG, integerMutation::Function, varargs...)


    protein, introns = pruneProtein(genotype)

    child = integerMutation(protein, rng, varargs...)

    child = generateTree(gpExperimentInfo, rng::Random.AbstractRNG, vcat(child._representation, introns))

    return child
end



"""
    proteinMutationGrow(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                            rng::Random.AbstractRNG, integerMutation::Function, varargs...)

As proteinMutation, but instead, a growGenerator is used to ensure that all individuals are valids.
It is advisable to used along proteinCrossGrow.

# Self-provided Arguments
- `genotype::GEGenotype`: individual genotype.
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `integerCross::Function`: integer crossover function.
- `varargs`: arguments for integerCross.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function proteinMutationGrow(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                            rng::Random.AbstractRNG, integerMutation::Function, varargs...)

    protein, introns = pruneProtein(genotype)

    child = integerMutation(protein, rng, varargs...)

    child = growGenerator(gpExperimentInfo, rng::Random.AbstractRNG, vcat(child._representation, introns))

    return child
end
