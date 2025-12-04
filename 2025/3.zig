const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/3.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    // @setEvalBranchQuota(1000000);
    // const acc2, const acc12 = comptime blk: {
    var buf2: [2]u8 = undefined;
    var buf12: [12]u8 = undefined;
    var acc2: u64 = 0;
    var acc12: u64 = 0;
    var i: usize = input.len - 1;
    assert(input[i] == '\n' and input[i - 1] == '\r');
    var offset: usize = i - 13;
    @memcpy(&buf12, input[offset..][0..12]);
    @memcpy(&buf2, buf12[10..]);
    i -= 3;
    while (i > 0) {
        i -= 1;
        var next = input[i];
        assert(next != '\r');
        if (next == '\n') {
            acc2 += try std.fmt.parseUnsigned(u64, &buf2, 10);
            acc12 += try std.fmt.parseUnsigned(u64, &buf12, 10);
            offset = i - 13;
            assert(input[offset..][12] == '\r');
            @memcpy(&buf12, input[offset..][0..12]);
            @memcpy(&buf2, buf12[10..]);
            i -= 3;
            continue;
        }
        if (next >= buf2[0]) {
            if (buf2[0] > buf2[1])
                buf2[1] = buf2[0];
            buf2[0] = next;
        }
        if (i < offset) {
            for (&buf12) |*d| {
                const digit = d.*;
                if (next < digit) break;
                d.* = next;
                next = digit;
            }
        }
    }
    acc2 += try std.fmt.parseUnsigned(u64, &buf2, 10);
    acc12 += try std.fmt.parseUnsigned(u64, &buf12, 10);
    //     break :blk .{ acc2, acc12 };
    // };

    std.debug.print("{D}\n{d}\t{d}\n", .{ timer.lap(), acc2, acc12 });
}
