const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: i32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var grid_list = std.ArrayList([]const u8).init(ally);
    while (lines.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    for (grid, 0..) |row, y| {
        var it = std.mem.tokenizeAny(u8, row, "!@#$%^&*()-=_+/.");
        while (it.next()) |num| {
            var is_valid = false;
            const start = @intFromPtr(num.ptr) - @intFromPtr(row.ptr);
            for (0..num.len) |i| {
                const x = start + i;
                for (try getAdjacentCells(grid, x, y)) |char| {
                    if (!std.ascii.isDigit(char) and char != '.') {
                        is_valid = true;
                    }
                }
            }
            if (is_valid) {
                res += try std.fmt.parseInt(i32, num, 10);
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn getAdjacentCells(grid: [][]const u8, x: usize, y: usize) ![]u8 {
    var cells = std.ArrayList(u8).init(ally);
    for (0..3) |ymod| {
        for (0..3) |xmod| {
            if (ymod == 1 and xmod == 1) {
                continue;
            }

            const xoff: isize = @as(isize, @intCast(x + xmod)) - 1;
            const yoff: isize = @as(isize, @intCast(y + ymod)) - 1;

            if (xoff >= 0 and yoff >= 0 and xoff < grid[0].len and yoff < grid.len) {
                try cells.append(grid[@intCast(yoff)][@intCast(xoff)]);
            }
        }
    }
    return try cells.toOwnedSlice();
}
