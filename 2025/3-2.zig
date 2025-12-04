const std = @import("std");

pub fn main() !void {
    var path_buf: [256]u8 = undefined;
    var cwd = std.fs.cwd();
    defer cwd.close();
    const path = try cwd.realpath("input/3.txt", &path_buf);
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    const N = 12;
    var total_joltage: u64 = 0;
    while (reader.interface.takeDelimiterExclusive('\r')) |line| {
        _ = try reader.interface.discard(.limited(2));
        var start: usize = 0;
        var buf: [N]u8 = undefined;
        for (0..N) |digit| {
            const i = std.mem.indexOfMax(u8, line[start .. line.len - (N - 1 - digit)]);
            start += i;
            buf[digit] = line[start];
            start += 1;
        }
        const joltage = try std.fmt.parseInt(u64, &buf, 10);
        // std.debug.print("{s}:\t{d}\n", .{ line, joltage });
        total_joltage += joltage;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
    std.debug.print("{d}", .{total_joltage});
}
