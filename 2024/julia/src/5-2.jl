using CSV, DataFrames

rules = CSV.read("input/5-1.csv", DataFrame, header=0)

updates = map(x -> parse.(Int, split(x, ',')), readlines("input/5-2.txt"))

begin
    valid_mask = trues(length(updates))
    for (i, update) in enumerate(updates)
        for rule in eachrow(rules)
            a, b = rule[1], rule[2]
            a_ind = findfirst(==(a), update)
            b_ind = findfirst(==(b), update)
            if !isnothing(a_ind) && !isnothing(b_ind) && b_ind < a_ind
                valid_mask[i] = false
                break
            end
        end
    end
    invalid_updates = deepcopy(updates[.!valid_mask])
    result = 0
    for update in invalid_updates
        is_invalid = true
        while is_invalid
            all_passing = true
            for rule in eachrow(rules)
                a, b = rule[1], rule[2]
                a_ind = findfirst(==(a), update)
                b_ind = findfirst(==(b), update)
                if !isnothing(a_ind) && !isnothing(b_ind) && b_ind < a_ind
                    all_passing = false
                    update[a_ind], update[b_ind] = update[b_ind], update[a_ind]
                end
            end
            if all_passing
                is_invalid = false
            end
        end
        result += update[(length(update)+1)÷2]
    end
    println(result)
end