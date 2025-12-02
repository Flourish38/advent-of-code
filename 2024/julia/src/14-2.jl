using HypothesisTests, UnicodePlots

input = readlines("input/14.txt")

regex = r"p=([\-0-9]+),([\-0-9]+) v=([\-0-9]+),([\-0-9]+)"

function print_timestep(timesteps)
    robots = map(input) do line
        px, py, vx, vy = parse.(Int, match(regex, line))
        p, v = [px, py], [vx, vy]
    end

    for (p, v) in robots
        p .= mod.((p .+ timesteps .* v), dims)
    end
    xs, ys = reduce(first.(robots), init=[[], []]) do (xs, ys), (x, y)
        push!(xs, x)
        push!(ys, y)
        xs, ys
    end
    println(scatterplot(xs, ys, xlim=(0, dims[1]), ylim=(0, dims[2])))
end

dims = [101, 103]
begin
    counts = zeros.(Int, dims)
    robots = map(input) do line
        px, py, vx, vy = parse.(Int, match(regex, line))
        p, v = [px, py], [vx, vy]
        counts[1][p[1]+1] += 1
        counts[2][p[2]+1] += 1
        (p, v)
    end

    it = 0
    min_p = 1.0
    while true
        it += 1
        for (p, v) in robots
            counts[1][p[1]+1] -= 1
            counts[2][p[2]+1] -= 1
            p .= mod.((p .+ v), dims)
            counts[1][p[1]+1] += 1
            counts[2][p[2]+1] += 1
        end
        # Check p-value of each dimension independently being uniform
        p_data = prod(pvalue.(ChisqTest.(counts)))
        if p_data < min_p
            min_p = p_data
            print_timestep(it)
            println(it, "\t", min_p)
        end
        # just so you can interrupt it.
        sleep(0.000001)
    end
end

# Chi squared test is not the perfect test for this, since it does not encode the spatial nature of the problem, but it is more than good enough.