const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/8.txt");

var point_buffer: [3][1 << 10]i64 = undefined;

const N = 1000;

var circuit_buffer: [128]usize = undefined;

// var circuits_buffer: [3 * N]enum(u16) { terminal = ~0, _ } = @splat(.terminal);

fn binarySearchLowestGeq(comptime T: type, items: []const T, target: T) usize {
    var lo: usize = 0;
    var hi = items.len - 1;
    while (hi - lo > 1) {
        const mid = lo + (hi - lo) / 2;
        if (items[mid] < target) lo = mid else hi = mid;
        // std.debug.print("{d}-{d}\t{d}\t{any}\n", .{ lo, hi, target, items });
    }
    if (items[lo] >= target) hi = lo;
    return hi;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var lines = std.mem.tokenizeAny(u8, input, "\r\n");

    var points: [3]std.ArrayList(i64) = @splat(.empty);
    for (&points, &point_buffer) |*axis, *buffer| {
        axis.* = .initBuffer(buffer);
    }

    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ',');

        for (&points) |*axis| {
            const coord = try std.fmt.parseUnsigned(i64, nums.next().?, 10);
            axis.appendAssumeCapacity(coord);
        }
    }

    var min_dists: [N]f32 = @splat(std.math.inf(f32));
    var min_pairs: [N][2]usize = undefined;

    for (points[0].items, points[1].items, points[2].items, 1..) |x, y, z, i| {
        for (points[0].items[i..], points[1].items[i..], points[2].items[i..], i..) |a, b, c, j| {
            const dist = @sqrt(@as(f32, @floatFromInt((x - a) * (x - a) + (y - b) * (y - b) + (z - c) * (z - c))));
            if (dist > min_dists[N - 1]) continue;
            const k = binarySearchLowestGeq(f32, &min_dists, dist);
            @memmove(min_dists[k + 1 ..], min_dists[k .. N - 1]);
            @memmove(min_pairs[k + 1 ..], min_pairs[k .. N - 1]);
            min_dists[k] = dist;
            min_pairs[k] = .{ i - 1, j };
            // std.debug.print("{any}\n{any}\n\n", .{ min_dists, min_pairs });
        }
    }

    var pairs_integrated: [N]bool = @splat(false);
    var top_3_len: [3]usize = @splat(0);

    for (min_pairs, 0..) |pair, i| {
        if (pairs_integrated[i]) continue;
        var circuit: std.ArrayList(usize) = .initBuffer(&circuit_buffer);
        circuit.appendAssumeCapacity(pair[0]);
        circuit.appendAssumeCapacity(pair[1]);
        var any_changed: bool = true;
        while (any_changed) {
            any_changed = false;
            for (min_pairs[i + 1 ..], i + 1..) |other, j| {
                if (pairs_integrated[j]) continue;
                const has_first = std.mem.containsAtLeastScalar(usize, circuit.items, 1, other[0]);
                const has_second = std.mem.containsAtLeastScalar(usize, circuit.items, 1, other[1]);
                if (has_first or has_second) {
                    if (has_first ^ has_second)
                        if (has_first)
                            circuit.appendAssumeCapacity(other[1])
                        else
                            circuit.appendAssumeCapacity(other[0]);
                    pairs_integrated[j] = true;
                    any_changed = true;
                }
            }
        }
        var tmp: usize = circuit.items.len;

        if (top_3_len[2] < tmp) {
            for (&top_3_len) |*len| {
                if (len.* < tmp) {
                    std.mem.swap(usize, &tmp, len);
                }
            }
            // std.debug.print("{any}\t{d}\n", .{ top_3_len, tmp });
        }
    }

    var prod: usize = top_3_len[0];
    for (top_3_len[1..]) |len| {
        prod *= len;
    }

    std.debug.print("{D}\n{any}\n", .{ timer.lap(), prod });
}
