using CSV, DataFrames

data = CSV.read("input/1.csv", DataFrame, header=0)

function count_all(a)
    output = Dict()
    for v in a
        if haskey(output, v)
            output[v] += 1
        else
            output[v] = 1
        end
    end
    output

end

a = count_all(data[:, 1])
b = count_all(data[:, 2])

result = 0
for k in keys(a)
    if haskey(b, k)
        result += k * b[k]
    end
end
println(result)