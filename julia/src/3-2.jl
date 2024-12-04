input = read("input/3.txt", String)

length(input)

mul_regex = r"mul\(([0-9]+),([0-9]+)\)"
do_regex = r"do\(\)"
dont_regex = r"don't\(\)"

begin
    result = 0
    mask = falses(length(input))
    donts = []
    for m in eachmatch(dont_regex, input)
        push!(donts, m.offset)
    end
    push!(donts, length(input) + 1)
    sort!(donts)
    mask[1:(first(donts)-1)] .= true
    for m in eachmatch(do_regex, input)
        fin = donts[findfirst(>(m.offset), donts)] - 1
        mask[m.offset:fin] .= true
    end
    for m in eachmatch(regex, input)
        if mask[m.offset]
            numbers = parse.(Int, m.captures)
            result += numbers[1] * numbers[2]
        end
    end
    println(result)
end