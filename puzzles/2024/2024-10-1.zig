const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var grid_list = std.ArrayList([]const u8).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    var found = std.AutoHashMap(vec2, void).init(ally);
    var res: usize = 0;
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == '0') {
                found.clearRetainingCapacity();
                res += try calcScore(grid, @intCast(x), @intCast(y), '0', &found);
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn calcScore(
    grid: [][]const u8,
    x: isize,
    y: isize,
    height: u8,
    found: *std.AutoHashMap(vec2, void),
) !usize {
    if (x < 0 or x >= grid[0].len or y < 0 or y >= grid.len) {
        return 0;
    }

    if (grid[@intCast(y)][@intCast(x)] != height) {
        return 0;
    }

    if (height == '9') {
        const cell = vec2{ x, y };
        if (found.get(cell) == null) {
            try found.put(cell, {});
            return 1;
        } else {
            return 0;
        }
    }

    const next_height = height + 1;
    var score: usize = 0;
    score += try calcScore(grid, x - 1, y, next_height, found);
    score += try calcScore(grid, x + 1, y, next_height, found);
    score += try calcScore(grid, x, y + 1, next_height, found);
    score += try calcScore(grid, x, y - 1, next_height, found);

    return score;
}
