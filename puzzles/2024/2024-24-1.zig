const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Gate = struct {
    inputs: [2][]const u8,
    output: ?u1,
    op: []const u8,
};

pub fn main() !void {
    var gate_map = std.StringHashMap(Gate).init(ally);
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var split = std.mem.tokenizeSequence(u8, line, ": ");
        const name = split.next().?;
        const value = try std.fmt.parseInt(u1, split.next().?, 10);
        try gate_map.put(name, .{
            .inputs = undefined,
            .output = value,
            .op = undefined,
        });
    }

    var z_gates = std.ArrayList([]const u8).init(ally);
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var split = std.mem.tokenizeAny(u8, line, " ->");
        const a = split.next().?;
        const op = split.next().?;
        const b = split.next().?;
        const name = split.next().?;
        try gate_map.put(name, .{
            .inputs = [_][]const u8{ a, b },
            .output = null,
            .op = op,
        });

        if (std.mem.startsWith(u8, name, "z")) {
            try z_gates.append(name);
        }
    }

    std.mem.sort([]const u8, z_gates.items, {}, lessThanStr);

    var res: usize = 0;
    for (z_gates.items, 0..) |z_gate, bit| {
        res |= @as(usize, @intCast(try getGateOutput(gate_map, z_gate))) << @intCast(bit);
    }
    std.debug.print("{}", .{res});
}

fn getGateOutput(gate_map: std.StringHashMap(Gate), name: []const u8) !u1 {
    if (gate_map.getPtr(name)) |gate| {
        if (gate.output == null) {
            const a = try getGateOutput(gate_map, gate.inputs[0]);
            const b = try getGateOutput(gate_map, gate.inputs[1]);
            gate.output = if (std.mem.eql(u8, gate.op, "AND"))
                a & b
            else if (std.mem.eql(u8, gate.op, "OR"))
                a | b
            else if (std.mem.eql(u8, gate.op, "XOR"))
                a ^ b
            else
                return error.InvalidGateOp;
        }
        return gate.output.?;
    }

    return error.InvalidGateMap;
}

fn lessThanStr(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
}
