input = readlines("input/12.txt")
data = reduce(hcat, collect.(input))

function neighbors(index)
    [Tuple(index)...] |>
    G -> map(x -> G .- x, [[1, 0], [0, 1]]) |>
         G -> map(x -> CartesianIndex(x...), G) |>
              G -> filter(x -> checkbounds(Bool, data, x), G)
end

function all_neighbors(index)
    [Tuple(index)...] |>
    G -> map(x -> G .+ x, [[1, 0], [0, 1], [-1, 0], [0, -1]]) |>
         G -> map(x -> CartesianIndex(x...), G)
end

regions = Dict{Char,Vector{Set{CartesianIndex{2}}}}([c => [] for c in data])
for index in CartesianIndices(data)
    c = data[index]
    c_regions = regions[c]
    adj = filter(i -> data[i] == c, neighbors(index))
    mask = [i in s for s in c_regions, i in adj]
    if !any(mask)
        push!(c_regions, Set([index]))
    elseif count(mask) == 1
        (s, _) = Tuple(findfirst(mask))
        push!(c_regions[s], index)
    else # Both neighbors are in sets, might need to merge if they're in different sets
        @assert count(mask) == 2 # each neighbor should be in only one set, one hopes...
        is = Tuple.(findall(mask))
        (s1, _), (s2, _) = is[1], is[2]
        push!(c_regions[s1], index)
        if s1 != s2 # Merge!! :D
            union!(c_regions[s1], c_regions[s2])
            deleteat!(c_regions, s2)
        end
    end
end
# Bit of a mess, but I'm pretty sure that actually worked!

function compute_perimeter(s)
    perimeter = 0
    for i in s
        for i2 in all_neighbors(i)
            if !(i2 in s)
                perimeter += 1
            end
        end
    end
    return perimeter
end

areas = Dict{Char,Vector{Int}}([c => length.(v) for (c, v) in regions])
@assert all([sum(v) == count(==(c), data) for (c, v) in areas])  # AT LEAST have the right number of each character
perimeters = Dict{Char,Vector{Int}}([c => compute_perimeter.(v) for (c, v) in regions])

begin
    result = 0
    for c in keys(regions), i in eachindex(regions[c])
        result += areas[c][i] * perimeters[c][i]
    end
    println(result)
end