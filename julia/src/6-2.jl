using ProgressMeter

input = readlines("input/6.txt")
data = reduce(hcat, collect.(input))

directions = "^>v<"
direction_encodings = [0 -1; 1 0; 0 1; -1 0]

begin
    result = 0
    @showprogress for pos in eachindex(data)
        if contains("#" * directions, data[pos])
            continue
        end
        data[pos] = '#'

        guard_pos = [Tuple(findfirst(x -> contains(directions, x), data))...]
        guard_dir = findfirst(==(data[CartesianIndex(guard_pos...)]), directions)

        visited_positions = Set([[guard_pos..., guard_dir]])
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
                guard_pos = next_pos
            end
            if [guard_pos..., guard_dir] in visited_positions
                # If we've already been in the same position and direction, we're looping!
                result += 1
                break
            end
            push!(visited_positions, [guard_pos..., guard_dir])
        end

        data[pos] = '.'
    end
    println(result)
end