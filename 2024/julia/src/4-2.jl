input = readlines("input/4.txt")
data = reduce(hcat, collect.(input))

k = ['M' '.' 'M';
    '.' 'A' '.';
    'S' '.' 'S']

kernel = [k, rotl90(k), rot180(k), rotr90(k)]

begin
    result = 0
    for i in 1:(size(data, 1)-2), j in 1:(size(data, 2)-2)
        d = data[i:i+2, j:j+2]
        for k in kernel
            if count(k .== d) == 5
                result += 1
            end
        end
    end
    println(result)
end
