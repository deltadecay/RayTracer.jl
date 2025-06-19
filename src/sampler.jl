

abstract type AbstractSamplingMethod end

struct Regular <: AbstractSamplingMethod
end

struct PureRandom <: AbstractSamplingMethod
end

struct Jittered <: AbstractSamplingMethod
end

struct NRooks <: AbstractSamplingMethod
end

struct MultiJittered <: AbstractSamplingMethod
end

struct Hammersley <: AbstractSamplingMethod 
end



generatesamples(method::AbstractSamplingMethod, numsamples::Int, numsets::Int) = error("generatesamples() not implemented for " * typeof(method))

function generatesamples(::Regular, numsamples::Int, numsets::Int)
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



function generatesamples(::PureRandom, numsamples::Int, numsets::Int)
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


function generatesamples(::Jittered, numsamples::Int, numsets::Int)
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


function generatesamples(::NRooks, numsamples::Int, numsets::Int)
    samples = Vector{Point2D}(undef, numsamples * numsets)
    i = 1
    # first generate samples on diagonal
    for _ in 1:numsets
        for j in 1:numsamples
            samples[i] = Point2D((j-1 + rand(Float64)) / numsamples, (j-1 + rand(Float64)) / numsamples)
            i = i + 1
        end
    end
    
    # shuffle x-coordinates
    for p in 1:numsets
        for i in 1:numsamples-1
            target = mod1(rand(Int64), numsamples) + (p-1) * numsamples
            src = samples[i + (p-1)*numsamples + 1]
            dest = samples[target]
            samples[i + (p-1)*numsamples + 1] = Point2D(dest.x, src.y)
            samples[target] = Point2D(src.x, dest.y)
        end
    end
    
    # shuffle y-coordinates
    for p in 1:numsets
        for i in 1:numsamples-1
            target = mod1(rand(Int64), numsamples) + (p-1) * numsamples
            src = samples[i + (p-1)*numsamples + 1]
            dest = samples[target]
            samples[i + (p-1)*numsamples + 1] = Point2D(src.x, dest.y)
            samples[target] = Point2D(dest.x, src.y)
        end
    end
    
    return samples
end

function _phi(j::Int)
    x = 0.0
    f = 0.5
    while j > 0
        x = x + f * Float64(j & 1)
        j = j >> 1
        f = f * 0.5
    end
    return x
end

function generatesamples(::Hammersley, numsamples::Int, numsets::Int)
    samples = Vector{Point2D}(undef, numsamples * numsets)
    i = 1
    for _ in 1:numsets
        for j in 1:numsamples
            samples[i] = Point2D((j-1) / numsamples, _phi(j-1))
            i = i + 1
        end
    end
    return samples
end


#=
# test generatesamples
img = fill(RGB{Float64}(1,1,1), (160,160));
is = [(Int(trunc(p.x))+1,Int(trunc(p.y))+1) for p in (160 * generatesamples(Hammersley(), 256, 1))]
for i in is
    img[i...] = RGB{Float64}(0,0,0)
end
img
=#

mutable struct Sampler
    numsamples::Int16
    numsets::Int16
    samples::Vector{Point2D}
    shuffledindices::Vector{Int16}
    # mutable state vars below
    count::Int64
    jump::Int64
end

function Sampler(numsamples::Int, method::AbstractSamplingMethod=Regular(); numsets::Int=83)
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
    if mod1(s.count, s.numsamples) == 1
        s.jump = mod(rand(Int64), s.numsets) * s.numsamples
    end
    #p = s.samples[s.jump + mod1(s.count, s.numsamples)]
    p = s.samples[s.jump + s.shuffledindices[s.jump + mod1(s.count, s.numsamples)]]
    s.count = s.count + 1
    return p
end


