const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/4.txt");

const Vec = @Vector(32, u8);

const Adder = struct {
    result: u192,
    carry: u192,
    parity: u192,

    const zero: Adder = .{ .result = 0, .carry = 0, .parity = 0 };

    pub fn intake(self: *Adder, arr: []const u192) void {
        for (arr) |n| {
            const carry = self.parity & n;
            self.result |= carry & self.carry;
            self.carry ^= carry;
            self.parity ^= n;
            // if (arr.len == 2)
            //     std.debug.print("{b:0>11}             ", .{n})
            // else
            //     std.debug.print("{b:0>11} ", .{n});
        }
        // if (arr.len == 2)
        //     std.debug.print("\x08\x08\x08\x08\x08\x08\x08\x08\x08\x08\x08\x08{d}, {d}, {d}\n", .{ @popCount(self.result), @popCount(self.carry), @popCount(self.parity) })
        // else
        //     std.debug.print("{d}, {d}, {d}\n", .{ @popCount(self.result), @popCount(self.carry), @popCount(self.parity) });
    }
};

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var acc: usize = 0;
    const n = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const line_len = input.len / n;
    var prev_lines: [3]u192 = @splat(0);
    var prev_above: [3]u192 = @splat(0);
    for (0..line_len) |line_idx| {
        const offset = n * line_idx;
        var line: u192 = 0;
        for (input[offset..][0 .. n - 2]) |c| {
            if (c == '@')
                line |= 1
            else
                assert(c == '.');
            line <<= 1;
        }
        const lines: [3]u192 = .{
            line << 1,
            line,
            line >> 1,
        };
        defer prev_lines = lines;

        var adder: Adder = .zero;
        adder.intake(&prev_above);
        adder.intake(&.{
            prev_lines[0] & prev_lines[1],
            prev_lines[2] & prev_lines[1],
        });
        adder.intake(&.{
            prev_lines[1] & lines[0],
            prev_lines[1] & lines[1],
            prev_lines[1] & lines[2],
        });
        prev_above = .{
            lines[1] & prev_lines[0],
            lines[1] & prev_lines[1],
            lines[1] & prev_lines[2],
        };
        acc += @popCount(prev_lines[1] & ~adder.result);
        // std.debug.print("{b:0>11}, {b:0>11}\t{b:0>11}\t{d}\n", .{ prev_lines[1], adder.result, prev_lines[1] & ~adder.result, acc });
    }
    var adder: Adder = .zero;
    adder.intake(&prev_above);
    adder.intake(&.{
        prev_lines[0] & prev_lines[1],
        prev_lines[2] & prev_lines[1],
    });
    acc += @popCount(prev_lines[1] & ~adder.result);
    // std.debug.print("{b:0>11}, {b:0>11}\t{b:0>11}\t{d}\n", .{ prev_lines[1], adder.result, prev_lines[1] & ~adder.result, acc });
    std.debug.print("{D}\n{d}", .{ timer.lap(), acc });
}
