const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, i32);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: usize = 0;

    var grid_list = std.ArrayList([]const u8).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    const dirs = [_]vec2{
        .{ 1, 0 },
        .{ 1, 1 },
        .{ 0, 1 },
        .{ -1, 1 },
        .{ -1, 0 },
        .{ -1, -1 },
        .{ 0, -1 },
        .{ 1, -1 },
    };
    for (0..grid.len) |row| {
        for (0..grid[0].len) |col| {
            for (dirs) |dir| {
                if (findWord(grid, row, col, dir)) {
                    res += 1;
                }
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn findWord(grid: [][]const u8, row: usize, col: usize, dir: vec2) bool {
    var word: [4]u8 = undefined;
    for (0..word.len) |i| {
        const offset = dir * @as(vec2, @splat(@intCast(i)));
        const cell = vec2{ @intCast(col), @intCast(row) } + offset;
        if (cell[0] < 0 or cell[0] >= grid[0].len or
            cell[1] < 0 or cell[1] >= grid.len)
        {
            return false;
        }
        word[i] = grid[@intCast(cell[1])][@intCast(cell[0])];
    }
    return std.mem.eql(u8, word[0..], "XMAS");
}
