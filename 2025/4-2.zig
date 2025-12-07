const std = @import("std");
const assert = std.debug.assert;

const _input = @embedFile("input/4.txt");

var buffer: [1 << 15]u8 = undefined;

pub fn main() !void {
    var timer = try std.time.Timer.start();

    // var gpa: std.heap.DebugAllocator(.{}) = .init;
    // defer assert(gpa.deinit() == .ok);
    // var alloc = gpa.allocator();

    var fba: std.heap.FixedBufferAllocator = .init(&buffer);
    const allocator = fba.allocator();

    const input = try allocator.dupe(u8, _input);
    defer allocator.free(input);

    var acc: usize = 0;
    var any_change = true;
    while (any_change) {
        any_change = false;
        var lines: [3][]u8 = @splat(&.{});
        var reader = std.Io.Reader.fixed(input);
        // var test_line: [128]u8 = @splat(' ');

        for (lines[1..]) |*line| {
            line.* = try reader.takeDelimiterExclusive('\r');
            _ = try reader.discard(.limited(2));
        }
        while (reader.takeDelimiterExclusive('\r')) |new_line| {
            _ = reader.discard(.limited(2)) catch |err| switch (err) {
                error.EndOfStream => {},
                else => return err,
            };
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
                    any_change = true;
                    lines[1][i + 1] = '.';
                    // test_line[i + 1] = 'x';
                }
            }
            // std.debug.print("{s}\n{s}\n{s}\n{s}\n\n", .{ lines[0], lines[1], lines[2], test_line });
            // test_line = @splat(' ');
        } else |err| switch (err) {
            error.EndOfStream => {},
            else => return err,
        }
    }

    std.debug.print("{D}\n{d}", .{ timer.lap(), acc });
}
