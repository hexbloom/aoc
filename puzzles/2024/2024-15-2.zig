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
        var row_list = std.ArrayList(u8).init(ally);
        for (line) |c| {
            switch (c) {
                '#' => try row_list.appendSlice("##"),
                'O' => try row_list.appendSlice("[]"),
                '.' => try row_list.appendSlice(".."),
                '@' => try row_list.appendSlice("@."),
                else => return error.InvalidInput,
            }
        }
        try grid_list.append(try row_list.toOwnedSlice());
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
        if (move(robot, dir, grid, true)) {
            robot += dir;
            var buf: [10]u8 = undefined;
            _ = try std.io.getStdIn().reader().readUntilDelimiterOrEof(buf[0..], '\n');
        }
    }

    var res: usize = 0;
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == '[') {
                res += 100 * y + x;
            }
        }
    }
    printGrid(grid);
    std.debug.print("{}", .{res});
}

fn move(cell: vec2, dir: vec2, grid: [][]u8, modify_grid: bool) bool {
    if (cell[0] < 0 or cell[0] >= grid[0].len or cell[1] < 0 or cell[1] >= grid.len) {
        return false;
    }

    const val = &grid[@intCast(cell[1])][@intCast(cell[0])];
    if (val.* == '.') {
        return true;
    }

    if (val.* == '@') {
        const next_cell = cell + dir;
        if (move(next_cell, dir, grid, modify_grid)) {
            if (modify_grid) {
                const next_val = &grid[@intCast(next_cell[1])][@intCast(next_cell[0])];
                next_val.* = val.*;
                val.* = '.';
            }
            return true;
        }
    }

    if (val.* == '[' or val.* == ']') {
        if (dir[1] == 0) {
            // horizontal box movement
            const next_cell = cell + dir;
            const next_cell_b = next_cell + dir;
            if (move(next_cell_b, dir, grid, modify_grid)) {
                if (modify_grid) {
                    const next_val = &grid[@intCast(next_cell[1])][@intCast(next_cell[0])];
                    const next_val_b = &grid[@intCast(next_cell_b[1])][@intCast(next_cell_b[0])];
                    next_val_b.* = next_val.*;
                    next_val.* = val.*;
                    val.* = '.';
                }
                return true;
            }
        } else {
            // vertical box movement
            const cell_b = if (val.* == '[') cell + vec2{ 1, 0 } else cell - vec2{ 1, 0 };
            const next_cell = cell + dir;
            const next_cell_b = cell_b + dir;
            const can_move = move(next_cell, dir, grid, false);
            const can_move_b = move(next_cell_b, dir, grid, false);
            if (can_move and can_move_b) {
                if (modify_grid) {
                    _ = move(next_cell, dir, grid, true);
                    _ = move(next_cell_b, dir, grid, true);
                    const val_b = &grid[@intCast(cell_b[1])][@intCast(cell_b[0])];
                    const next_val = &grid[@intCast(next_cell[1])][@intCast(next_cell[0])];
                    const next_val_b = &grid[@intCast(next_cell_b[1])][@intCast(next_cell_b[0])];
                    next_val.* = val.*;
                    next_val_b.* = val_b.*;
                    val.* = '.';
                    val_b.* = '.';
                }
                return true;
            }
        }
    }

    return false;
}

fn printGrid(grid: [][]u8) void {
    for (grid) |row| {
        for (row) |col| {
            std.debug.print("{c}", .{col});
        }
        std.debug.print("\n", .{});
    }
}
