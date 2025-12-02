input = readlines("input/6.txt")
data = reduce(hcat, collect.(input))



begin
    directions = "^>v<"
    guard_pos = [Tuple(findfirst(x -> contains(directions, x), data))...]
    guard_dir = findfirst(==(data[CartesianIndex(guard_pos...)]), directions)
    direction_encodings = [0 -1; 1 0; 0 1; -1 0]

    visited_positions = Set([guard_pos])
    while true
        next_pos = guard_pos .+ direction_encodings[guard_dir, :]
        ci_next_pos = CartesianIndex(next_pos...)
        if !checkbounds(Bool, data, ci_next_pos)
            break
        elseif data[ci_next_pos] == '#'
            # Change direction
            guard_dir += 1
            if !checkbounds(Bool, directions, guard_dir)
                guard_dir = firstindex(directions)
            end
        else
            # Move guard
            push!(visited_positions, next_pos)
            guard_pos = next_pos
        end
    end
    println(length(visited_positions))
end