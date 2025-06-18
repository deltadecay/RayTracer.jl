

abstract type AbstractTracer end

traceray(::AbstractTracer, ray::Ray) = RGBColor(0.0, 0.0, 0.0)
world(::AbstractTracer) = error("No world in tracer")


#=
struct SingleSphereTracer <: AbstractTracer
    world::World
end
world(tracer::SingleSphereTracer) = tracer.world


function traceray(tracer::SingleSphereTracer, ray::Ray)
    w = world(tracer)
    hitrec = hit(w.sphere, ray)
    return shading(hitrec, w.background)
end
=#

struct MultipleObjectsTracer <: AbstractTracer
    world::World
end
world(tracer::MultipleObjectsTracer) = tracer.world

function traceray(tracer::MultipleObjectsTracer, ray::Ray)
    w = world(tracer)
    #hitrec = hit(w.sphere, ray)
    sr = hitbarebonesobjects(w, ray)
    if sr.did_hit
        return sr.color
    end
    #return shading(hitrec, w.background)
    return w.background
end



function renderscene(tracer::AbstractTracer)

    w = world(tracer)
    vp = w.vp
    zw = 100.0
    n = Int64(trunc(sqrt(vp.num_samples)))
    for r in Base.OneTo(vp.vres)
        for c in Base.OneTo(vp.hres)
            color = RGBColor(0, 0, 0)

            #=
            for p in Base.OneTo(n)
                for q in Base.OneTo(n)
                    #x = vp.s * (c-1 - 0.5 * (vp.hres - 1.0))
                    #y = vp.s * (r-1 - 0.5 * (vp.vres - 1.0))
                    x = vp.s * (c-1 - 0.5 * vp.hres + (q + 0.5) / n)
                    y = vp.s * (r-1 - 0.5 * vp.vres + (p + 0.5) / n)
                    ray = Ray(Point3D(x, y, zw), Vector3D(0, 0, -1))
                    color = color + traceray(tracer, ray)
                end
            end
            =#
            # Random sampling
            for p in Base.OneTo(vp.num_samples)
                    x = vp.s * (c-1 - 0.5 * vp.hres + rand(Float64))
                    y = vp.s * (r-1 - 0.5 * vp.vres + rand(Float64))
                    ray = Ray(Point3D(x, y, zw), Vector3D(0, 0, -1))
                    color = color + traceray(tracer, ray)
            end
            color = color / vp.num_samples
            displaypixel(vp, r, c, color)
        end
    end

end


