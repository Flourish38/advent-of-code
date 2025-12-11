const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/9.txt");

var point_buffer: [2][1 << 9]i64 = undefined;

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var lines = std.mem.tokenizeAny(u8, input, "\r\n");

    var points: [2]std.ArrayList(i64) = @splat(.empty);
    for (&points, &point_buffer) |*axis, *buffer| {
        axis.* = .initBuffer(buffer);
    }

    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ',');

        for (&points) |*axis| {
            const coord = try std.fmt.parseUnsigned(i64, nums.next().?, 10);
            axis.appendAssumeCapacity(coord);
        }
    }

    var max_area: u64 = 0;
    for (points[0].items, points[1].items, 1..) |x, y, i| {
        for (points[0].items[i..], points[1].items[i..]) |a, b| {
            // const last_area = max_area;
            max_area = @max(max_area, @abs((x - a + 1) * (y - b + 1)));
            // if (max_area != last_area) std.debug.print("{d}, {d}\n", .{ i - 1, j });
        }
    }

    std.debug.print("{D}\n{any}\n", .{ timer.lap(), max_area });
}
