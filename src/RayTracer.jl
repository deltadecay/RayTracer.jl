
module RayTracer

using StaticArrays
using LinearAlgebra
using Random
#using ColorTypes
#using ColorVectorSpace

export Point2D, Point3D, Vector3D, Normal, Point4D, Vector4D, Matrix4x4, RGBColor

export Ray, ShadeRec, HitRec, AbstractGeometry, Plane, Sphere, hit

export AbstractSamplingMethod, Regular, PureRandom, Jittered, NRooks, MultiJittered, Hammersley,
    Sampler, num_samples, sample_unit_square!

export AbstractTracer, MultipleObjectsTracer, traceray

export Viewport, AbstractWorld, World, buildworld, renderscene, displaypixel



const kEpsilon = 0.00001

include("types.jl")
include("hit.jl")
include("sampler.jl")
include("tracer.jl")
include("world.jl")




end