input = parse.(Int, split(readline("input/11.txt"), ' '))

function blink(stones)
    output = []
    for s in stones
        if s == 0
            push!(output, 1)
        elseif length(string(s)) % 2 == 0
            digits = string(s)
            n = length(digits) ÷ 2
            parts = [digits[1:n], digits[n+1:end]]
            append!(output, parse.(Int, parts))
        else
            push!(output, s * 2024)
        end
    end
    return output
end

begin
    stones = input
    for _ in 1:25
        stones = blink(stones)
    end
    println(length(stones))
end