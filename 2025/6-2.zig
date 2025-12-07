const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/6.txt");

var line_len: usize = undefined;
var n_lines: usize = undefined;

fn parse(column: usize) !u64 {
    var buf: [8]u8 = undefined;
    var num: std.ArrayList(u8) = .initBuffer(&buf);

    for (0..n_lines - 1) |i| {
        num.appendAssumeCapacity(input[line_len * i + column]);
    }

    const trimmed = std.mem.trim(u8, num.items, " ");
    // std.debug.print("{s}\n", .{trimmed});
    return std.fmt.parseUnsigned(u64, trimmed, 10);
}

fn compute_problem(comptime op: enum { plus, star }, start: usize, end: usize) !u64 {
    var problem = try parse(start);
    for (start + 1..end) |i| {
        const next = try parse(i);
        switch (op) {
            .plus => problem += next,
            .star => problem *= next,
        }
    }
    return problem;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    line_len = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    n_lines = input.len / line_len;

    var last_start: usize = 0;
    var last_op = input[(n_lines - 1) * line_len];
    assert(last_op == '+' or last_op == '*');

    var acc: u64 = 0;
    for (input[(n_lines - 1) * line_len + 1 .. input.len], 0..) |c, i| {
        if (c != '+' and c != '*' and c != '\n') continue;
        acc += switch (last_op) {
            '+' => try compute_problem(.plus, last_start, i),
            '*' => try compute_problem(.star, last_start, i),
            else => unreachable,
        };
        last_op = c;
        last_start = i + 1;
    }

    std.debug.print("{D}\n{d}\n", .{
        timer.lap(),
        acc,
    });
}
