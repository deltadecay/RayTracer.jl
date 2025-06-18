
using RayTracer
using ColorTypes
using Images
using FileIO

Base.convert(::Type{RGB{Float64}}, color::RGBColor) = RGB{Float64}(red(color), green(color.g), blue(color.b))

function main(args)

    w = buildworld()
    tracer = SingleSphereTracer(w)
    renderscene(tracer)

  
    imgrgb = convert.(RGB{Float64}, w.vp.pixels)

    save("test.png", imgrgb)
end




if @isdefined(var"@main")
    #println("@main")
    (@main)
else
    #println("exit main")
    exit(main(ARGS))
end