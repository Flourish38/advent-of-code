const std = @import("std");
const assert = std.debug.assert;

pub fn main() !void {
    var path_buf: [256]u8 = undefined;
    var cwd = std.fs.cwd();
    defer cwd.close();
    const path = try cwd.realpath("input/2.txt", &path_buf);
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    var acc: u64 = 0;
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
        const even_len = if (last_slice.len & 1 == 0) last_slice.len else first_slice.len;
        if (even_len & 1 == 1) continue; // all numbers have odd length, no chance of duplicate
        const first = if (first_slice.len != even_len)
            try std.math.powi(u64, 10, last_slice.len - 1)
        else
            try std.fmt.parseUnsigned(u64, first_slice, 10);
        const last = if (last_slice.len != even_len)
            try std.math.powi(u64, 10, first_slice.len) - 1
        else
            try std.fmt.parseUnsigned(u64, last_slice, 10);
        const invalid_factor = try std.math.powi(u64, 10, even_len / 2) + 1;
        // if `first` is divided exactly by `invalid_factor`, it must be included
        const first_divided = first / invalid_factor + @min(1, @mod(first, invalid_factor)) - 1;
        const last_divided = last / invalid_factor;
        // triangle number formula
        acc += invalid_factor * (last_divided * (last_divided + 1) - (first_divided) * (first_divided + 1)) / 2;
        // std.debug.print("{d}-{d}\t{d}\t{d}\t{d}\t{d}\t{d}\n", .{ first, last, invalid_factor, first_divided, last_divided, last_divided - first_divided, acc });
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
    std.debug.print("{d}\n", .{acc});
}
