const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/3.txt");

fn buf2_incorporate(buf2: *[2]u8, next: u8) void {
    if (next >= buf2[0]) {
        if (buf2[0] > buf2[1])
            buf2[1] = buf2[0];
        buf2[0] = next;
    }
}

fn parseInt(N: comptime_int, buf: [N]u8) u64 {
    if (N > 19) @compileError("A u64 can only fit 19 decimal digits");
    const offset = comptime blk: {
        var acc = 0;
        for (0..N) |_| {
            acc *= 10;
            acc += '0';
        }
        break :blk acc;
    };
    var result: u64 = 0;
    for (buf) |c| {
        result *= 10;
        result += c;
    }
    return result - offset;
}

pub fn main() !void {
    var timer = std.time.Timer.start();

    // @setEvalBranchQuota(75000);
    // const acc2, const acc12 = comptime blk: {
    var buf2: [2]u8 = undefined;
    var buf12: [12]u8 = undefined;
    var acc2: u64 = 0;
    var acc12: u64 = 0;
    var i: usize = input.len - 14;
    assert(input[i + 13] == '\n');

    loop: switch (@as(enum { reset, take, acc }, .reset)) {
        .reset => {
            assert(input[i..][12] == '\r');
            @memcpy(&buf12, input[i..][0..12]);
            @memcpy(&buf2, buf12[10..]);
            for (0..10) |count| {
                buf2_incorporate(&buf2, buf12[9 - count]);
            }
            continue :loop .take;
        },
        .take => {
            i -= 1;
            var next = input[i];
            assert(next != '\r');
            if (next == '\n') {
                i -= 13;
                continue :loop .acc;
            }
            buf2_incorporate(&buf2, next);
            for (&buf12) |*d| {
                const digit = d.*;
                if (next < digit) break;
                d.* = next;
                next = digit;
            }
            if (i > 0) continue :loop .take;
        },
        .acc => {
            acc2 += parseInt(2, buf2);
            acc12 += parseInt(12, buf12);
            continue :loop .reset;
        },
    }
    acc2 += parseInt(2, buf2);
    acc12 += parseInt(12, buf12);
    //     break :blk .{ acc2, acc12 };
    // };

    std.debug.print("{D}\n{d}\t{d}\n", .{ if (timer) |*t| t.lap() else |_| 0, acc2, acc12 });
}
