input = parse.(Int, split(readline("input/11.txt"), ' '))

rules = Dict{Int,Tuple{Int,Int}}(0 => (1, -1), -1 => (-1, -1))

function step!(rules, s)
    digits = string(s)
    result = (-1, -1)
    if length(digits) % 2 == 0
        n = length(digits) ÷ 2
        result = (tryparse(Int, digits[1:n]), tryparse(Int, digits[n+1:end]))
        if any(isnothing, result)
            println(s)
        end
    else
        result = (s * 2024, -1)
    end
    rules[s] = result
    return result
end

function blink(rules, stones)
    output = Dict{Int,Int}()
    for (s, n) in stones
        new_stones = get(() -> step!(rules, s), rules, s)
        for ns in new_stones
            if haskey(output, ns)
                output[ns] += n
            else
                output[ns] = n
            end
        end
    end
    return output
end

begin
    stones = Dict{Int,Int}(map(x -> x => 1, input))
    for i in 1:75
        stones = blink(rules, stones)
    end
    println(sum(values(stones)) - stones[-1])
    # ... for some reason, stones[-1] is exactly negative the answer. It *should* be positive, and not necessarily the answer.
    # Doesn't matter, as it was a throwaway value regardless, but... huh.
    # Also, at least for my input, all needed rules are generated after blink #70, for a total of 3880 rules.
end