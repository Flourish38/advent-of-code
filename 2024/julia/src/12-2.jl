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

function has_adjacent(i, s)
    any(n in s for n in all_neighbors(i))
end

function compute_sides(s)
    # The insight here is that the orientation of the side being equal is equivalent to
    # the surface being adjacent and the outside being adjacent.
    # So, each side is a set of surface indices and a set of outside indices.
    sides = Vector{NTuple{2,Set{CartesianIndex{2}}}}()
    for i in s
        for i2 in filter(x -> !(x in s), all_neighbors(i))
            mask = [has_adjacent(i, s1) && has_adjacent(i2, s2) for (s1, s2) in sides]
            if !any(mask)
                push!(sides, (Set([i]), Set([i2])))
            else
                side = findfirst(mask)
                push!(sides[side][1], i)
                push!(sides[side][2], i2)
                if count(mask) > 1  # same side meeting in the middle, needs to be merged (maybe unnecessary with ordered set but idk and this works)
                    for other_side in reverse(findall(mask)[2:end])
                        union!(sides[side][1], sides[other_side][1])
                        union!(sides[side][2], sides[other_side][2])
                        deleteat!(sides, other_side)
                    end
                end
            end
        end
    end
    return length(sides)
end

areas = Dict{Char,Vector{Int}}([c => length.(v) for (c, v) in regions])
@assert all([sum(v) == count(==(c), data) for (c, v) in areas])  # AT LEAST have the right number of each character
sides = Dict{Char,Vector{Int}}([c => compute_sides.(v) for (c, v) in regions])

begin
    result = 0
    for c in keys(regions), i in eachindex(regions[c])
        result += areas[c][i] * sides[c][i]
    end
    println(result)
end