const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    var path_buf: [256]u8 = undefined;
    const cwd = std.fs.cwd();
    const path = try cwd.realpath("input/2.txt", &path_buf);
    const file = try std.fs.openFileAbsolute(path, .{});
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    var acc: i64 = 0;
    while (reader.interface.takeDelimiterExclusive(',')) |maybe_range| {
        const range = if (maybe_range[maybe_range.len - 1] == '\n')
            maybe_range[0 .. maybe_range.len - 2]
        else blk: {
            assert(try reader.interface.discard(.limited(1)) == 1);
            break :blk maybe_range;
        };
        const middle = std.mem.indexOfScalarPos(u8, range, range.len / 2 - 1, '-').?;
        const first_slice = range[0..middle];
        const last_slice = range[middle + 1 ..];
        assert(last_slice.len - first_slice.len < 2);
        var factors_used: [16]i8 = @splat(0);
        for (2..last_slice.len + 1) |n_repetitions| {
            const n_used_factors = blk: {
                var result: i8 = 0;
                for (2..n_repetitions) |i| {
                    if (@mod(n_repetitions, i) == 0)
                        result += factors_used[i];
                }
                break :blk result;
            };
            // this removes cases like 2222_2222, where 2 groups of 4 was already counted.
            // 4 groups of 2 should not be counted, and neither should 8 groups of 1.
            if (n_used_factors == 1) continue;
            const round_len = if (@mod(last_slice.len, n_repetitions) == 0) last_slice.len else first_slice.len;
            if (@mod(round_len, n_repetitions) != 0) continue; // no lengths that are divided evenly by the number of repetitions
            const repetition_len = @divExact(round_len, n_repetitions);
            const first = if (first_slice.len != round_len)
                try std.math.powi(i64, 10, @intCast(last_slice.len - 1))
            else
                try std.fmt.parseInt(i64, first_slice, 10);
            const last = if (last_slice.len != round_len)
                try std.math.powi(i64, 10, @intCast(first_slice.len)) - 1
            else
                try std.fmt.parseInt(i64, last_slice, 10);
            const invalid_factor = blk: {
                var factor_acc: i64 = 1;
                for (1..n_repetitions) |i| {
                    factor_acc += try std.math.powi(i64, 10, @intCast(repetition_len * i));
                }
                break :blk factor_acc;
            };
            // if `first` is divided exactly by `invalid_factor`, it must be included
            const first_divided = @divFloor(first, invalid_factor) + @min(1, @mod(first, invalid_factor)) - 1;
            const last_divided = @divFloor(last, invalid_factor);
            if (last_divided <= first_divided) continue;
            // used to cancel out double-counting, like for 222222 in the example input.
            // counts once for 2 groups of 3, once for 3 groups of 2, and negative once for 6 groups of 1
            // this is correct since 6 has 2 and 3 as factors, both of which were counted.
            // So, any number that is 6 groups of 1 must be double-counted, and should be removed.
            const multiplier = 1 - n_used_factors;
            factors_used[n_repetitions] = multiplier;
            // triangle number formula
            const new_invalids = invalid_factor * @divExact((last_divided * (last_divided + 1) - (first_divided) * (first_divided + 1)), 2);
            acc += multiplier * new_invalids;
            // std.debug.print("{d}-{d}\t{d}\t{d}\n", .{ first, last, n_repetitions, multiplier * new_invalids });
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
    std.debug.print("{d}\n", .{acc});
}
