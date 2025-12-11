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

    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

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

    const n = points[0].items.len;

    var dists: std.ArrayList(f32) = try .initCapacity(allocator, n * (n - 1));
    defer dists.deinit(allocator);

    for (points[0].items, points[1].items, points[2].items, 0..) |x, y, z, i| {
        for (points[0].items, points[1].items, points[2].items, 0..) |a, b, c, j| {
            if (i == n - 1) continue;
            const dist = if (i == j)
                std.math.inf(f32)
            else
                @sqrt(@as(f32, @floatFromInt((x - a) * (x - a) + (y - b) * (y - b) + (z - c) * (z - c))));
            dists.appendAssumeCapacity(dist);
        }
    }

    assert(dists.capacity == dists.items.len);

    var sets: std.ArrayList(std.bit_set.IntegerBitSet(1 << 10)) = .empty;
    defer sets.deinit(allocator);

    var i: usize = undefined;
    var j: usize = undefined;
    // can't believe I got all this garbage right first try...
    while (blk: {
        const k = std.mem.indexOfMin(f32, dists.items);
        dists.items[k] = std.math.inf(f32);
        i = k / n;
        j = k - i * n;
        var set_i = blk_inner: {
            for (sets.items, 0..) |*set, set_i| {
                if (set.isSet(i) or set.isSet(j)) {
                    set.set(i);
                    set.set(j);
                    break :blk_inner set_i;
                }
            }
            var new_set: std.bit_set.IntegerBitSet(1 << 10) = .initEmpty();
            new_set.set(i);
            new_set.set(j);
            try sets.append(allocator, new_set);
            break :blk true;
        };
        const set: *std.bit_set.IntegerBitSet(1 << 10) = &sets.items[set_i];
        set_i += 1;
        while (set_i < sets.items.len) {
            const other = sets.items[set_i];
            if (other.isSet(i) or other.isSet(j)) {
                set.setUnion(other);
                _ = sets.swapRemove(set_i);
            } else {
                set_i += 1;
            }
        }
        break :blk sets.items[0].count() < n;
    }) {}
    assert(sets.items.len == 1);

    std.debug.print("{D}\n{d}\n", .{ timer.lap(), points[0].items[i] * points[0].items[j] });
}
