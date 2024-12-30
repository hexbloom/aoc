const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Gate = struct {
    inputs: [2][]const u8,
    output: ?u1,
    op: []const u8,
};

const GateMap = std.StringHashMap(Gate);
const SwapSet = std.ArrayList([]const u8);

pub fn main() !void {
    var gate_map = GateMap.init(ally);
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

    var swap_set = SwapSet.init(ally);
    var prev: [2][]const u8 = undefined;
    for (z_gates.items[0..], 0..) |z_gate, z_index| {
        // skipping exception cases - hand-verified these...
        if (z_index == 0) {
            continue;
        }
        if (z_index == 1) {
            prev = gate_map.get(z_gate).?.inputs;
            continue;
        }
        if (z_index == z_gates.items.len - 1) {
            break;
        }

        try swapInvalidGates(&gate_map, &swap_set, @intCast(z_index), prev);
        prev = gate_map.get(z_gate).?.inputs;
    }

    std.mem.sort([]const u8, swap_set.items, {}, lessThanStr);
    for (swap_set.items) |swap| {
        std.debug.print("{s},", .{swap});
    }
}

fn swapInvalidGates(map: *GateMap, swap: *SwapSet, index: u8, prev: [2][]const u8) !void {
    const z_id = getGateId('z', index)[0..];

    // try to replace at the top level
    if (!isXorTopLevel(map.*, z_id, index)) {
        var gate_it = map.iterator();
        while (gate_it.next()) |entry| {
            const name = entry.key_ptr.*;
            if (!std.mem.eql(u8, name, z_id) and isXorTopLevel(map.*, name, index)) {
                try swapGates(map, swap, z_id, name);
                break;
            }
        }
    }

    // go one level deeper if first attempt failed
    if (!isXorTopLevel(map.*, z_id, index)) {
        const z_gate = map.get(z_id).?;
        const id = if (isOrTopLevel(map.*, z_gate.inputs[0], index, prev))
            z_gate.inputs[1]
        else if (isOrTopLevel(map.*, z_gate.inputs[1], index, prev))
            z_gate.inputs[0]
        else
            return error.UnhandledCodeFlow;

        var gate_it = map.iterator();
        while (gate_it.next()) |entry| {
            const name = entry.key_ptr.*;
            if (!std.mem.eql(u8, name, id) and xyOpIndex(map.*, name, "XOR", index)) {
                try swapGates(map, swap, id, name);
                break;
            }
        }
    }
}

// a XOR b -> z<index>
// a/b = x<index> XOR y<index>
fn isXorTopLevel(map: GateMap, name: []const u8, index: u8) bool {
    const gate = map.get(name).?;
    if (!std.mem.eql(u8, gate.op, "XOR")) {
        return false;
    }

    return xyOpIndex(map, gate.inputs[0], "XOR", index) or
        xyOpIndex(map, gate.inputs[1], "XOR", index);
}

// c OR d
// c/d = x<index - 1> AND y<index - 1>, prev[0] AND prev[1]
fn isOrTopLevel(map: GateMap, name: []const u8, index: u8, prev: [2][]const u8) bool {
    const gate = map.get(name).?;
    if (!std.mem.eql(u8, gate.op, "OR")) {
        return false;
    }

    return (xyOpIndex(map, gate.inputs[0], "AND", index - 1) and opVals(map, gate.inputs[1], "AND", prev)) or
        (xyOpIndex(map, gate.inputs[1], "AND", index - 1) and opVals(map, gate.inputs[0], "AND", prev));
}

fn xyOpIndex(map: GateMap, name: []const u8, op: []const u8, index: u8) bool {
    const x = getGateId('x', index)[0..];
    const y = getGateId('y', index)[0..];
    return opVals(map, name, op, .{ x, y });
}

fn opVals(map: GateMap, name: []const u8, op: []const u8, vals: [2][]const u8) bool {
    const gate = map.get(name).?;
    if (!std.mem.eql(u8, gate.op, op)) {
        return false;
    }

    return (std.mem.eql(u8, gate.inputs[0], vals[0]) and std.mem.eql(u8, gate.inputs[1], vals[1])) or
        (std.mem.eql(u8, gate.inputs[1], vals[0]) and std.mem.eql(u8, gate.inputs[0], vals[1]));
}

fn swapGates(map: *GateMap, swap: *SwapSet, a: []const u8, b: []const u8) !void {
    std.mem.swap(Gate, map.getPtr(a).?, map.getPtr(b).?);
    try swap.append(a);
    try swap.append(b);
}

fn getGateId(prefix: u8, val: u8) [3]u8 {
    var id: [3]u8 = undefined;
    id[0] = prefix;
    id[1] = '0' + val / 10;
    id[2] = '0' + val % 10;
    return id;
}

fn lessThanStr(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
}
