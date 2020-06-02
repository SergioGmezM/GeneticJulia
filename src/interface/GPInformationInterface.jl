"""
    setCGPInfo(; nodesFile::String = "", maxTreeDepth::Integer = 3,
               genj::GeneticJuliaStructure = GenJ)

Sets the information about a Canonical Genetic Programming problem.
This function constructs a structure of type `CGPInfo` and adds it to the GP
experiment info field of the experiment info of the main structure.

# Keyword Arguments
- `nodesFile::String = ""`: file in which the information about terminal and
    non-terminal nodes is. If this is not specified, the system provides with a
    file that is read by default and contains the simples arithmetic operations and terminals.
- `maxTreeDepth::Integer = 3`: maximum tree depth permitted. If this argument is
    not specified, it will be 3 by default.
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> setCGPInfo() #Arguments set by default
```

```jldoctest
julia> setCGPInfo(nodesFile="myNodesFile.txt", maxTreeDepth=4) #Setting a specific node information file and a maximum tree depth of 4
```

See also: [`setSTGPInfo`](@ref), [`setGEPInfo`](@ref), [`setGEInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setCGPInfo(; nodesFile::String = "", maxTreeDepth::Integer = 3,
                    genj::GeneticJuliaStructure = GenJ)

    if nodesFile == ""
        functionSet, terminalSet = createNodes("GeneticJulia/src/utils/GeneticProgramming/Canonical/exampleNodesCGP.json")
    elseif isfile(nodesFile)
        functionSet, terminalSet = createNodes(nodesFile)
    else
        error("Node information file $nodesFile does not exist in the specified directory")
    end

    functionSet = unique(functionSet)

    if maxTreeDepth <= 0
        error("Maximum tree depth must be an integer number greater than 0")
    end

    # Variables' names obtention
    variables = getVariableName.(filter(x -> typeof(x) <: VariableNode, terminalSet))

    setGPExperimentInfo(CGPInfo(functionSet, terminalSet, maxTreeDepth, variables), genj=genj)
end # function



"""
    setSTGPInfo(; nodesFile::String = "", maxTreeDepth::Integer = 3,
                genj::GeneticJuliaStructure = GenJ)

Sets the information about a Strongly Typed Genetic Programming problem.
This function constructs a structure of type `STGPInfo` and adds it to the GP
experiment information field of the experiment information of the main structure.

# Keyword Arguments
- `nodesFile::String = ""`: file in which the information about terminal and
    non-terminal nodes is. If this is not specified, the system provides with a
    file that is read by default and contains the simples arithmetic operations and terminals.
- `maxTreeDepth::Integer = 3`: maximum tree depth permitted. If this argument is
    not specified, it will be 3 by default.
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> #Arguments set by default
julia> setSTGPInfo()
```

```jldoctest
julia> #Setting a specific node information file and a maximum tree depth of 4
julia> setSTGPInfo(nodesFile="myNodesFile.txt", maxTreeDepth=4)
```

See also: [`setCGPInfo`](@ref), [`setGEPInfo`](@ref), [`setGEInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setSTGPInfo(; nodesFile::String = "", maxTreeDepth::Integer = 3,
                     genj::GeneticJuliaStructure = GenJ)

    if nodesFile == ""
        functionSet, terminalSet = createNodes("ECJ/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP.json")
    elseif isfile(nodesFile)
        functionSet, terminalSet = createNodes(nodesFile)
    else
        error("Node information file $nodesFile does not exist in the specified directory")
    end

    functionSet = unique(functionSet)

    if maxTreeDepth <= 0
        error("Maximum tree depth must be an integer number greater than 0")
    end

    # Variables' names obtention
    variables = getVariableName.(filter(x -> typeof(x) <: VariableNode, terminalSet))

    setGPExperimentInfo(STGPInfo(functionSet, terminalSet, maxTreeDepth, variables), genj=genj)
end # function



