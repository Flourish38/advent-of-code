input = split.(strip.(split(read("input/13.txt", String), "\n\n")), '\n')
regex = r"[^0-9]+([0-9]+)[^0-9]+([0-9]+)"

# LOOK AT HOW PRETTY THIS IS
sum(input) do P
    a, b, p = (x -> parse.(Int, match(regex, x))).(P)
    AB = Rational.(hcat(a, b))
    n = AB \ p
    return all(isinteger.(n)) ? sum(Int.(n) .* [3, 1]) : 0
end |> println