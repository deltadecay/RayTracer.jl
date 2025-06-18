

abstract type AbstractTracer end

traceray(::AbstractTracer, ray::Ray) = RGBColor(0.0, 0.0, 0.0)
world(::AbstractTracer) = error("No world in tracer")



struct SingleSphereTracer <: AbstractTracer
    world::World
end
world(tracer::SingleSphereTracer) = tracer.world


function traceray(tracer::SingleSphereTracer, ray::Ray)
    w = world(tracer)
    hitrec = hit(w.sphere, ray)
    return shading(hitrec, w.background)
end




function renderscene(tracer::AbstractTracer)

    w = world(tracer)
    vp = w.vp
    zw = 100.0

    

    for r in Base.OneTo(vp.vres)
        for c in Base.OneTo(vp.hres)
            x = vp.s * (c-1 - 0.5 * (vp.hres - 1.0))
            y = vp.s * (r-1 - 0.5 * (vp.vres - 1.0))
            ray = Ray(Point3D(x, y, zw), Vector3D(0, 0, -1))
            color = traceray(tracer, ray)
            displaypixel(vp, r, c, color)
        end
    end

end


