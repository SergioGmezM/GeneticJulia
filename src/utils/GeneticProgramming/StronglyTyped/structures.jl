"
Auxiliary structure that keeps some generic information for STGP experiments.

# Fields
- `_functionSet::Array{FunctionNode}`: array that contains all the non-terminal
    nodes specified in the node information file.
- `_terminalSet::Array{TerminalNode}`: array that contains all the terminal nodes
    specified in the node information file.
- `_maxTreeDepth::UInt16`: maximum tree depth permitted.
- `_variables::Array{String}`: array that contains the names of the variables of
    the problem.

See also: [`GPExperimentInfo`](@ref)
"
struct STGPInfo <: GPExperimentInfo
    _functionSet::Array{FunctionNode}
    _terminalSet::Array{TerminalNode}
    _maxTreeDepth::UInt16
    _variables::Array{String}
end # struct
