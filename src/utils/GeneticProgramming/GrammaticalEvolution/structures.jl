#### GEInfo #########

"
Auxiliary structure that keeps some generic information for Grammatical Evolution experiments.

# Fields
- `_grammar::Grammar`: grammar that will be used. This includes terminal and non-terminal
    symbols, production rules and the initial symbol.
- `_maxProductions::Int16`: maximum number of productions permitted to generate
    trees.
- `_maxDepth::Int16`: maximum tree depth permitted.
- `_variables::Array{String}`: array that contains the names of the variables of
    the problem.

See also: [`GPExperimentInfo`](@ref), [`Grammar`](@ref)
"
struct GEInfo <: GPExperimentInfo
    _grammar::Grammar
    _maxProductions::Int16
    _maxDepth::Int16
    _variables::Array{String}
end # struct





#### GEREP ##########

"
Structure that is the representantion of an individual in Grammatical Evolution,
which is a tree.

# Fields
- `_symbol::UInt16`: symbol in the grammar.
- `_depth::UInt8`: actual depth of the node in the tree.
- `_children::Array{GERep}`: children of symbol if it is a non terminal.

See also: [`GEGenotype`](@ref)
"
mutable struct GERep
    _symbol::UInt16
    _depth::UInt8
    _children::Array

    GERep(symbol::UInt16) = new(symbol, 0, Array{GERep}(undef, 0))
    GERep(symbol::UInt16, depth::UInt8) = new(symbol, depth, Array{GERep}(undef, 0))
end


"""
    getSymbol(tree::GERep)::UInt16

Returns the symbol stored.
"""
getSymbol(tree::GERep)::UInt16 = tree._symbol

"""
    getDepth(tree::GERep)::UInt8

Returns the depth of the node in the tree.
"""
getDepth(tree::GERep)::UInt8 = tree._depth

"""
    getChildren(tree::GERep)::Array{GERep}

Returns the array of children.
"""
getChildren(tree::GERep)::Array{GERep} = tree._children

"""
    setDepth!(tree::GERep, value)

Sets the depth of the node in the tree.
"""
setDepth!(tree::GERep, value) = tree.depth = depth

"""
    setDepth!(tree::GERep, value)

Sets the children of the node.
"""
setChildren!(tree::GERep, children::Array{GERep}) = tree._children = children

"""
    pushChild!(tree::GERep, child::GERep)

Introduce a child in the array of children.
"""
pushChild!(tree::GERep, child::GERep) = push!(getChildren(tree), child)

"""
    getNChildren(tree::GERep)::Int

Returns the number of children.
"""
getNChildren(tree::GERep)::Int = length(getChildren(tree))

"""
    isLeaf(tree::GERep)::Bool

Checks whether the node is a leaf or not.
"""
isLeaf(tree::GERep)::Bool = getNChildren(tree::GERep) == 0



"""
    getHeights(tree::GERep)

Obtains the heights of the nodes in preorder.
!!! warning
    DONT USE, it is still experimental.
"""
function getHeights(tree::GERep)

    representation = getPreOrder(tree)
    lenRep = length(representation)
    heights = Array{UInt16}(undef, lenRep)
    heights[end] = 0
    stack = [lenRep]
    currIndex = lenRep - 1

    while currIndex > 0

        if isLeaf(representation[currIndex])
            heights[currIndex] = 0
        else
            childrenIndexes = Array{UInt8}(undef, 0)
            for i=1:getNChildren(representation[currIndex])
                push!(childrenIndexes, pop!(stack))
            end
            heights[currIndex] = maximum(heights[childrenIndexes]) + 1
        end

        push!(stack, currIndex)
        currIndex -= 1
    end
    return heights
end


"""
    changeNodes!(tree1::GERep, tree2::GERep)

Interchange the given nodes.
"""
function changeNodes!(tree1::GERep, tree2::GERep)
    tree1._symbol, tree2._symbol = tree2._symbol, tree1._symbol
    tree1._children, tree2._children = tree2._children, tree1._children
    tree1._depth, tree2._depth = tree2._depth, tree1._depth
end


"""
    copyTree(tree::GERep)::GERep

Makes a copy of the tree.
"""
function copyTree(tree::GERep)::GERep


    stack = [tree]
    newTree = GERep(tree._symbol, tree._depth)
    copyStack = [newTree]

    while !isempty(stack)
        node = popfirst!(stack)
        newnode = popfirst!(copyStack)
        if !isLeaf(node)
            children = getChildren(node)
            for i in eachindex(children)
                newChild = GERep(children[i]._symbol, children[i]._depth)
                pushChild!(newnode, newChild)
                push!(stack, children[i])
                push!(copyStack, newChild)
            end
        end
    end
    return newTree