"""
    setGEPInfo(; nodesFile::String = "", head::Integer = 7, genj::GeneticJuliaStructure = GenJ)

Sets the information about a Gene Expression Programming problem.
This function constructs a structure of type `GEPInfo` and adds it to the GP
experiment information field of the experiment information of the main structure.

# Keyword Arguments
- `nodesFile::String = ""`: file in which the information about terminal and
    non-terminal nodes is. If this is not specified, the system provides with a
    file that is read by default and contains the simples arithmetic and boolean
    operations and terminals.
- `head::Integer = 7`: length of the head of the genotype, which will determine
    the total length of the genotype, along with the maximum arity of the non-terminals.
    If this argument is not specified, it will be 7 by default.
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> #Arguments set by default
julia> setGEPInfo()
```

```jldoctest
julia> #Setting a specific node information file and a head length of 5
julia> setSTGPInfo(nodesFile="myNodesFile.txt", head=5)
```

See also: [`setCGPInfo`](@ref), [`setSTGPInfo`](@ref), [`setGEInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setGEPInfo(; nodesFile::String = "", head::Integer = 7, genj::GeneticJuliaStructure = GenJ)

    if nodesFile == ""
        functionSet, terminalSet = createNodes("ECJ/utils/GeneticProgramming/GeneExpressionProgramming/exampleNodesGEP.json")
    elseif isfile(nodesFile)
        functionSet, terminalSet = createNodes(nodesFile)
    else
        error("Node information file $nodesFile does not exist in the specified directory")
    end

    if head <= 0
        error("Head length must be an integer number greater than 0")
    end

    # Maximum arity obtention
    maxArity = 0
    for func in functionSet
        if maxArity < func._arity
            maxArity = func._arity
        end
    end

    # Tail length calculation
    tail = head * (maxArity - 1) + 1

    # Variables' names obtention
    variables = getVariableName.(filter(x -> typeof(x) <: VariableNode, terminalSet))

    setGPExperimentInfo(GEPInfo(functionSet, terminalSet, head, tail, variables), genj=genj)
end # function



"""
    setGEInfo(N::Array{String}, T::Array{String}, P::Array{String}, S::String,
              variables::Array{String}; genj::GeneticJuliaStructure = GenJ,
              maxProductions::Integer = 15, maxDepth::Integer = -1)

Sets the information about a Grammatical Evolution problem.
This function constructs a structure of type `GEInfo` and adds it to the GP
experiment information field of the experiment information of the main structure.


# Arguments
- `N::Array{String}`: array that contains the symbols of non-terminal grammatical
    expressions.
- `T::Array{String}`: array that contains the symbols of terminal grammatical
    expressions.
- `P::Array{String}`: array that contains the production rules.
- `S:String`: initial symbol from which the expressions are generated.
- `variables::Array{String}`: array that contains the name of the variables of the problem.


# Keyword Arguments
- `maxProductions::Integer = 15`: maximum number of productions permitted.
- `maxDepth::Integer = -1`: maximum tree depth permitted.
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
```jldoctest
julia> #Declaring the Grammar

julia> N=["expr","op", "var"]
3-element Array{String,1}:
 "expr"
 "op"
 "var"

julia> T=["x", "y", "+", "-", "/", "*", "(", ")"]
8-element Array{String,1}:
 "x"
 "y"
 "+"
 "-"
 "/"
 "*"
 "("
 ")"

julia> P=[
    "<expr> -> (<expr> <op> <expr>)
             | <var>",

    "<op> -> +
           | -
           | /
           | *",

    "<var> -> x
            | y"
]
3-element Array{String,1}:
 "<expr> -> (<expr> <op> <expr>) | <var>"
 "<op> -> + | - | / | *"
 "<var> -> x | y"

julia> S="expr"
"expr"

#Arguments by default
julia> setGEInfo(N, T, P, S, ["x", "y"])
```

```jldoctest
julia> #Setting a maximum number of productions of 20
julia> setGEInfo(N, T, P, S, ["x", "y"], maxProductions=20)
```

```jldoctest
julia> #Setting a maximum tree depth of 5
julia> setGEInfo(N, T, P, S, ["x", "y"], maxProductions=0, maxDepth=5)
```

When setting a maximum number of production rules or a maximum tree depth,
take in consideration that those two cannot be set a the same time, otherwise
an error will be thrown.

