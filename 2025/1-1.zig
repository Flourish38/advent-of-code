const std = @import("std");

pub fn main() !void {
    var path_buf: [256]u8 = undefined;
    var cwd = std.fs.cwd();
    defer cwd.close();
    const path = try cwd.realpath("input/1.txt", &path_buf);
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    var reader_buf: [4096]u8 = undefined;
    var reader = file.reader(&reader_buf);
    var pos_acc: i16 = 50;
    var zero_acc: u64 = 0;
    while (reader.interface.takeDelimiterExclusive('\r')) |line| {
        const relevant_digits: []const u8 = if (line.len == 2) line[1..2] else line[line.len - 2 .. line.len];
        const parsed = try std.fmt.parseInt(i16, relevant_digits, 0);
        switch (line[0]) {
            'R' => pos_acc += parsed,
            'L' => pos_acc -= parsed,
            else => unreachable,
        }
        pos_acc = @mod(pos_acc, 100);
        if (pos_acc == 0) zero_acc += 1;
        _ = try reader.interface.discard(.limited(2));
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
    std.debug.print("{d}", .{zero_acc});
}
