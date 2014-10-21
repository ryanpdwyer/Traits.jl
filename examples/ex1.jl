include("../src/Traits.jl")
using Traits
using Base.Test

# check some traits implemented in src/commontraits.jl
@assert traitcheck(Cmp{Int,Float64}) 
@assert traitcheck(Cmp{Int,String})==false

# make a new trait and add a type to it:
@traitdef MyTr{X,Y} begin
    foobar(X,Y) -> Bool
end
type A
    a
end
foobar(a::A, b::A) = a.a==b.a
@assert traitcheck(MyTr{A,A})  # true
@assert traitcheck(MyTr{Int,Int})==false

# make a function which dispatches on traits:
@traitfn ft1{X,Y; Cmp{X,Y}}(x::X,y::Y)  = x>y ? 5 : 6
@traitfn ft1{X,Y; MyTr{X,Y}}(x::X,y::Y) = foobar(x,y) ? -99 : -999

ft1(4,5)  # 6
ft1(A(5), A(6)) # -999

# # dispatch on traits has its pitfalls:
# @traitfn ft1{X,Y; Arith{X,Y}}(x::X,y::Y) = x+y

# # now it's impossible to decide which method of ft1 to pick
# @test_throws TraitException ft1(4,5)

@test_throws TraitException ft1("asdf", 5)
foobar(a::String, b::Int) = length(a)==b
ft1("asdf", 5)

## dispatch using subtraits
@traitdef MyTr2{X,Y} <: MyTr{X,Y} begin
    bar(X,Y) -> Bool
end

@traitfn gt1{X,Y; MyTr2{X,Y}}(x::X,y::Y)  = "MyTr2"
@traitfn gt1{X,Y; MyTr{X,Y}}(x::X,y::Y)   = "MyTr"

type B1
    a
end
foobar(a::B1, b::B1) = a.a==b.a
type B2
    a
end
foobar(a::B2, b::B2) = a.a==b.a
bar(a::B2, b::B2) = a.a==b.a
@assert traitcheck(MyTr{B1,B1})  # true
@assert traitcheck(MyTr2{B1,B1})==false
@assert traitcheck(MyTr2{B2,B2})

@test gt1(B1(1), B1(1))=="MyTr"
@test gt1(B2(1), B2(1))=="MyTr2" 
