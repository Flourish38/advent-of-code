input = strip(read("input/9.txt", String))

max_id = (length(input) + 1) ÷ 2  # 10000

id_per_block = fill(Int16(-1), 9 * length(input)) # biggest possible array needed

# Initialize id_per_block array
begin
    id_index = 1
    id = Int16(0)
    for (i, c) in enumerate(input)
        n = parse(Int, c)
        if i % 2 == 1
            id_per_block[id_index:id_index+(n-1)] .= id
            id += Int16(1)
        end
        id_index += n
    end
end

# Compress id_per_block array
begin
    lo = 1
    hi = findlast(!=(-1), id_per_block)
    while lo < hi
        if id_per_block[lo] != -1
            lo += 1
            continue
        end
        if id_per_block[hi] == -1
            hi -= 1
            continue
        end
        id_per_block[lo], id_per_block[hi] = id_per_block[hi], id_per_block[lo]
        lo += 1
        hi -= 1
    end
end

# Compute checksum
begin
    result = 0
    for (i, id) in enumerate(id_per_block)
        if id < 0
            break
        end
        result += (i - 1) * id
    end
    println(result)
end