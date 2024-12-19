input = split.(strip.(split(read("input/13.txt", String), "\n\n")), '\n')

regex = r"[^0-9]+([0-9]+)[^0-9]+([0-9]+)"

begin
    result = 0
    for (A, B, P) in input
        a = parse.(Int, match(regex, A))
        b = parse.(Int, match(regex, B))
        AB = hcat(a, b)
        p = parse.(Int, match(regex, P))
        n = AB \ p # linear algebra, baybee! AB * n = p
        if all(isapprox.(n, round.(Int, n)))
            n = round.(Int, n)
            result += sum(n .* [3, 1])
        end
    end
    println(result)
end
