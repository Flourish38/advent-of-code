input = readlines("input/7.txt")
Y = parse.(Int, first.(split.(input, ':')))
X = map(x -> parse.(Int, split(last(split(x, ": ")), ' ')), input)

data = zip(X, Y)

begin
    result = 0
    for (x, y) in data
        N = length(x) - 1
        for n in 0:(3^(N)-1)
            mask = digits(n, base=3, pad=N)
            total = x[1]
            for (c, x) in zip(mask, x[2:end])
                if c == 2
                    total = parse(Int, string(total) * string(x))
                elseif c == 1
                    total *= x
                else
                    total += x
                end
            end
            if total == y
                result += y
                break
            end
        end
    end
    println(result)
end