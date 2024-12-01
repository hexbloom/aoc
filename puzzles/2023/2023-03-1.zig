const puzzle = @import("puzzle");
const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    const lines = try utils.readLines(ally, puzzle.input_path);

    var res: i32 = 0;

    for (lines, 0..) |line, y| {
        var it = std.mem.tokenizeAny(u8, line, "!@#$%^&*()-=_+/.");
        while (it.next()) |num| {
            var is_valid = false;
            const start = @intFromPtr(num.ptr) - @intFromPtr(line.ptr);
            for (0..num.len) |i| {
                const x = start + i;
                for (try grid.getAdjCells(ally, lines, x, y, &grid.adj_all)) |cell| {
                    const char = lines[cell.y][cell.x];
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
