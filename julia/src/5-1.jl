using CSV, DataFrames

rules = CSV.read("input/5-1.csv", DataFrame, header=0)

updates = map(x -> parse.(Int, split(x, ',')), readlines("input/5-2.txt"))

begin
    using UnicodePlots
    histogram(length.(updates), nbins=maximum(length.(updates))) # All odd length!
    # No need to decide between left or right for "middle"
end

begin
    result = 0
    for update in updates
        valid = true
        for rule in eachrow(rules)
            a, b = rule[1], rule[2]
            a_ind = findfirst(==(a), update)
            b_ind = findfirst(==(b), update)
            if !isnothing(a_ind) && !isnothing(b_ind) && b_ind < a_ind
                valid = false
                break
            end
        end
        if valid
            result += update[(length(update)+1)÷2]
        end
    end
    println(result)
end