const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, i32);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var grid_list = std.ArrayList([]const u8).init(ally);
    while (lines.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    const antinodes = try ally.alloc([]bool, grid.len);
    for (antinodes) |*row| {
        row.* = try ally.alloc(bool, grid[0].len);
        for (row.*) |*col| {
            col.* = false;
        }
    }

    var antenna_map = std.AutoHashMap(u8, std.ArrayList(vec2)).init(ally);
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == '.') {
                continue;
            }
            var entry = try antenna_map.getOrPut(col);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.ArrayList(vec2).init(ally);
            }
            try entry.value_ptr.append(.{ @intCast(x), @intCast(y) });
        }
    }

    var res: usize = 0;
    var antenna_it = antenna_map.iterator();
    while (antenna_it.next()) |antennas| {
        for (antennas.value_ptr.items) |a| {
            for (antennas.value_ptr.items) |b| {
                if (@reduce(.And, a == b)) {
                    continue;
                }

                const dir = b - a;
                var cell = a;
                while (true) {
                    const antinode = &antinodes[@intCast(cell[1])][@intCast(cell[0])];
                    if (antinode.* == false) {
                        antinode.* = true;
                        res += 1;
                    }

                    cell += dir;

                    if (cell[0] < 0 or cell[0] >= antinodes[0].len or
                        cell[1] < 0 or cell[1] >= antinodes.len)
                    {
                        break;
                    }
                }
            }
        }
    }

    std.debug.print("{}", .{res});
}
