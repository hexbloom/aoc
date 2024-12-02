const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Cell = struct { x: usize, y: usize };

pub fn main() !void {
    var res: i32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var grid_list = std.ArrayList([]const u8).init(ally);
    while (lines.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    var map = std.AutoHashMap(Cell, std.ArrayList(i32)).init(ally);
    for (grid, 0..) |row, y| {
        var it = std.mem.tokenizeAny(u8, row, "!@#$%^&*()-=_+/.");
        while (it.next()) |num| {
            var gear_cell: ?Cell = null;
            const start = @intFromPtr(num.ptr) - @intFromPtr(row.ptr);
            for (0..num.len) |i| {
                const x = start + i;
                for (try getAdjacentCells(grid, x, y)) |cell| {
                    const char = grid[cell.y][cell.x];
                    if (char == '*') {
                        gear_cell = cell;
                    }
                }
            }
            if (gear_cell) |cell| {
                const kvp = try map.getOrPutValue(cell, std.ArrayList(i32).init(ally));
                try kvp.value_ptr.append(try std.fmt.parseInt(i32, num, 10));
            }
        }
    }

    var it = map.valueIterator();
    while (it.next()) |val| {
        if (val.items.len == 2) {
            res += val.items[0] * val.items[1];
        }
    }

    std.debug.print("{}", .{res});
}

fn getAdjacentCells(grid: [][]const u8, x: usize, y: usize) ![]Cell {
    var cells = std.ArrayList(Cell).init(ally);
    for (0..3) |ymod| {
        for (0..3) |xmod| {
            if (ymod == 1 and xmod == 1) {
                continue;
            }

            const xoff: isize = @as(isize, @intCast(x + xmod)) - 1;
            const yoff: isize = @as(isize, @intCast(y + ymod)) - 1;

            if (xoff >= 0 and yoff >= 0 and xoff < grid[0].len and yoff < grid.len) {
                try cells.append(.{ .x = @intCast(xoff), .y = @intCast(yoff) });
            }
        }
    }
    return try cells.toOwnedSlice();
}