```jldoctest
julia> #Setting a maximum tree depth of 5
julia> setGEInfo(N, T, P, S, ["x", "y"], maxProductions=20, maxDepth=5)
ERROR: Either maxDepth or maxProduction must be set, but not both. By default,
    maxProductions is 15, if you want to use maxDepth, set maxProductions to 0 or below.
    [...]
```

Also, either if you set `maxProductions` to a number lower than 6 or `maxDepth` to a
number lower than 3, a warning will be displayed saying that if the Grammar is
long, generated trees might be too similar with so few productions or small depth
or incorrect due to no termination.

```jldoctest
julia> #Setting a maximum tree depth of 5
julia> setGEInfo(N, T, P, S, ["x", "y"], maxProductions=4)
Warning: maxProductions have been set to 1, if your grammar is long, grammatical
    trees will be too similar or, in some cases, incorrect due to no termination
    [...]
```

See also: [`setCGPInfo`](@ref), [`setSTGPInfo`](@ref), [`setGEPInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setGEInfo(N::Array{String}, T::Array{String}, P::Array{String}, S::String,
                   variables::Array{String}; genj::GeneticJuliaStructure = GenJ,
                   maxProductions::Integer = 15, maxDepth::Integer = -1)

    if maxDepth > 0 && maxProductions < 0
        error("If maxDepth is set, maxProduction must be set. By
               default, maxProductions is 15, if you want to use maxDepth, set
               maxProductions to a higher number.")
    end
    if maxDepth <= 0 && maxProductions <= 0
        error("Either maxDepth or maxProduction must be set. By
               default, maxProductions is 15, if you want to use maxDepth, set
               maxProductions to a higher number.")
    end

    if 0 < maxProductions < 6
        @warn "maxProductions have been set to $maxProductions, if your grammar
               is long, grammatical trees will be too similar or, in some cases,
               incorrect due to no termination"
    end

    if 0 < maxDepth < 3
        @warn "maxDepth have been set to $maxDepth, if your grammar is long,
               grammatical trees will be too similar or, in some cases, incorrect
               due to no termination"
    end

    # Existance of every variable as a terminal node is checked
    for i=1:length(variables)
        check = false
        for j=1:length(N)
            if variables[i] == T[j]
                check = true
                break
            end
        end
        if !check
            error("Variable $(variables[i]) isn't found in the terminal set")
        end
    end

    grammar = createGrammar(N, T, P, S)
    setGPExperimentInfo(GEInfo(grammar, maxProductions, maxDepth, variables), genj=genj)
end # function



"""
    setGPExperimentInfo(GPInfo::GPExperimentInfo; genj::GeneticJuliaStructure = GenJ)

Sets the information about a Genetic Programming problem to the given one.

# Arguments
- `GPInfo::GPExperimentInfo`: experiment information for a GP problem.

# Keyword Arguments
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

See also: [`setCGPInfo`](@ref), [`setSTGPInfo`](@ref), [`setGEPInfo`](@ref),
[`setGEInfo`](@ref)
"""
function setGPExperimentInfo(GPInfo::GPExperimentInfo; genj::GeneticJuliaStructure = GenJ)
    genj._experimentInfo._GPExperimentInfo = GPInfo
end # function



"""
    setGPExperimentInfo(; genj::GeneticJuliaStructure = GenJ)

Sets the default information about a Genetic Programming problem according to
the individual type specified.

# Keyword Arguments
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

See also: [`setCGPInfo`](@ref), [`setSTGPInfo`](@ref), [`setGEPInfo`](@ref),
[`setGEInfo`](@ref)
"""
function setGPExperimentInfo(; genj::GeneticJuliaStructure = GenJ)
    if genj._experimentInfo._individualType <: CGPGenotype
        setCGPInfo(genj=genj)
    elseif genj._experimentInfo._individualType <: STGPGenotype
        setSTGPInfo(genj=genj)
    elseif genj._experimentInfo._individualType <: GEPGenotype
        setGEPInfo(genj=genj)
    end
end # function
