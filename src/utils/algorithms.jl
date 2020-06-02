"""
    basicExperiment(; genj::GeneticJuliaStructure = GenJ)

Runs a single experiment with the tools and methods specified in `genj`.

# Keyword Arguments
- `genj::GeneticJuliaStructure = GenJ`: the main structure. For `code user`: don't modify the default value unless multiple experiments are going to be run.

See also: [`run`](@ref)
"""
function basicExperiment(; genj::GeneticJuliaStructure = GenJ)

    initTime(genj)

    genPopulation!(genj)
    evaluate!(genj, genj._population)

    initBestFitness(genj)

    while !(reached(genj))

        saveResults(genj)

        selectedParents = selectParents(genj)

        offspring = cross(genj, selectedParents)
        mutatedOffspring = mutate(genj, offspring)

        evaluate!(genj, mutatedOffspring)

        replacePopulation!(genj, mutatedOffspring)
    end

    saveResults(genj)
end # function



"""
    SPEA(archiveSize::Integer, distanceFunction::Function=euclideanDistance; genj::GeneticJuliaStructure = GenJ)

documentation
"""
function SPEA(archiveSize::Integer, distanceFunction::Function=euclideanDistance; genj::GeneticJuliaStructure = GenJ)

    getDominant(population::Array{Individual}) = filter(x->getGlobalFitness(x)==1, population)

    function truncateArchive(archive::Array{Individual})

        k = round(Integer, sqrt(archiveSize + genj._generator._popSize))
        rest = length(archive) - archiveSize
        fitnesses = getFitness(archive)
        distanceMatrix = pairwiseDistance(fitnesses, fitnesses, distanceFunction)

        for i=1:rest
            nearestDistances = sum(distanceMatrix[1, getKnearest(distanceMatrix[1,:], k)])
            bestIndex = 1
            for j=2:size(distanceMatrix)[1]
                current = sum(distanceMatrix[j, getKnearest(distanceMatrix[j,:], k)])
                if current < nearestDistances
                    nearestDistances = current
                    bestIndex = j
                end
            end
            distanceMatrix = distanceMatrix[1:end .!= bestIndex, 1:end .!= bestIndex]
            archive = archive[1:end .!= bestIndex]
        end

        return archive
    end

    initTime(genj)
    genPopulation!(genj)
    evaluate!(genj, genj._population)

    initBestFitness(genj)

    archive = getDominant(genj._population)


    while !reached(genj)

        saveResults(genj)

        if length(archive) > archiveSize
            archive=truncateArchive(archive)
        end
        selectedParents = selectParents(genj, union(genj._population, archive))

        offspring = cross(genj, selectedParents)
        mutatedOffspring = mutate(genj, offspring)

        evaluate!(genj, mutatedOffspring)

        replacePopulation!(genj, mutatedOffspring)

        archive = getDominant(union(genj._population, archive))
    end

    saveResults(genj)
end # function
