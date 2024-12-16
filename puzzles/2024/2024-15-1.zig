const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var grid_list = std.ArrayList([]u8).init(ally);
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        try grid_list.append(try ally.dupe(u8, line));
    }
    const grid = try grid_list.toOwnedSlice();

    var command_list = std.ArrayList(vec2).init(ally);
    while (lines.next()) |line| {
        for (line) |c| {
            try command_list.append(switch (c) {
                '>' => .{ 1, 0 },
                '<' => .{ -1, 0 },
                '^' => .{ 0, -1 },
                'v' => .{ 0, 1 },
                else => return error.InvalidCommand,
            });
        }
    }
    const commands = try command_list.toOwnedSlice();

    var robot = find_robot: {
        for (grid, 0..) |row, y| {
            for (row, 0..) |col, x| {
                if (col == '@') {
                    break :find_robot vec2{ @intCast(x), @intCast(y) };
                }
            }
        }
        return error.NoRobot;
    };

    for (commands) |dir| {
        if (move(robot, dir, grid)) {
            robot += dir;
        }
    }

    var res: usize = 0;
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            std.debug.print("{c}", .{col});
            if (col == 'O') {
                res += 100 * y + x;
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("{}", .{res});
}

fn move(cell: vec2, dir: vec2, grid: [][]u8) bool {
    if (cell[0] < 0 or cell[0] >= grid[0].len or cell[1] < 0 or cell[1] >= grid.len) {
        return false;
    }

    const val = &grid[@intCast(cell[1])][@intCast(cell[0])];
    if (val.* == '.') {
        return true;
    }

    if (val.* == '@' or val.* == 'O') {
        const next_cell = cell + dir;
        if (move(next_cell, dir, grid)) {
            const next_val = &grid[@intCast(next_cell[1])][@intCast(next_cell[0])];
            next_val.* = val.*;
            val.* = '.';
            return true;
        }
    }

    return false;
}