end



"""
    printTree(tree::GERep, gramm::Grammar)

Print the tree formated in the current output.
"""
function printTree(tree::GERep, gramm::Grammar)
    stack = [tree]
    result = []
    depth = 0

    function printRecursive(node, depth)
        for i=1:depth-1
            print("   ")
        end
        print("|--")
        if isLeaf(node)
            println(getRepresentation(gramm, node))
        else
            println(getRepresentation(gramm, node))
            for i=getNChildren(node):-1:1
                printRecursive(getChildren(node)[i], depth + 1)
            end
        end
    end
    println(getRepresentation(gramm, tree))
    for i=getNChildren(tree):-1:1
        printRecursive(getChildren(tree)[i], 1)
    end
    nothing
end

"""
    getPreOrder(tree::GERep, onlyNonTerminal::Bool=false)

Returns the given tree as an array in preorder.
"""
function getPreOrder(tree::GERep, onlyNonTerminal::Bool=false)

    stack = [tree]
    preOrder = Array{GERep}(undef, 0)

    while !isempty(stack)
        node = popfirst!(stack)
        if isLeaf(node)
            if !onlyNonTerminal
                push!(preOrder, node)
            end
        else
            push!(preOrder, node)
            children = getChildren(node)
            nChildren = length(children)
            for i=nChildren:-1:1
                pushfirst!(stack, children[i])
            end
        end
    end
    return preOrder
end

"""
    countNonTerminal(tree::GERep)

Returns the number of non terminals in the tree.
"""
function countNonTerminal(tree::GERep)
    stack = [tree]
    count = 0
    while !isempty(stack)
        node = popfirst!(stack)

        if !isLeaf(node)
            count = count + 1
            children = getChildren(node)
            nChildren = length(children)
            for i=nChildren:-1:1
                pushfirst!(stack, children[i])
            end
        end
    end
    return count
end


"""
    getRepresentation(gramm::Grammar, tree::GERep)

Interface for `getRepresentation(gramm::Grammar, id::UInt16)`
"""
function getRepresentation(gramm::Grammar, tree::GERep)
    getRepresentation(gramm, getSymbol(tree))
end



"Main struct for Grammatical Evolution genotypes used in GP."
struct GEGenotype <: GPGenotype
    _tree::GERep
    _ind::IntegerGenotype{UInt8}
    _selections::Array{UInt8}
    _productions::UInt16
    _valid::Bool
end # struct



"""
    pruneProtein(genotype1, genotype2)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}, IntegerGenotype{UInt8}, Array{UInt8}}

Perfoms a prune dividing the codons in two, the useful part and the introns for each
genotype. Returning -> useful1, introns1, useful2, introns2
"""
function pruneProtein(genotype1, genotype2)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}, IntegerGenotype{UInt8}, Array{UInt8}}
    protein1 = genotype1._ind
    len1 = genotype1._productions
    protein2 = genotype2._ind
    len2 = genotype2._productions

    maxlen = len1
    if len2 > len1
        maxLen = len2
    end
    subProtein1 = IntegerGenotype{UInt8}(protein1._representation[1:maxlen])
    introns1 = protein1._representation[maxlen+1:end]

    subProtein2 = IntegerGenotype{UInt8}(protein2._representation[1:maxlen])
    introns2 = protein2._representation[maxlen+1:end]

    return subProtein1, introns1, subProtein2, introns2
end

"""
    pruneProtein(genotype1)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}}

Perfoms a prune dividing the codons in two, the useful part and the introns for
genotype. Returning -> useful, introns
"""
function pruneProtein(genotype)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}}

    protein = genotype._ind
    len = genotype._productions

    subProtein = IntegerGenotype(protein._representation[1:len])
    introns = protein._representation[len:end]

    return subProtein, introns
end

"""
    copyGenotype(geGenotype::GEGenotype)::GEGenotype

Returns a copy of the genotype.
"""
function copyGenotype(geGenotype::GEGenotype)::GEGenotype
    tree = copyTree(geGenotype._tree)
    ind = copyGenotype(geGenotype._ind)
    selections = copy(geGenotype._selections)
    productions = geGenotype._productions
    valid = geGenotype._valid
    GEGenotype(tree, ind, selections, productions, valid)
end
