
hit(geom::AbstractGeometry, ray::Ray)::Union{Nothing,HitRec} = error("hit() not implemented for " * typeof(geom))


function hit(plane::Plane, ray::Ray)::Union{Nothing,HitRec}
    t = dot((plane.point - ray.o), plane.normal)/ (dot(ray.d, plane.normal))

    if t > kEpsilon
        hitpoint = ray.o + t * ray.d
        sr = ShadeRec(true, hitpoint, plane.normal, plane.color)
        return HitRec(t, sr)
    end
    return nothing
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


function hit(ss::Sinusoid, ray::Ray)::Union{Nothing,HitRec}

    sx = ss.size.x
    sy = ss.size.y

    w = ss.topright.x - ss.lowleft.x
    h = ss.topright.y - ss.lowleft.y

    mx = ss.lowleft.x + w / 2
    my = ss.lowleft.y + h / 2

    x = mx + (ray.o.x / sx) * w
    y = my + (ray.o.y / sy) * h
    z = 0.5 * (1 + sin(x*x*y*y))

    hitpoint = Point3D(x,y,z)
    sr = ShadeRec(true, hitpoint, Vector3D(0,0,1), RGBColor(z,z,z))
    return HitRec(0.0, sr)

end

