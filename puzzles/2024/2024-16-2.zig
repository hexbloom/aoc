const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Node = struct {
    cell: vec2,
    dir: vec2,
};

pub fn main() !void {
    var grid_list = std.ArrayList([]const u8).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    const start_cell = vec2{ 1, @intCast(grid.len - 2) };
    const end_cell = vec2{ @intCast(grid[0].len - 2), 1 };

    var visited = std.AutoHashMap(Node, usize).init(ally);

    var queue_nodes = std.ArrayList(Node).init(ally);
    var queue_costs = std.ArrayList(usize).init(ally);
    try queue_nodes.append(.{ .cell = start_cell, .dir = .{ 1, 0 } });
    try queue_costs.append(0);

    while (queue_nodes.items.len > 0) {
        const node = queue_nodes.pop();
        const cost = queue_costs.pop();

        if (visited.get(node)) |visited_cost| {
            if (cost >= visited_cost) {
                continue;
            }
        }

        try visited.put(node, cost);

        var node_fwd = node;
        node_fwd.cell = node.cell + node.dir;
        if (isValidCell(node_fwd.cell, grid)) {
            try queue_nodes.append(node_fwd);
            try queue_costs.append(cost + 1);
        }

        const next_dirs = [_]vec2{ rotateLeft(node.dir), rotateRight(node.dir) };
        for (next_dirs) |next_dir| {
            var node_turn = node;
            node_turn.dir = next_dir;
            try queue_nodes.append(node_turn);
            try queue_costs.append(cost + 1000);
        }
    }

    var min_cost = @as(usize, std.math.maxInt(usize));
    var end_node: Node = undefined;
    const all_dirs = [_]vec2{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };
    for (all_dirs) |dir| {
        const node = Node{ .cell = end_cell, .dir = dir };
        const cost = visited.get(node) orelse continue;
        if (cost < min_cost) {
            min_cost = cost;
            end_node = node;
        }
    }

    var best_path_cells = std.AutoHashMap(vec2, void).init(ally);
    queue_nodes.clearRetainingCapacity();

    try queue_nodes.append(end_node);
    try best_path_cells.put(end_cell, {});
    while (queue_nodes.items.len > 0) {
        const node = queue_nodes.pop();
        const cost = visited.get(node).?;

        if (@reduce(.And, node.cell == start_cell)) {
            continue;
        }

        var node_rev = node;
        node_rev.cell = node.cell - node.dir;
        if (visited.get(node_rev)) |cost_rev| {
            if (cost == cost_rev + 1) {
                try queue_nodes.append(node_rev);
                try best_path_cells.put(node_rev.cell, {});
            }
        }

        const prev_dirs = [_]vec2{ rotateRight(node.dir), rotateLeft(node.dir) };
        for (prev_dirs) |prev_dir| {
            var node_turn = node;
            node_turn.dir = prev_dir;
            if (visited.get(node_turn)) |cost_turn| {
                if (cost == cost_turn + 1000) {
                    try queue_nodes.append(node_turn);
                    try best_path_cells.put(node_turn.cell, {});
                }
            }
        }
    }

    std.debug.print("{}", .{best_path_cells.count()});
}

fn isValidCell(cell: vec2, grid: [][]const u8) bool {
    if (cell[0] < 0 or cell[0] >= grid[0].len or cell[1] < 0 or cell[1] >= grid.len) {
        return false;
    }

    if (grid[@intCast(cell[1])][@intCast(cell[0])] == '#') {
        return false;
    }

    return true;
}

fn rotateLeft(dir: vec2) vec2 {
    return .{ dir[1], -dir[0] };
}

fn rotateRight(dir: vec2) vec2 {
    return .{ -dir[1], dir[0] };
}
