
module RayTracer

using StaticArrays
using LinearAlgebra
#using ColorTypes
#using ColorVectorSpace

export Point2D, Point3D, Vector3D, Normal, Point4D, Vector4D, Matrix4x4, RGBColor, red, green, blue

export Ray, ShadeRec, HitRec, AbstractGeometry, Plane, Sphere, shading, hit


export Viewport, World, buildworld, displaypixel

export AbstractTracer, SingleSphereTracer, traceray, renderscene


const kEpsilon = 0.00001

include("types.jl")
include("world.jl")

include("tracer.jl")



end