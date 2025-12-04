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
    var was_zero = false;
    while (reader.interface.takeDelimiterExclusive('\r')) |line| {
        const relevant_offset = @max(1, line.len - 2);
        const relevant_digits = line[relevant_offset..];

        const parsed = try std.fmt.parseInt(i16, relevant_digits, 10);
        switch (line[0]) {
            'R' => pos_acc += parsed,
            'L' => pos_acc -= parsed,
            else => unreachable,
        }
        const fixed_acc = @mod(pos_acc, 100);
        if (fixed_acc == 0 or (!was_zero and fixed_acc != pos_acc)) zero_acc += 1;
        // std.debug.print("{s}\t{d}\t{d}\t{any}\t{d}\n", .{ line, pos_acc, fixed_acc, is_zero, zero_acc });
        pos_acc = fixed_acc;
        was_zero = pos_acc == 0;

        const other_digits = line[1..relevant_offset];
        if (other_digits.len > 0)
            zero_acc += try std.fmt.parseInt(u8, other_digits, 10);

        _ = try reader.interface.discard(.limited(2));
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
    std.debug.print("{d}", .{zero_acc});
}
