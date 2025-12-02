input = readlines("input/14.txt")

regex = r"p=([\-0-9]+),([\-0-9]+) v=([\-0-9]+),([\-0-9]+)"

dims = [101, 103]

robots = map(input) do line
    px, py, vx, vy = parse.(Int, match(regex, line))
    p, v = [px, py], [vx, vy]
end

for (p, v) in robots
    # God I love this language, look at this
    p .= mod.((p .+ 100 .* v), dims)
end

middle = dims .÷ 2

reduce(robots, init=zeros(Int, 4)) do quadrants, (p, _)
    dir = sign.(p .- middle)
    if dir == [-1, -1]
        quadrants[1] += 1
    elseif dir == [-1, 1]
        quadrants[2] += 1
    elseif dir == [1, -1]
        quadrants[3] += 1
    elseif dir == [1, 1]
        quadrants[4] += 1
    end
    return quadrants
end |> prod |> println