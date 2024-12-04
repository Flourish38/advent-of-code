raw_data = readlines("input/2.txt")

data = map(x -> parse.(Int, x), split.(raw_data, ' '))

begin
    result = 0
    for r in data
        n = length(r) - 1
        diffs = [r[i+1] - r[i] for i in 1:n]
        if diffs[1] < 0
            diffs = map(x -> -x, diffs)
        end
        if all(x -> 1 <= x <= 3, diffs)
            result += 1
        end
    end
    println(result)
end