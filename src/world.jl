

# Viewport has pixels with resolution hres x vres
# rows bottom to top  = 1 to vres
# columns left to right = 1 to hres
@kwdef struct Viewport
    hres::Int64 = 200
    vres::Int64 = 200
    s::Float64 = 1.0 # pixel size
    oogamma::Float64 = 1.0 # 1.0/gamma
    show_out_of_gamut::Bool = false
    sampler::Sampler = Sampler(1, Regular())
    pixels::Matrix{RGBColor} = Matrix{RGBColor}(undef, (vres, hres))
end


function displaypixel(vp::Viewport, row::Int, col::Int, color::RGBColor)

    r = color.r
    g = color.g
    b = color.b
    
    
    if vp.show_out_of_gamut
        if r > 1.0 || g > 1.0 || b > 1.0
            # Debug our of gamut colors as red
            color = RGBColor(1.0, 0.0, 0.0)
        end
    else
        maxval = max(r, g, b)
        if maxval > 1.0
            color = color / maxval
        end
    end
    

    oog = vp.oogamma
    if oog != 1.0
        #color = RGBColor(r^oog, g^oog, b^oog)
        color = color .^ oog
    end
    #color = clamp01(color)

    # Note! rows in the viewport are number 1 tovres (bottom to top)
    # But the actual pixels in the image are reversed vertically,
    # 1 is top row and vres is bottom row
    vp.pixels[vp.vres + 1 - row, col] = color
end


struct World{T<:AbstractTracer} <: AbstractWorld
    vp::Viewport
    tracer::T
    background::RGBColor
    geometries::Vector{Geometry}
end

addgeometry(world::World, geom::AbstractGeometry) = push!(world.geometries, geom)

function hitbarebonesobjects(world::World, ray::Ray)

    sr = ShadeRec(false, Point3D(0,0,0), Normal(0,0,0), RGBColor(0,0,0))
    tmin = typemax(Float64)
    @inbounds for i in eachindex(world.geometries)
        geom = world.geometries[i]
        hitrec = hit(geom, ray)
        if !isnothing(hitrec) && hitrec.t < tmin
            tmin = hitrec.t
            sr = hitrec.sr
        end
    end
    return sr
end

function buildworld()::World

    backroundcolor = RGBColor(0.0, 0.0, 0.0)
    gamma = 1.0 #1.8 #2.2
    #pixels = fill(backroundcolor, (vres, hres))
    #vp = Viewport(; hres=300, vres=300, s = 1.0, oogamma = 1.0/gamma, show_out_of_gamut = false, num_samples = 16, pixels)
    vp = Viewport(; hres=300, vres=300, oogamma = 1.0/gamma, sampler = Sampler(1, Regular()))
    geoms = Vector{Geometry}();
    tracer = MultipleObjectsTracer()
    w = World(vp, tracer, backroundcolor, geoms)

#=
    sphere = Sphere(Point3D(0, -25, 0), 80.0, RGBColor(1, 0, 0))
    addgeometry(w, sphere)

    sphere = Sphere(Point3D(0, 30, 0), 60.0, RGBColor(1, 1, 0))
    addgeometry(w, sphere)

    plane = Plane(Point3D(0, 0, 0), Normal(0, 1, 1), RGBColor(0, 0.3, 0))
    addgeometry(w, plane)
=#
    #addgeometry(w, Sinusoid(Point2D(vp.hres * vp.s, vp.vres * vp.s), Point2D(0,0), Point2D(3.79, 3.79)))
    addgeometry(w, Sinusoid(Point2D(vp.hres * vp.s, vp.vres * vp.s), Point2D(0,0), Point2D(10.83, 10.83)))
    return w
end


function renderscene(world::World)

    tracer = world.tracer
    vp = world.vp
    zw = 100.0
    #n = Int64(trunc(sqrt(vp.num_samples)))
    ns = num_samples(vp.sampler)
    oons = 1 / ns
    @inbounds for r in 1:vp.vres
        for c in 1:vp.hres
            color = RGBColor(0, 0, 0)

            #=
            # Regular sampling
            for p in Base.OneTo(n)
                for q in Base.OneTo(n)
                    #x = vp.s * (c-1 - 0.5 * (vp.hres - 1.0))
                    #y = vp.s * (r-1 - 0.5 * (vp.vres - 1.0))
                    x = vp.s * (c-1 - 0.5 * vp.hres + (q-1 + 0.5) / n)
                    y = vp.s * (r-1 - 0.5 * vp.vres + (p-1 + 0.5) / n)
                    ray = Ray(Point3D(x, y, zw), Vector3D(0, 0, -1))
                    color = color + traceray(tracer, ray)
                end
            end
            =#
            #=
            # Random sampling
            for p in Base.OneTo(vp.num_samples)
                    x = vp.s * (c-1 - 0.5 * vp.hres + rand(Float64))
                    y = vp.s * (r-1 - 0.5 * vp.vres + rand(Float64))
                    ray = Ray(Point3D(x, y, zw), Vector3D(0, 0, -1))
                    color = color + traceray(tracer, ray)
            end
            =#
            for _ in 1:ns
                sp = sample_unit_square!(vp.sampler)
                x = vp.s * (c-1 - 0.5 * vp.hres + sp.x)
                y = vp.s * (r-1 - 0.5 * vp.vres + sp.y)
                ray = Ray(Point3D(x, y, zw), Vector3D(0, 0, -1))
                color = color + traceray(tracer, world, ray)
            end
            color = color * oons
            displaypixel(vp, r, c, color)
        end
    end

end



