using UnicodePlots

input = readlines("input/14.txt")

regex = r"p=([\-0-9]+),([\-0-9]+) v=([\-0-9]+),([\-0-9]+)"

dims = [101, 103]

begin
    robots = map(input) do line
        px, py, vx, vy = parse.(Int, match(regex, line))
        p, v = [px, py], [vx, vy]
    end

    it = 0
    while true
        it += 1
        for (p, v) in robots
            p .= mod.((p .+ v), dims)
        end
        xs, ys = reduce(first.(robots), init=[[], []]) do (xs, ys), (x, y)
            push!(xs, x)
            push!(ys, y)
            xs, ys
        end
        println(scatterplot(xs, ys, xlim=(0, dims[1]), ylim=(0, dims[2])))
        println(it)
        sleep(0.25)
    end
end

# OH
# x dist is starting at 4 and every 101 after
# y dist is starting at 76 and every 103 after

begin
    start = [4, 76]
    n = 0
    while (dims[2] * n + start[2] - start[1]) % dims[1] != 0
        n += 1
    end
    timesteps = dims[2] * n + start[2]
    println(timesteps)
end

begin
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

# I didn't like this one very much.
# I probably could have tried to do it statistically but I'm unfamiliar with exactly how to do that.
# ...I should probably learn how.
# Fortunately, it was guaranteed that I would see an anomaly within maximum(dims) timesteps, which isn't that long.