"
Auxiliary structure that keeps some generic information for GEP experiments.

# Fields
- `_functionSet::Array{FunctionNode}`: array that contains all the non-terminal
    nodes specified in the node information file.
- `_terminalSet::Array{TerminalNode}`: array that contains all the terminal nodes
    specified in the node information file.
- `_head::UInt16`: length of the head of the genotype.
- `_tail::UInt16`: length of the tail of the genotype. It is calculated as follows:
    t = h (n-1) + 1 , where n is the maximum arity of the non-terminal nodes of the
    problem.
- `_variables::Array{String}`: array that contains the names of the variables of
    the problem.

See also: [`GPExperimentInfo`](@ref)
"
struct GEPInfo <: GPExperimentInfo
    _functionSet::Array{FunctionNode}
    _terminalSet::Array{TerminalNode}
    _head::UInt16
    _tail::UInt16
    _variables::Array{String}
end # struct
