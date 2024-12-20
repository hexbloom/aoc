const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Node = struct {
    cell: vec2,
    cost: usize,

    fn compare(_: void, a: Node, b: Node) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

pub fn main() !void {
    var grid_list = std.ArrayList([]u8).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try grid_list.append(try ally.dupe(u8, line));
    }
    const grid = try grid_list.toOwnedSlice();

    var start_cell: vec2 = undefined;
    var end_cell: vec2 = undefined;
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            const cell = vec2{ @intCast(x), @intCast(y) };
            if (col == 'S') {
                start_cell = cell;
            }
            if (col == 'E') {
                end_cell = cell;
            }
        }
    }

    var res: usize = 0;
    const base_cost = try getLowestCost(grid, start_cell, end_cell);
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col != '#') {
                continue;
            }

            const cell = vec2{ @intCast(x), @intCast(y) };
            const dirs = [_]vec2{ .{ 1, 0 }, .{ 0, 1 } };
            var valid_cheat_cell = false;
            for (dirs) |dir| {
                if (isValidCell(grid, cell + dir) and isValidCell(grid, cell - dir)) {
                    valid_cheat_cell = true;
                    break;
                }
            }

            if (valid_cheat_cell) {
                grid[y][x] = '.';
                if (try getLowestCost(grid, start_cell, end_cell) + 100 <= base_cost) {
                    res += 1;
                }
                grid[y][x] = '#';
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn getLowestCost(grid: [][]const u8, start_cell: vec2, end_cell: vec2) !usize {
    var visited = std.AutoHashMap(vec2, Node).init(ally);
    var queue = std.PriorityQueue(Node, void, Node.compare).init(ally, {});
    try queue.add(.{ .cell = start_cell, .cost = 0 });
    while (queue.removeOrNull()) |node| {
        try visited.put(node.cell, node);
        const adj_dirs = [_]vec2{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };
        for (adj_dirs) |adj_dir| {
            const adj_cell = node.cell + adj_dir;
            if (visited.get(adj_cell) != null or !isValidCell(grid, adj_cell)) {
                continue;
            }
            try queue.add(.{ .cell = adj_cell, .cost = node.cost + 1 });
        }
    }

    const end = visited.get(end_cell).?;
    return end.cost;
}

fn isValidCell(grid: [][]const u8, cell: vec2) bool {
    if (cell[0] < 0 or cell[0] >= grid[0].len or cell[1] < 0 or cell[1] >= grid.len) {
        return false;
    }

    if (grid[@intCast(cell[1])][@intCast(cell[0])] == '#') {
        return false;
    }

    return true;
}
