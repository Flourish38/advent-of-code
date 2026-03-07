const std = @import("std");
const assert = std.debug.assert;

const input = @embedFile("input/11.txt");

const Node = u16;
const Count = u64;

var names_buf: [1 << 10]u24 = undefined;
var offsets_buf: [1 << 10]Node = @splat(0);

var children_buf: [1 << 12]Node = undefined;

var dp_buf: [4][1 << 10]Count = @splat(@splat(NONE));

var stack_buf: [1 << 10]StackFrame = undefined;

const END: Node = std.math.maxInt(Node);
const NONE: Count = std.math.maxInt(Count);

const StackFrame = struct {
    node: Node,
    child: Node,
    total: Count = 0,
};

const FFT: u2 = 0b10;
const DAC: u2 = 0b01;

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var tokens = std.mem.tokenizeAny(u8, input, " \r\n");

    var names_list: std.ArrayList(u24) = .initBuffer(&names_buf);

    var children_list: std.ArrayList(Node) = .initBuffer(&children_buf);

    while (tokens.next()) |token| {
        const name: u24 = @bitCast(token[0..3].*);

        const index: Node = @intCast(std.mem.indexOfScalar(u24, names_list.items, name) orelse blk: {
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
    children_list.appendAssumeCapacity(END);

    const offsets: []const Node = offsets_buf[0..names_list.items.len];
    const children: []const Node = children_list.items;

    const svr: Node = @intCast(std.mem.indexOfScalar(u24, names_list.items, @bitCast("svr "[0..3].*)).?);
    const out: Node = @intCast(std.mem.indexOfScalar(u24, names_list.items, @bitCast("out "[0..3].*)).?);
    const fft: Node = @intCast(std.mem.indexOfScalar(u24, names_list.items, @bitCast("fft "[0..3].*)).?);
    const dac: Node = @intCast(std.mem.indexOfScalar(u24, names_list.items, @bitCast("dac "[0..3].*)).?);

    var stack: std.ArrayList(StackFrame) = .initBuffer(&stack_buf);

    stack.appendAssumeCapacity(.{ .node = svr, .child = offsets[svr] });

    // var visited: std.bit_set.ArrayBitSet(usize, 1 << 10) = .initEmpty();

    var state: u2 = 0;

    // visited.set(svr);

    while (stack.pop()) |frame| {
        // assert((state & FFT == FFT) == visited.isSet(fft));
        // assert((state & DAC == DAC) == visited.isSet(dac));
        const prev_node = children[frame.child -| 1];
        const total = frame.total + if (prev_node != END and dp_buf[state][prev_node] != NONE) dp_buf[state][prev_node] else 0;

        // visited.unset(frame.node);
        state &= if (frame.node == fft) ~FFT else if (frame.node == dac) ~DAC else FFT | DAC;

        // if (stack.items.len < 30) {
        //     std.debug.print("{d}\t{d}\t{d}\t{d}\n", .{ stack.items.len, frame.node, frame.child, frame.total });
        // }

        const next_node = children[frame.child];
        if (next_node == END) {
            dp_buf[state][frame.node] = total;
            continue;
        }
        if (next_node == out and state == FFT | DAC) {
            stack.appendAssumeCapacity(.{
                .node = frame.node,
                .child = frame.child + 1,
                .total = total + 1,
            });
            continue;
        }
        stack.appendAssumeCapacity(.{ .node = frame.node, .child = frame.child + 1, .total = total });
        state |= if (frame.node == fft) FFT else if (frame.node == dac) DAC else 0;
        // visited.set(frame.node);
        // assert(!visited.isSet(next_node));
        if (dp_buf[state][next_node] != NONE) continue;
        stack.appendAssumeCapacity(.{ .node = next_node, .child = offsets[next_node] });
        // visited.set(next_node);
        state |= if (next_node == fft) FFT else if (next_node == dac) DAC else 0;
    }

    std.debug.print("{D}\n{any}\n", .{ timer.lap(), dp_buf[0][svr] });
}
