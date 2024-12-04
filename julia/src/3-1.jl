input = read("input/3.txt", String)

regex = r"mul\(([0-9]+),([0-9]+)\)"

begin
    result = 0
    for match in eachmatch(regex, input)
        numbers = parse.(Int, match.captures)
        result += numbers[1] * numbers[2]
    end
    println(result)
end