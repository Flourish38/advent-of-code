const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/6.txt");

var line_len: usize = undefined;
var n_lines: usize = undefined;

fn parse(str: []const u8) !u64 {
    const trimmed = std.mem.trim(u8, str, " ");
    return std.fmt.parseUnsigned(u64, trimmed, 10);
}

fn compute_problem(comptime op: enum { plus, star }, start: usize, end: usize) !u64 {
    var problem = try parse(input[start..end]);
    for (1..n_lines - 1) |i| {
        const line_offset = line_len * i;
        const next = try parse(input[line_offset + start .. line_offset + end]);
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
    for (input[(n_lines - 1) * line_len + 1 .. input.len], 1..) |c, i| {
        if (c != '+' and c != '*' and c != '\r') continue;
        acc += switch (last_op) {
            '+' => try compute_problem(.plus, last_start, i),
            '*' => try compute_problem(.star, last_start, i),
            else => unreachable,
        };
        last_op = c;
        last_start = i;
    }

    std.debug.print("{D}\n{d}\n", .{
        timer.lap(),
        acc,
    });
}
