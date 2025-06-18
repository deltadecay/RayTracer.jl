


struct Viewport
    hres::Int64
    vres::Int64
    s::Float64
    oogamma::Float64 # 1.0/gamma

    pixels::Matrix{RGBColor}
end

function displaypixel(vp::Viewport, r::Int, c::Int, color::RGBColor)
    oog = vp.oogamma
    if oog != 1.0
        color = RGBColor(red(color)^oog, green(color)^oog, blue(color)^oog)
    end

    #color = clamp01(color)

    vp.pixels[r, c] = color
end


struct World
    vp::Viewport
    background::RGBColor
    sphere::Sphere
end

function buildworld()::World

    hres = 200
    vres = 200
    backroundcolor = RGBColor(0.0, 0.0, 0.0)
    gamma = 1.0
    pixels = fill(backroundcolor, (vres, hres))
    vp = Viewport(hres, vres, 1.0, 1.0/gamma, pixels)

    sphere = Sphere(Point3D(0.0, 0.0, 0.0), 85.0, RGBColor(1.0, 0.0, 0.0))

    return World(vp, backroundcolor, sphere)
end

