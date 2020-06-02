"""
    kPointRecombinationCross(parent1::GEPGenotype, parent2::GEPGenotype,
                            gpExperimentInfo::GEPInfo, rng::Random.AbstractRNG,
                            k::Integer=1)

documentation
"""
function kPointRecombinationCross(parent1::GEPGenotype, parent2::GEPGenotype,
                                  gpExperimentInfo::GEPInfo, rng::Random.AbstractRNG,
                                  k::Integer=1)

    if k < 1
        error("k_points ($k) should be greater than 0")
    end

    parent1Rep = parent1._representation
    parent2Rep = parent2._representation
    genotypeLen = length(parent1Rep)
    if k > genotypeLen
        error("k_points ($k) should be minor than the size of the genoytpe ($genotypeLen)")
    end

    child1 = Array{Node}(undef, genotypeLen)
    child2 = Array{Node}(undef, genotypeLen)

    points = Array{Integer}(undef, k+2)
    points[1] = 1
    points[end] = genotypeLen

    for i=1:k
        points[i+1] = (rand(rng, UInt16) % genotypeLen) + 1
    end

    points = sort(points)

    for i=1:k
        indexes = points[i]:points[i+1]-1
        if isodd(i)
            child1[indexes] = parent1Rep[indexes]
            child2[indexes] = parent2Rep[indexes]
        else
            child1[indexes] = parent2Rep[indexes]
            child2[indexes] = parent1Rep[indexes]
        end
    end

    indexes = points[k+1]:points[k+2]
    if isodd(k)
        child1[indexes] = parent2Rep[indexes]
        child2[indexes] = parent1Rep[indexes]
    else
        child1[indexes] = parent1Rep[indexes]
        child2[indexes] = parent2Rep[indexes]
    end

    return [GEPGenotype(child1), GEPGenotype(child2)]
end



"""
    onePointRecombinationCross(parent1::GEPGenotype, parent2::GEPGenotype,
                               rng::Random.AbstractRNG)

documentation
"""
function onePointRecombinationCross(parent1::GEPGenotype, parent2::GEPGenotype,
                                    rng::Random.AbstractRNG)

    return kPointRecombinationCross(parent1, parent2, rng)
end
