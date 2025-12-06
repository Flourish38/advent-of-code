const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/5.txt");

fn binarySearchHighestLeq(items: []u64, target: u64) usize {
    var lo: usize = 0;
    var hi = items.len;
    while (hi - lo > 1) {
        const mid = lo + (hi - lo) / 2;
        if (items[mid] <= target) lo = mid else hi = mid;
    }
    return lo;
}

const SortCtx = struct {
    starts: []const u64,

    pub fn lessThan(ctx: SortCtx, a_index: usize, b_index: usize) bool {
        return ctx.starts[a_index] < ctx.starts[b_index];
    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var ranges_list: std.MultiArrayList(struct { start: u64, end: u64 }) = .empty;
    defer ranges_list.deinit(allocator);

    var current_number: u64 = 0;
    var saw_newline = false;
    var range_start: u64 = undefined;

    for (input, 0..) |c, i| {
        switch (c) {
            '-' => {
                range_start = current_number;
                current_number = 0;
            },
            '\r' => {},
            '\n' => {
                if (saw_newline) {
                    range_start = i + 1;
                    break;
                }
                try ranges_list.append(allocator, .{ .start = range_start, .end = current_number });
                current_number = 0;
                saw_newline = true;
            },
            else => {
                saw_newline = false;
                assert(std.ascii.isDigit(c));
                current_number = 10 * current_number + c - '0';
            },
        }
    }

    var ranges = ranges_list.slice();
    const sort_ctx: SortCtx = .{ .starts = ranges.items(.start) };
    ranges_list.sortUnstable(sort_ctx);

    // merge ranges
    var current = ranges.get(0);
    var i: usize = 1;
    while (i < ranges_list.len) : (i += 1) {
        const next = ranges.get(i);
        // std.debug.print("{any}\t{any}\n", .{ current, next });
        if (next.start - 1 <= current.end) {
            ranges_list.orderedRemove(i);
            ranges.len -= 1;
            i -= 1;
            ranges.items(.end)[i] = @max(current.end, next.end); // nasty bug, forgetting to `@max`
            current = ranges.get(i);
        } else {
            current = next;
        }
    }

    var acc: u64 = 0;

    for (ranges.items(.start), ranges.items(.end)) |start, end| {
        // std.debug.print("{d}-{d}\n", .{ start, end });
        acc += end - start + 1;
    }

    std.debug.print("{d}\n", .{acc});
}
