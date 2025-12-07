const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/7.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var live: [256]bool = @splat(false);
    var left: usize = undefined;
    var right: usize = undefined;

    const line_len = blk: {
        for (input, 0..) |c, i| {
            switch (c) {
                'S' => {
                    live[i] = true;
                    left = i;
                    right = i + 1;
                },
                '\n' => break :blk i + 1,
                else => {},
            }
        }
        unreachable;
    };

    const n_lines = input.len / line_len;

    var acc: u64 = 0;

    for (1..n_lines) |line_number| {
        const line_offset = line_number * line_len;
        const line = input[line_offset + left .. line_offset + right];
        for (line, left..) |c, i| {
            if (c == '^' and live[i]) {
                acc += 1;
                live[i] = false;
                live[i - 1] = true;
                live[i + 1] = true;
                if (i == left) left -= 1;
                if (i == right - 1) right += 1;
            }
        }
    }

    std.debug.print("{D}\n{d}\n", .{
        timer.lap(),
        acc,
    });
}
