input = readlines("input/10.txt")
data = parse.(Int, reduce(hcat, collect.(input)))

trailheads = findall(==(0), data)

function neighbors(position)
    pos = [Tuple(position)...]
    return map(x -> CartesianIndex(x...), [pos .+ [0, 1], pos .+ [1, 0], pos .- [0, 1], pos .- [1, 0]])
end

function recursive_search(position)
    height = data[position]
    if height == 9
        return Set([position])
    end
    accum = Set()
    for neighbor in neighbors(position)
        if checkbounds(Bool, data, neighbor) && data[neighbor] == height + 1
            union!(accum, recursive_search(neighbor))
        end
    end
    return accum
end

begin
    result = 0
    for trailhead in trailheads
        result += length(recursive_search(trailhead))
    end
    println(result)
end
