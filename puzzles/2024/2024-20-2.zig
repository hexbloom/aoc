const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Node = struct {
    cell: vec2,
    cost: isize,

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

    var visited = std.AutoHashMap(vec2, isize).init(ally);
    var queue = std.PriorityQueue(Node, void, Node.compare).init(ally, {});
    try queue.add(.{ .cell = start_cell, .cost = 0 });
    while (queue.removeOrNull()) |node| {
        try visited.put(node.cell, node.cost);
        const adj_dirs = [_]vec2{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };
        for (adj_dirs) |adj_dir| {
            const adj_cell = node.cell + adj_dir;
            if (visited.get(adj_cell) != null or !isValidCell(grid, adj_cell)) {
                continue;
            }
            try queue.add(.{ .cell = adj_cell, .cost = node.cost + 1 });
        }
    }

    var res: usize = 0;
    var visited_it = visited.iterator();
    while (visited_it.next()) |entry| {
        const cell = entry.key_ptr.*;
        const cost = entry.value_ptr.*;

        const max_cheat = 20;
        for (0..max_cheat * 2 + 1) |y| {
            for (0..max_cheat * 2 + 1) |x| {
                const off_x = @as(isize, @intCast(x)) - max_cheat;
                const off_y = @as(isize, @intCast(y)) - max_cheat;
                const cheat_cell = cell + vec2{ off_x, off_y };
                const dist = @as(isize, @intCast(@reduce(.Add, @abs(cheat_cell - cell))));
                if (dist > max_cheat or !isValidCell(grid, cheat_cell)) {
                    continue;
                }
                if (visited.get(cheat_cell)) |cheat_cell_cost| {
                    if (cheat_cell_cost - cost - dist >= 100) {
                        res += 1;
                    }
                }
            }
        }
    }

    std.debug.print("{}", .{res});
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
