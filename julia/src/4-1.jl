input = readlines("input/4.txt")
data = reduce(hcat, collect.(input))

key = collect("XMAS")
key = [key, reverse(key)]

row(s, n) = [n == i ? s[j] : '.' for i in 1:4, j in 1:4]
rows(n) = row.(key, n)
column(s, n) = [n == j ? s[i] : '.' for i in 1:4, j in 1:4]
columns(n) = column.(key, n)
diagonal_1(s) = [i == j ? s[i] : '.' for i in 1:4, j in 1:4]
diagonal_1s() = diagonal_1.(key)
diagonal_2(s) = [i == j ? s[i] : '.' for i in 1:4, j in 4:-1:1]
diagonal_2s() = diagonal_2.(key)

kernel = vcat(diagonal_1s(), diagonal_2s())

begin
    result = 0
    for i in 1:size(data, 1), j in 1:(size(data, 2)-3)
        d = data[i, j:j+3]
        for k in key
            if count(k .== d) == 4
                result += 1
            end
        end
    end
    for i in 1:(size(data, 1)-3), j in 1:size(data, 2)
        d = data[i:i+3, j]
        for k in key
            if count(k .== d) == 4
                result += 1
            end
        end
    end
    for i in 1:(size(data, 1)-3), j in 1:(size(data, 2)-3)
        d = data[i:i+3, j:j+3]
        for k in kernel
            if count(k .== d) == 4
                result += 1
            end
        end
    end
    println(result)
end
