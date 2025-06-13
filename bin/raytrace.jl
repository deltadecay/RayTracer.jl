
using RayTracer



function main(args)

    w = World()

    build(w)
    renderscene(w)


end




if @isdefined(var"@main")
    #println("@main")
    (@main)
else
    #println("exit main")
    exit(main(ARGS))
end