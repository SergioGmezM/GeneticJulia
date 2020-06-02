

"""
    getPhenotype(gramm::Grammar, genotype::GEGenotype)

Obtains the phenotype as expresion in Julia from a grammatical tree.
"""
function getPhenotype(gramm::Grammar, genotype::GEGenotype)

    if !genotype._valid
        return quote Inf end
    end
    tree = genotype._tree
    stack = [tree]
    result = Array{String}(undef, 0)

    while !isempty(stack)
        node = popfirst!(stack)
        if isLeaf(node)
            push!(result, getRepresentation(gramm, node))
        else
            children = getChildren(node)
            nChildren = length(children)
            for i=1:nChildren
                pushfirst!(stack, children[i])
            end
        end
    end
    if length(result) == 1
        result = Meta.parse(result[1])
        return quote $result end
    else
        aux = Meta.parse(join(result))
        if !(typeof(aux) <: Expr)
            return quote $aux end
        else
            return aux
        end
    end
end




"""
    compareFunctions(genotype::GEGenotype,
                    gpExperimentInfo::GPExperimentInfo, objectives::Array,
                    values...)

This GE-exclusive fitness function compares the objective values given with the
ones obtained by the individual's evaluation using the values for the variables.
The fitness value that this function calculates is the MSE between the results of
the genotype for the given variable values and the objective values.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::GPGenotype`: genotype of the individual that is going to be evaluated.
- `gpExperimentInfo::GPExperimentInfo`: information about the GP experiment.

# User Arguments
- `objectives::Array`: objective values that are going to be compared.
- `values`: values of the variables. Must be in the same order as the variables
    are in the GP experiment information (see documentation of [`GPExperimentInfo`](@ref)
    and [`getVariables`](@ref)).

# Returns
The MSE between the objective values and the results of evaluating the genotype
with the given variables values.

# Examples
```jdoctests
julia> objectives = [0, 1, 4, 9, 16, 25] #Objective values
6-element Array{Int64,1}:
[...]

julia> xValues = [0, 1, 2, 3, 4 , 5] #Values for variable x
6-element Array{Int64,1}:
[...]

julia> setEvaluator([FitnessFunction(compareFunctions, objectives, xValues, weight=-1)])
Evaluator(...)
```

See also: [`setEvaluator`](@ref), [`FitnessFunction`](@ref)
"""
function compareFunctions(genotype::GEGenotype,
                          gpExperimentInfo::GEInfo, objectives::Array,
                          values...)


    vars = getVariables(gpExperimentInfo)
    nVars = length(vars)

    vars = [Meta.parse(x) for x in vars]
    vars = (vars...,)
    phenotype = getPhenotype(gpExperimentInfo._grammar, genotype)

    values = [i for i in values]
    nValues = 1
    y = 0
    y_est = 0
    acc = 0
    failures = 0

    if nVars == 0

        y = objectives[1]

        try
            y_est = evalPhenotype(phenotype)

            if isnan(y_est) || abs(y_est) == Inf
                failures += 1
            else
                acc += (abs(y - y_est))^2
            end
        catch
            failures += 1
        end

    else
        nValues = length(values[1])
        varValues = Array{Number}(undef, nVars)
        for i=1:nValues

            for j=1:nVars
                varValues[j] = values[j][i]
            end
            varsdict = NamedTuple{vars}(varValues)

            y = objectives[i]

            try
                y_est = evaluate(phenotype, varsdict)

                if isnan(y_est) || abs(y_est) == Inf
                    failures += 1
                else
                    acc += (abs(y - y_est))^2
                end
            catch e

                failures += 1
            end
        end
    end

    if failures > (nValues * 0.15)
        fitness = Inf
    else
        mse = acc/(nValues - failures)
        fitness = (acc + failures * mse * 3) / nValues
    end

    return fitness
end # function
