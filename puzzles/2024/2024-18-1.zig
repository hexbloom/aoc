const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Node = struct {
    cell: vec2,
    cost: usize,
};

const grid_width = 70;
const grid_height = 70;

pub fn main() !void {
    var blocks = std.AutoHashMap(vec2, void).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    for (0..1024) |_| {
        var split = std.mem.tokenizeScalar(u8, lines.next().?, ',');
        try blocks.put(.{
            try std.fmt.parseInt(isize, split.next().?, 10),
            try std.fmt.parseInt(isize, split.next().?, 10),
        }, {});
    }

    const start = vec2{ 0, 0 };
    const end = vec2{ 70, 70 };

    var visited = std.AutoHashMap(vec2, Node).init(ally);

    var queue = std.ArrayList(Node).init(ally);
    try queue.append(.{
        .cell = start,
        .cost = 0,
    });

    while (queue.items.len > 0) {
        const node = queue.orderedRemove(0);
        if (visited.get(node.cell)) |visited_node| {
            if (node.cost >= visited_node.cost) {
                continue;
            }
        }

        try visited.put(node.cell, node);

        const adj_cells = [_]vec2{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };
        for (adj_cells) |adj_cell| {
            const next_cell = node.cell + adj_cell;
            if (isValidCell(next_cell, blocks)) {
                try queue.append(.{
                    .cell = next_cell,
                    .cost = node.cost + 1,
                });
            }
        }
    }

    std.debug.print("{}", .{visited.get(end).?.cost});
}

fn isValidCell(cell: vec2, blocks: std.AutoHashMap(vec2, void)) bool {
    if (cell[0] < 0 or cell[0] > grid_width or cell[1] < 0 or cell[1] > grid_height) {
        return false;
    }

    if (blocks.get(cell) != null) {
        return false;
    }

    return true;
}
