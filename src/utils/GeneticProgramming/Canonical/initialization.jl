"""
    growGenerator(gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

Creates a CGP tree using the \"grow\" method.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
None

# Returns
An instance of type `CGPGenotype` created by the \"grow\" method.
"""
function growGenerator(gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)
    functionSet = gpExperimentInfo._functionSet
    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    maxDepth = gpExperimentInfo._maxTreeDepth

    function growRecursiveMethod(maxDepthAux)
        expr = Array{Node}(undef, 0)
        prob = length(terminalSet)/(length(terminalSet) + length(functionSet))

        if maxDepthAux == 0 || rand(rng) < prob
            push!(expr, rand(rng, terminalSet))
        else
            push!(expr, rand(rng, functionSet))

            arity = getFunctionArity(expr[end])

            for i = 1:arity
                append!(expr, growRecursiveMethod(maxDepthAux-1))
            end
        end

        return expr
    end # function

    return CGPGenotype(growRecursiveMethod(maxDepth))
end # function



"""
    fullGenerator(gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

Creates a CGP tree using the \"full\" method.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
None

# Returns
An instance of type `CGPGenotype` created by the \"full\" method.
"""
function fullGenerator(gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)
    functionSet = gpExperimentInfo._functionSet
    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    maxDepth = gpExperimentInfo._maxTreeDepth

    function fullRecursiveMethod(maxDepthAux)

        expr = Array{Node}(undef, 0)

        if maxDepthAux == 0
            push!(expr, rand(rng, terminalSet))
        else

            push!(expr, rand(rng, functionSet))

            arity = getFunctionArity(expr[end])

            for i = 1:arity
                append!(expr, fullRecursiveMethod(maxDepthAux-1))
            end
        end

        return expr
    end # function

    return CGPGenotype(fullRecursiveMethod(maxDepth))
end # function
