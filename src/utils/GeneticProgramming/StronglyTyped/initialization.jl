"""
    growGenerator(gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

Creates a STGP tree using the \"grow\" method.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
None

# Returns
An instance of type `STGPGenotype` created by the \"grow\" method.
"""
function growGenerator(gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)
    functionSet = gpExperimentInfo._functionSet
    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    maxDepth = gpExperimentInfo._maxTreeDepth

    function growRecursiveMethod(maxDepthAux::Integer, allowedType::Union{DataType, Union})
        expr = Array{Node}(undef, 0)
        prob = length(terminalSet)/(length(terminalSet) + length(functionSet))

        if maxDepthAux == 0 || rand(rng) < prob

            node = (allowedType == Any) ? rand(rng, terminalSet) : rand(rng,
                   filter(x->getType(x) <: allowedType, terminalSet))
            push!(expr, node)
        else
            node = (allowedType == Any) ? rand(rng, functionSet) : rand(rng,
                   filter(x->getType(x) <: allowedType, functionSet))
            push!(expr, node)

            argTypes = node._argTypes
            arity = getFunctionArity(node)

            for i=1:arity
                append!(expr, growRecursiveMethod(maxDepthAux-1, argTypes[i]))
            end
        end

        return expr
    end # function

    return STGPGenotype(growRecursiveMethod(maxDepth, Any))
end # function



"""
    fullGenerator(gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

Creates a STGP tree using the \"full\" method.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
None

# Returns
An instance of type `STGPGenotype` created by the \"full\" method.
"""
function fullGenerator(gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)
    functionSet = gpExperimentInfo._functionSet
    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    maxDepth = gpExperimentInfo._maxTreeDepth

    function fullRecursiveMethod(maxDepthAux::Integer, allowedType::Union{DataType, Union})
        expr = Array{Node}(undef, 0)

        if maxDepthAux == 0
            node = (allowedType == Any) ? rand(rng, terminalSet) : rand(rng,
                   filter(x->getType(x) <: allowedType, terminalSet))
            push!(expr, node)
        else
            node = (allowedType == Any) ? rand(rng, functionSet) : rand(rng,
                   filter(x->getType(x) <: allowedType, functionSet))
            push!(expr, node)
            argTypes = node._argTypes
            arity = getFunctionArity(node)

            for i=1:arity
                append!(expr, fullRecursiveMethod(maxDepthAux-1, argTypes[i]))
            end
        end

        return expr
    end # function

    return STGPGenotype(fullRecursiveMethod(maxDepth, Any))
end # function
