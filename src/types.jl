


const Point2D = SVector{2, Float64}

const Point3D = SVector{3, Float64}
const Vector3D = SVector{3, Float64}
const Normal = SVector{3, Float64}

const Point4D = SVector{4, Float64}
const Vector4D = SVector{4, Float64}

const Matrix4x4 = SMatrix{4, 4, Float64}

#Base.:+(p::Point3D, v::Vector3D) = Point3D(p.x + v.x, p.y + v.y, p.z + v.z)

struct RGBColor <: FieldVector{3, Float64}
    r::Float64
    g::Float64
    b::Float64
end

struct Ray
    o::Point3D
    d::Vector3D
end





struct ShadeRec
    did_hit::Bool
    local_hit_point::Point3D
    normal::Normal
    color::RGBColor
    #world::World
end

struct HitRec
    t::Float64
    sr::ShadeRec
end

#=
shading(::Nothing, defaultcolor::RGBColor) = defaultcolor
function shading(hitrec::HitRec, defaultcolor::RGBColor) 
    if hitrec.sr.did_hit
        return hitrec.sr.color
    end
    return defaultcolor
end
=#

abstract type AbstractGeometry
end





struct Plane <: AbstractGeometry
    point::Point3D
    normal::Normal
    
    color::RGBColor
end


struct Sphere <: AbstractGeometry
    center::Point3D
    radius::Float64
    
    color::RGBColor
end

struct Sinusoid <: AbstractGeometry
    size::Point2D
    lowleft::Point2D
    topright::Point2D
end


const Geometry = Union{Plane,Sphere,Sinusoid}