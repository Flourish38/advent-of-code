input = strip(read("input/9.txt", String))

max_id = (length(input) + 1) ÷ 2  # 10000

files = fill(-1, (max_id, 2))
gaps = fill(-1, (length(input) ÷ 2, 2))

begin
    id_index = 0
    for (i, c) in enumerate(input)
        n = parse(Int, c)
        id = i ÷ 2
        if i % 2 == 1
            files[id+1, :] .= [id_index, n]
        else
            gaps[id, :] .= [id_index, n]
        end
        id_index += n
    end
end

any(==(0), files[:, 2]) # false, all files have at least 1 block. 
# This means no gaps need to be merged, since they are all separated by files.

for id in reverse(axes(files, 1))
    n = files[id, 2]
    gap_index = findfirst(>=(n), gaps[:, 2])
    if isnothing(gap_index)
        continue
    end
    gap_pos, gap_len = gaps[gap_index, :]
    if gap_pos > files[id, 1]
        continue
    end
    files[id, 1] = gap_pos
    gaps[gap_index, :] .= [gap_pos + n, gap_len - n]
end

begin
    result = 0
    for id in axes(files, 1)
        pos, n = files[id, :]
        result += (id - 1) * sum(pos:pos+(n-1))
    end
    println(result)
end
