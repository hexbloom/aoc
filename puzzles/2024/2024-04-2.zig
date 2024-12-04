const std = @import("std");
const input = @embedFile("puzzle_input");

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

    for (1..grid.len - 1) |row| {
        for (1..grid[0].len - 1) |col| {
            if (findWord(grid, row, col)) {
                res += 1;
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn findWord(grid: [][]const u8, row: usize, col: usize) bool {
    if (grid[row][col] != 'A') {
        return false;
    }

    const tlbr = [_]u8{ grid[row - 1][col - 1], grid[row][col], grid[row + 1][col + 1] };
    const bltr = [_]u8{ grid[row + 1][col - 1], grid[row][col], grid[row - 1][col + 1] };

    const tlbr_valid = std.mem.eql(u8, tlbr[0..], "MAS") or std.mem.eql(u8, tlbr[0..], "SAM");
    const bltr_valid = std.mem.eql(u8, bltr[0..], "MAS") or std.mem.eql(u8, bltr[0..], "SAM");

    return tlbr_valid and bltr_valid;
}
