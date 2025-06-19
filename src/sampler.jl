

abstract type AbstractSamplingMethod end

generatesamples(method::AbstractSamplingMethod, numsamples, numsets) = error("generatesamples() not implemented for " * typeof(method))

struct Regular <: AbstractSamplingMethod
end

function generatesamples(::Regular, numsamples, numsets)
    samples = Vector{Point2D}(undef, numsamples * numsets)
    n = Int16(trunc(sqrt(numsamples)))
    i = 1
    for _ in 1:numsets
        for y in 1:n
            for x in 1:n
                samples[i] = Point2D((x-1 + 0.5) / n, (y-1 + 0.5) / n)
                i = i + 1
            end
        end
    end
    return samples
end


struct PureRandom <: AbstractSamplingMethod
end

function generatesamples(::PureRandom, numsamples, numsets)
    samples = Vector{Point2D}(undef, numsamples * numsets)
    n = Int16(trunc(sqrt(numsamples)))
    i = 1
    for _ in 1:numsets
        for _ in 1:n
            for _ in 1:n
                samples[i] = Point2D(rand(Float64), rand(Float64))
                i = i + 1
            end
        end
    end
    return samples
end

struct Jittered <: AbstractSamplingMethod
end

function generatesamples(::Jittered, numsamples, numsets)
    samples = Vector{Point2D}(undef, numsamples * numsets)
    n = Int16(trunc(sqrt(numsamples)))
    i = 1
    for _ in 1:numsets
        for y in 1:n
            for x in 1:n
                samples[i] = Point2D((x-1 + rand(Float64)) / n, (y-1 + rand(Float64)) / n)
                i = i + 1
            end
        end
    end
    return samples
end

struct NRooks <: AbstractSamplingMethod
end

struct MultiJittered <: AbstractSamplingMethod
end

struct Hammersley <: AbstractSamplingMethod
end


mutable struct Sampler
    numsamples::Int16
    numsets::Int16
    samples::Vector{Point2D}
    shuffledindices::Vector{Int16}
    # mutable state vars below
    count::Int64
    jump::Int64
end

function Sampler(numsamples, method::AbstractSamplingMethod=Regular(); numsets=83)
    samples = generatesamples(method, numsamples, numsets)
    # Create numsets sets of samples with numsamples 2D points
    shuffledindices = repeat(1:numsamples, outer=numsets)
    for i in 1:numsets
        start = (i - 1) * numsamples + 1
        shuffle!(view(shuffledindices, start:(start + numsamples - 1)))
    end
    return Sampler(numsamples, numsets, samples, shuffledindices, 1, 0)
end

num_samples(s::Sampler) = s.numsamples
function sample_unit_square!(s::Sampler) 
    #p = s.samples[mod1(s.count, s.numsamples * s.numsets)]
    if(mod1(s.count, s.numsamples) == 1)
        s.jump = mod(rand(Int64), s.numsets) * s.numsamples
    end
    #p = s.samples[s.jump + mod1(s.count, s.numsamples)]
    p = s.samples[s.jump + s.shuffledindices[s.jump + mod1(s.count, s.numsamples)]]
    s.count = s.count + 1
    return p
end


