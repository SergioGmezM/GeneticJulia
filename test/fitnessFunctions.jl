"""
    countBinaryOnes(ind::Individual)

documentation
"""
function countBinaryOnes(genotype::GeneticJulia.BinaryGenotype)
    genotype = genotype._representation
    tam = length(genotype)
    count=0
    for i=1:tam
        if genotype[i]==1
            count+=1
        end
    end
    return count
end # function


function nNodes(canonicalgp::GeneticJulia.GPGenotype, gpInfo)
    length(canonicalgp._representation)
end
