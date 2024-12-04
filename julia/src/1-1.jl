using CSV, DataFrames

data = CSV.read("input/1.csv", DataFrame, header=0)

a = sort(data[:, 1])
b = sort(data[:, 2])

answer = sum(abs.(a .- b))

println(answer)
