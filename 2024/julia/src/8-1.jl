input = readlines("input/8.txt")
data = reduce(hcat, collect.(input))

begin
    frequencies = Set(data)
    delete!(frequencies, '.')
    frequencies = collect(frequencies)
end

frequency_stations = map.(x -> [Tuple(x)...], [filter(i -> data[i] == freq, CartesianIndices(data)) for freq in frequencies])

begin
    anodes = Set()
    for stations in frequency_stations
        for s1 in stations, s2 in stations
            if s1 == s2
                continue
            end
            dist = s2 .- s1
            push!(anodes, s2 .+ dist)
            push!(anodes, s1 .- dist)
        end
    end
    filter!(x -> checkbounds(Bool, data, CartesianIndex(x...)), anodes)
    println(length(anodes))
end
