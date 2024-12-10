const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var grid_list = std.ArrayList([]const u8).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    var res: usize = 0;
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == '0') {
                res += calcScore(grid, @intCast(x), @intCast(y), '0');
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn calcScore(grid: [][]const u8, x: isize, y: isize, height: u8) usize {
    if (x < 0 or x >= grid[0].len or y < 0 or y >= grid.len) {
        return 0;
    }

    if (grid[@intCast(y)][@intCast(x)] != height) {
        return 0;
    }

    if (height == '9') {
        return 1;
    }

    const next_height = height + 1;
    var score: usize = 0;
    score += calcScore(grid, x - 1, y, next_height);
    score += calcScore(grid, x + 1, y, next_height);
    score += calcScore(grid, x, y + 1, next_height);
    score += calcScore(grid, x, y - 1, next_height);

    return score;
}
