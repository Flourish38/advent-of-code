raw_data = readlines("input/2.txt")

data = map(x -> parse.(Int, x), split.(raw_data, ' '))

begin
    result = 0
    for r in data
        s = sum([sign(r[i+1] - r[i]) for i in 1:(length(r)-1)])
        if s < 0
            r .= -r
        end
        x_prev = r[1]
        used = false
        for (i, x) in enumerate(r)
            if i == 1
                continue
            end
            d = x - x_prev
            if !(1 <= d <= 3)
                if used
                    # Try again without the first entry... this sucks lmao
                    x_prev = r[2]
                    used = true
                    for (i, x) in enumerate(r)
                        if i == 1 || i == 2
                            continue
                        end
                        d = x - x_prev
                        if !(1 <= d <= 3)
                            if used
                                break
                            else
                                used = true
                            end
                        else
                            x_prev = x
                        end
                        if i == length(r)
                            result += 1
                        else

                        end
                    end
                    break
                else
                    used = true
                end
            else
                x_prev = x
            end
            if i == length(r)
                result += 1
            end
        end
    end
    println(result)
end