
using StaticArrays
using LinearAlgebra

v1 = SVector{3, Float64}(1,1,0)
v2 = SVector{3, Float64}(0,1,1)

# Length of vector, ie number of elements
length(v1)
size(v1)


# ' transpose
len1 = sqrt(v1' * v1)

# \cdot require LineaAlgebra
len2 = sqrt(v1 ⋅ v1)
# dor requires LinearAlgebra
sqrt(dot(v1, v1))

# norm require LinearAlgebra
norm(v1)

# This is marked internal, may be changed/removed in the future
LinearAlgebra.norm_sqr(v1)

cross(v1, v2)

normalize(v1)


# Identity
m = SMatrix{4, 4, Float64}(1I)
# the elements are given in column-major order, ie. first 4 elements makes the
# first column
m = SMatrix{4, 4, Float64}(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 5, -1, 2, 1)
# Same as above, but using maccro to spec row.major order
m2 = @SMatrix [1.0 0 0 5; 0 1 0 -1; 0 0 1 2; 0 0 0 1]
# convenience constructor
SA_F64[1 0 0 5; 0 1 0 -1; 0 0 1 2; 0 0 0 1]

# column
m[:, 4]
#view(m, :, 4)

p = SVector{4, Float64}(0, 0, 0, 1)
p1 = m * p
invm = inv(m)

invm * p1

# orthonormalized columns
#qr(m).Q
#qr(invm).Q

f(x) = (x[1]+x[2])+(x[3]+x[4])

v2 = SVector{4}(1, 2, 3, 4)
@code_llvm debuginfo=:none f(v2)

#NTuple{4, VecElement{Float64}}()
a = ntuple(i->VecElement(i), 4)
@code_llvm debuginfo=:none f(a)


struct LatLon <: FieldVector{2, Float64}
    lat::Float64
    lon::Float64
end

loc1 = LatLon(60, 20)
loc1.lat
loc1[1]

va = SVector{4, Float64}(5, 0, 0, 0)
vb = SVector{4, Float64}(0, 1, 0, 0)

@code_llvm debuginfo=:none va + vb



using ColorTypes
using Images
img_rgb = rand(RGB, 10, 10)

using FileIO
using ImageIO
save("test.png", img_rgb)


