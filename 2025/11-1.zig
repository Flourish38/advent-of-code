const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/11.txt");

var names_buf: [1 << 10]u24 = undefined;
var offsets_buf: [1 << 10]u16 = undefined;

var children_buf: [1 << 12]u16 = undefined;

const END: u16 = ~@as(u16, 0);

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var tokens = std.mem.tokenizeAny(u8, input, " \r\n");

    var names_list: std.ArrayList(u24) = .initBuffer(&names_buf);

    var children_list: std.ArrayList(u16) = .initBuffer(&children_buf);

    while (tokens.next()) |token| {
        const name: u24 = @bitCast(token[0..3].*);

        const index: u16 = @intCast(std.mem.indexOfScalar(u24, names_list.items, name) orelse blk: {
            const i = names_list.items.len;
            names_list.appendAssumeCapacity(name);
            break :blk i;
        });

        assert(token.len == 3 or token.len == 4);
        if (token.len == 4) {
            assert(token[3] == ':');
            children_list.appendAssumeCapacity(END);
            offsets_buf[index] = @intCast(children_list.items.len);
        } else {
            children_list.appendAssumeCapacity(index);
        }
    }

    const offsets: []const u16 = offsets_buf[0..names_list.items.len];
    const children: []const u16 = children_list.items;

    const you_index = std.mem.indexOfScalar(u24, names_list.items, @bitCast("you "[0..3].*)).?;
    const out_index = std.mem.indexOfScalar(u24, names_list.items, @bitCast("out "[0..3].*)).?;

    const num_paths = count_paths(offsets, children, @intCast(you_index), @intCast(out_index));

    std.debug.print("{D}\n{any}\n", .{ timer.lap(), num_paths });
}

fn count_paths(offsets: []const u16, children: []const u16, from: u16, to: u16) u64 {
    const offset = offsets[from];
    const ptr: [*:END]const u16 = @ptrCast(&children[offset]);
    var total: u64 = 0;
    for (std.mem.span(ptr)) |child| {
        total += if (child == to)
            1
        else
            count_paths(offsets, children, child, to);
    }
    return total;
}
