input = readlines("input/7.txt")
Y = parse.(Int, first.(split.(input, ':')))
X = map(x -> parse.(Int, split(last(split(x, ": ")), ' ')), input)

data = zip(X, Y)

begin
    result = 0
    for (x, y) in data
        N = length(x) - 1
        for n in UInt16(0):UInt16((2^(N) - 1))
            mask = reverse(bitstring(n))[1:N]
            total = x[1]
            for (c, x) in zip(mask, x[2:end])
                if c == '1'
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