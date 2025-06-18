
#=
struct Point3D <: FieldVector{3, Float64}
    x::Float64
    y::Float64
    z::Float64
end

struct Vector3D <: FieldVector{3, Float64}
    x::Float64
    y::Float64
    z::Float64
end
=#



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
red(c::RGBColor) = c.r
green(c::RGBColor) = c.g
blue(c::RGBColor) = c.b

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

shading(::Nothing, defaultcolor::RGBColor) = defaultcolor
shading(hitrec::HitRec, ::RGBColor) = hitrec.sr.color

abstract type AbstractGeometry
end



hit(geom::AbstractGeometry, ray::Ray)::Union{Nothing,HitRec} = error("Not implemented for " * typeof(geom))


struct Plane <: AbstractGeometry
    point::Point3D
    normal::Normal
    
    color::RGBColor
end

function hit(plane::Plane, ray::Ray)::Union{Nothing,HitRec}
    t = dot((plane.point - ray.o), plane.normal)/ (dot(ray.d, plane.normal))

    if t > kEpsilon
        hitpoint = ray.o + t * ray.d
        sr = ShadeRec(true, hitpoint, plane.normal, plane.color)
        return HitRec(t, sr)
    end
    return nothing
end

struct Sphere <: AbstractGeometry
    center::Point3D
    radius::Float64
    
    color::RGBColor
end

function hit(sphere::Sphere, ray::Ray)::Union{Nothing,HitRec}
    temp = ray.o - sphere.center
    a = dot(ray.d, ray.d)
    b = 2 * dot(temp, ray.d)
    c = dot(temp, temp) - sphere.radius * sphere.radius
    disc = b * b - 4.0 * a * c

    if disc >= 0.0
        e = sqrt(disc)
        denom = 2.0 * a
        t = (-b - e) / denom

        if t > kEpsilon
            hitpoint = ray.o + t * ray.d
            normal = (temp + t * ray.d) / sphere.radius
            sr = ShadeRec(true, hitpoint, normal, sphere.color)
            return HitRec(t, sr)
        end

        t = (-b + e) / denom

        if t > kEpsilon
            hitpoint = ray.o + t * ray.d
            normal = (temp + t * ray.d) / sphere.radius
            sr = ShadeRec(true, hitpoint, normal, sphere.color)
            return HitRec(t, sr)
        end
    end
    return nothing
end
