
using RayTracer
using Test
using Aqua


function write_test_config()

end


@testset "RayTracer" begin

    # Before any tests, write a test config
    write_test_config()


    @testset "Aqua.jl" begin
        Aqua.test_all(
            RayTracer;
            #ambiguities=(exclude=[SomePackage.some_function], broken=true),
            #stale_deps=(ignore=[:ProgressMeter, :Getopt],),
            #deps_compat=(ignore=[:SomeOtherPackage],),
            #piracies=true,
        )
    end

    include("test_world.jl")

end
