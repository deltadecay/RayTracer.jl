


traceray(::AbstractTracer, w::AbstractWorld, ray::Ray) = RGBColor(0.0, 0.0, 0.0)
world(::AbstractTracer) = error("No world in tracer")


#=
struct SingleSphereTracer <: AbstractTracer
end
world(tracer::SingleSphereTracer) = tracer.world


function traceray(tracer::SingleSphereTracer, ray::Ray)
    w = world(tracer)
    hitrec = hit(w.sphere, ray)
    return shading(hitrec, w.background)
end
=#

struct MultipleObjectsTracer <: AbstractTracer
end
#world(tracer::MultipleObjectsTracer) = tracer.world

function traceray(tracer::MultipleObjectsTracer, w::AbstractWorld, ray::Ray)
    #w = world(tracer)
    #hitrec = hit(w.sphere, ray)
    sr = hitbarebonesobjects(w, ray)
    if sr.did_hit
        return sr.color
    end
    #return shading(hitrec, w.background)
    return w.background
end


