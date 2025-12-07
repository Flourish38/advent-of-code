const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/4.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var acc: usize = 0;
    var lines: [3][]const u8 = @splat(&.{});
    var it = std.mem.tokenizeAny(u8, input, "\r\n");
    // var test_line: [128]u8 = @splat(' ');
    for (lines[1..]) |*line| {
        line.* = it.next().?;
    }
    while (it.next()) |new_line| {
        lines[0] = lines[1];
        lines[1] = lines[2];
        lines[2] = new_line;

        for (lines[1][1 .. lines[1].len - 1], 0..) |c, i| {
            if (c != '@') {
                assert(c == '.');
                continue;
            }
            var num_rolls: usize = 0;
            for (lines) |line| {
                num_rolls += std.mem.count(u8, line[i .. i + 3], "@");
            }
            if (num_rolls < 4 + 1) {
                acc += 1;
                // test_line[i + 1] = 'x';
            }
        }
        // std.debug.print("{s}\n{s}\n{s}\n{s}\n\n", .{ lines[0], lines[1], lines[2], test_line });
        // test_line = @splat(' ');
    }
    std.debug.print("{D}\n{d}", .{ timer.lap(), acc });
}
