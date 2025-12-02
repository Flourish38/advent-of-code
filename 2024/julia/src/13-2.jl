input = split.(strip.(split(read("input/13.txt", String), "\n\n")), '\n')

regex = r"[^0-9]+([0-9]+)[^0-9]+([0-9]+)"

sum(input) do P
    a, b, p = (x -> parse.(Int, match(regex, x))).(P) # 3 lines of input per problem
    # God I love this language. Getting floating point error? Just use different numbers! ^_^
    AB = Rational.(hcat(a, b))
    p .+= 10000000000000 # 1e13
    n = AB \ p # Linear algebra, baybee! AB * n = p
    # Beautiful.
    return all(isinteger.(n)) ? sum(Int.(n) .* [3, 1]) : 0
end |> println