

# Viewport has pixels with resolution hres x vres
# rows bottom to top  = 1 to vres
# columns left to right = 1 to hres
@kwdef struct Viewport
    hres::Int64 = 200
    vres::Int64 = 200
    s::Float64 = 1.0 # pixel size
    oogamma::Float64 = 1.0 # 1.0/gamma
    show_out_of_gamut::Bool = false
    num_samples::Int64 = 1
    pixels::Matrix{RGBColor} = Matrix{RGBColor}(undef, (vres, hres))
end


function displaypixel(vp::Viewport, row::Int, col::Int, color::RGBColor)

    r = color.r
    g = color.g
    b = color.b
    
    #=
    if vp.show_out_of_gamut
        if r > 1.0 || g > 1.0 || b > 1.0
            # Debug our of gamut colors as red
            color = RGBColor(1.0, 0.0, 0.0)
        end
    else
        maxval = max(r, g, b)
        color = color / maxval
    end
    =#

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


struct World
    vp::Viewport
    background::RGBColor
    geometries::Vector{AbstractGeometry}
end

addgeometry(world::World, geom::AbstractGeometry) = push!(world.geometries, geom)

function hitbarebonesobjects(world::World, ray::Ray)

    sr = ShadeRec(false, Point3D(0,0,0), Normal(0,0,0), RGBColor(0,0,0))
    tmin = typemax(Float64)
    for geom in world.geometries
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
    vp = Viewport(; hres=300, vres=300, oogamma = 1.0/gamma, num_samples = 16)
    geoms = Vector{AbstractGeometry}();
    w = World(vp, backroundcolor, geoms)


    sphere = Sphere(Point3D(0, -25, 0), 80.0, RGBColor(1, 0, 0))
    addgeometry(w, sphere)

    sphere = Sphere(Point3D(0, 30, 0), 60.0, RGBColor(1, 1, 0))
    addgeometry(w, sphere)

    plane = Plane(Point3D(0, 0, 0), Normal(0, 1, 1), RGBColor(0, 0.3, 0))
    addgeometry(w, plane)

    return w
end

