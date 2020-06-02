"""
    setStopCondition(; genj::GeneticJuliaStructure = GenJ, maxEvaluations::Integer = -1,
                     maxIterations::Integer = -1, maxIterNotImproving::Integer = -1,
                     maxTime::AbstractFloat = Inf)

Sets the stop conditions for `genj`, however if none are introduced, `maxIterations`
will be set to 100 by default. This function constructs a structure of type
`StopCondition` and adds it to the main structure.

# Keyword Arguments
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.
- `maxEvaluations::Integer = -1`: number of calls to compute fitness before the
    algorithm stops. If it is set to a `negative value`, the verification over
    this parameter will be `useless`, as default.
- `maxIterations::Integer = -1`: number of iterations before the algorithm stops.
    If it is set to a `negative value`, the verification over this parameter
    will be `useless`, as default.
- `maxIterNotImproving::Integer = -1`: number of iterations in which the best
    individual doesn't improve before the algorithm stops. If it is set to a
    `negative value`, the verification over this parameter will be `useless`, as default.
- `maxTime::AbstractFloat = Inf`: time, in seconds, passed since the beginning of the
    experiment before the algorithm stops. If it is set to `inf`, the verification
    over this parameter will be `useless`, as default.

See also: [`StopCondition`](@ref)
"""
function setStopCondition(; genj::GeneticJuliaStructure = GenJ, maxEvaluations::Integer = -1,
                          maxIterations::Integer = -1, maxIterNotImproving::Integer = -1,
                          maxTime::AbstractFloat = Inf)

    if maxTime < 0
        error("maxTime must be a positive number")
    end

    if (maxEvaluations < 1) && (maxIterations < 1) && (maxIterNotImproving < 1) && (maxTime == Inf)
        error("At least one of the stop conditions must be set to a value that allows checking")
    end

    stopCondition = StopCondition(maxEvaluations, maxIterations, maxIterNotImproving, maxTime, 0, 0, 0, 0.0)
    genj._stopCondition = stopCondition
end # function
