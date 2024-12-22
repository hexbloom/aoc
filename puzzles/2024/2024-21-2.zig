const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const num_pad = &[_][]const u8{ "789", "456", "123", "X0A" };
const key_pad = &[_][]const u8{ "X^A", "<v>" };

const PadPath = struct {
    start: u8,
    end: u8,
};

const PadPathNode = struct {
    cell: vec2,
    path: std.ArrayList(u8),

    fn compare(_: void, a: PadPathNode, b: PadPathNode) std.math.Order {
        return std.math.order(a.path.items.len, b.path.items.len);
    }
};

const PadMap = std.AutoHashMap(PadPath, []const []const u8);
const MemoMap = [max_depth + 1]std.StringHashMap(usize);

const max_depth = 26;

pub fn main() !void {
    var best_paths = PadMap.init(ally);
    try findBestPadPaths(num_pad, &best_paths);
    try findBestPadPaths(key_pad, &best_paths);

    var memo: MemoMap = undefined;
    for (0..memo.len) |i| {
        memo[i] = std.StringHashMap(usize).init(ally);
    }
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var res: usize = 0;
    while (lines.next()) |line| {
        const count = try countKeyPresses(max_depth, line, &memo, best_paths);
        const val = try std.fmt.parseInt(usize, line[0 .. line.len - 1], 10);
        res += count * val;
    }
    std.debug.print("{}", .{res});
}

fn countKeyPresses(depth: usize, keys: []const u8, memo: *MemoMap, best_paths: PadMap) !usize {
    if (depth == 0) {
        return keys.len;
    }

    if (memo[depth].get(keys)) |count| {
        return count;
    }

    var count: usize = 0;
    var prev_key: u8 = 'A';
    for (keys) |key| {
        var min = @as(usize, std.math.maxInt(usize));
        for (best_paths.get(.{ .start = prev_key, .end = key }).?) |path| {
            min = @min(min, try countKeyPresses(depth - 1, path, memo, best_paths));
        }
        count += min;
        prev_key = key;
    }

    try memo[depth].put(keys, count);
    return count;
}

fn findBestPadPaths(pad: []const []const u8, map: *PadMap) !void {
    for (0..pad.len) |start_y| {
        for (0..pad[0].len) |start_x| {
            for (0..pad.len) |end_y| {
                for (0..pad[0].len) |end_x| {
                    const start = vec2{ @intCast(start_x), @intCast(start_y) };
                    const end = vec2{ @intCast(end_x), @intCast(end_y) };
                    try findBestPaths(pad, start, end, map);
                }
            }
        }
    }
}

fn findBestPaths(pad: []const []const u8, start: vec2, end: vec2, map: *PadMap) !void {
    const start_char = pad[@intCast(start[1])][@intCast(start[0])];
    const end_char = pad[@intCast(end[1])][@intCast(end[0])];
    if (start_char == 'X' or end_char == 'X') {
        return;
    }

    var visited = std.AutoHashMap(vec2, void).init(ally);
    var queue = std.PriorityQueue(PadPathNode, void, PadPathNode.compare).init(ally, {});
    try queue.add(.{ .cell = start, .path = std.ArrayList(u8).init(ally) });

    var best_path_len: ?usize = null;
    var best_paths = std.ArrayList([]const u8).init(ally);
    while (queue.removeOrNull()) |node| {
        try visited.put(node.cell, {});
        if (@reduce(.And, node.cell == end)) {
            var add_best_path = false;
            if (best_path_len) |len| {
                if (node.path.items.len == len) {
                    add_best_path = true;
                }
            } else {
                best_path_len = node.path.items.len;
                add_best_path = true;
            }

            if (add_best_path) {
                var path = try node.path.clone();
                try path.append('A');
                try best_paths.append(try path.toOwnedSlice());
            }
        }
        const adj_dirs = [_]vec2{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };
        const adj_icons = [_]u8{ '>', 'v', '<', '^' };
        for (adj_dirs, adj_icons) |adj_dir, adj_icon| {
            const adj_cell = node.cell + adj_dir;
            if (visited.get(adj_cell) != null or !isValidCell(pad, adj_cell)) {
                continue;
            }
            var path = try node.path.clone();
            try path.append(adj_icon);
            try queue.add(.{ .cell = adj_cell, .path = path });
        }
    }

    try map.put(.{ .start = start_char, .end = end_char }, try best_paths.toOwnedSlice());
}

fn isValidCell(pad: []const []const u8, cell: vec2) bool {
    if (cell[0] < 0 or cell[0] >= pad[0].len or cell[1] < 0 or cell[1] >= pad.len) {
        return false;
    }

    if (pad[@intCast(cell[1])][@intCast(cell[0])] == 'X') {
        return false;
    }

    return true;
}
