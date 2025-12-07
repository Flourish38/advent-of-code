const std = @import("std");

// N = 6
// 234234234234278
//         >234278 4 234278
//        >4 34278 3 434278
//       > 4 34278 2 434278
//      >  4 34278 4 434278
//     >4  4  4278 3 444278
//    > 4  4  4278 2 444278
//   >  4  4  4278 4 444278
//  >4  4  4  4 78   444478

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
    const N = 12;
    var total_joltage: u64 = 0;
    var buf: [N]u8 = undefined;
    while (reader.interface.takeDelimiterExclusive('\r')) |line| {
        _ = try reader.interface.discard(.limited(2));
        @memcpy(&buf, line[line.len - N ..]);
        var i = line.len - N;
        while (i > 0) {
            i -= 1;
            var next = line[i];
            for (&buf) |*d| {
                const digit = d.*;
                if (next < digit) break;
                d.* = next;
                next = digit;
            }
        }
        const joltage = try std.fmt.parseUnsigned(u64, &buf, 10);
        // std.debug.print("{s}:\t{d}\n", .{ line, joltage });
        total_joltage += joltage;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
    std.debug.print("{D}\n{d}\n", .{ timer.lap(), total_joltage });
}
