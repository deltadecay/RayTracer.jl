
using RayTracer
using ColorTypes
using Images
using FileIO
using Random

Base.convert(::Type{RGB{Float64}}, color::RGBColor) = RGB{Float64}(color.r, color.g, color.b)

function main(args)

    Random.seed!(137)
    w = buildworld()
    renderscene(w)

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