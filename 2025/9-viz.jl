using Pkg
Pkg.add(["Plots", "CSV", "DataFrames"])
using CSV, Plots, DataFrames

df = CSV.read("2025/input/9.txt", DataFrame; header=0)

x = df[!, :Column1]
y = df[!, :Column2]

c = [57, 311]
d = 248

plot(x, y)
plot!(x[c.+1], y[c.+1])
plot!(x[d.+[1, 2]], y[d.+[1, 2]])

