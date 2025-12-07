const std = @import("std");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var path_buf: [256]u8 = undefined;
    var cwd = std.fs.cwd();
    defer cwd.close();
    const path = try cwd.realpath("input/3.txt", &path_buf);
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    var total_joltage: u64 = 0;
    while (reader.interface.takeDelimiterExclusive('\r')) |line| {
        _ = try reader.interface.discard(.limited(2));
        var best, var second_best, var best_after_second_best = if (line[0] > line[1])
            .{ line[0], line[1], false }
        else
            .{ line[1], line[0], true };
        for (line[2..]) |next| {
            if (next > best) {
                second_best = best;
                best = next;
                best_after_second_best = true;
            } else if (best_after_second_best) {
                second_best = next;
                best_after_second_best = false;
            } else if (next > second_best) {
                second_best = next;
            }
        }
        best &= 0b00001111;
        second_best &= 0b00001111;
        const joltage = if (best_after_second_best) 10 * second_best + best else 10 * best + second_best;
        total_joltage += joltage;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
    std.debug.print("{D}\n{d}\n", .{ timer.lap(), total_joltage });
}
