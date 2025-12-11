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

    const n = points[0].items.len;

    // const min_x = std.mem.min(i64, points[0].items);
    // const min_y = std.mem.min(i64, points[1].items);

    // for (points[0].items, points[1].items) |*x, *y| {
    //     x.* -= min_x;
    //     y.* -= min_y;
    // }

    // const max_x = std.mem.max(i64, points[0].items);
    // const max_y = std.mem.max(i64, points[1].items);

    var max_area: u64 = 0;

    for (points[0].items, points[1].items, 1..) |x, y, i| {
        outer: for (points[0].items[i..], points[1].items[i..]) |a, b| {
            const area = (@abs(x - a) + 1) * (@abs(y - b) + 1);
            if (area <= max_area) continue;
            const min_x, const max_x = if (x < a) .{ x, a } else .{ a, x };
            const min_y, const max_y = if (y < b) .{ y, b } else .{ b, y };
            for (
                points[0].items[0 .. n - 1],
                points[1].items[0 .. n - 1],
                points[0].items[1..],
                points[1].items[1..],
                // 0..,
            ) |x1, y1, a1, b1| {
                if (x1 == a1) {
                    if (x1 >= max_x or x1 <= min_x) continue;
                    const min_y1, const max_y1 = if (y1 < b1) .{ y1, b1 } else .{ b1, y1 };
                    if (min_y1 < max_y and max_y1 > min_y) {
                        // std.debug.print("{d}, {d}:  {d},{d}x{d},{d}\t{d}:  {d},{d}-{d},{d}\n", .{ i - 1, j, x, y, a, b, k, x1, y1, a1, b1 });
                        continue :outer;
                    }
                } else {
                    assert(y1 == b1);
                    if (y1 >= max_y or y1 <= min_y) continue;
                    const min_x1, const max_x1 = if (x1 < a1) .{ x1, a1 } else .{ a1, x1 };
                    if (min_x1 < max_x and max_x1 > min_x) {
                        // std.debug.print("{d}, {d}:  {d},{d}x{d},{d}\t{d}:  {d},{d}-{d},{d}\n", .{ i - 1, j, x, y, a, b, k, x1, y1, a1, b1 });
                        continue :outer;
                    }
                }
            }
            // std.debug.print("{d}, {d}:  {d},{d}x{d},{d}\t{d}\n", .{ i - 1, j, x, y, a, b, area });
            max_area = area;
        }
    }

    std.debug.print("{D}\n{d}\n", .{ timer.lap(), max_area });
}
