const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Node = struct {
    cell: vec2,
    dir: vec2,
    cost: usize,
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

    var visited = std.AutoHashMap(vec2, Node).init(ally);

    var queue = std.ArrayList(Node).init(ally);
    try queue.append(.{
        .cell = start_cell,
        .dir = .{ 1, 0 },
        .cost = 0,
    });

    while (queue.items.len > 0) {
        const node = queue.pop();
        if (visited.get(node.cell)) |visited_node| {
            if (node.cost >= visited_node.cost) {
                continue;
            }
        }

        try visited.put(node.cell, node);

        const next_dirs = [_]vec2{ node.dir, rotateLeft(node.dir), rotateRight(node.dir) };
        for (next_dirs) |next_dir| {
            const next_cell = node.cell + next_dir;
            const next_cost: usize = if (@reduce(.And, node.dir == next_dir)) 1 else 1001;
            if (isValidCell(next_cell, grid)) {
                try queue.append(.{
                    .cell = next_cell,
                    .dir = next_dir,
                    .cost = node.cost + next_cost,
                });
            }
        }
    }

    std.debug.print("{}", .{visited.get(end_cell).?.cost});
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
