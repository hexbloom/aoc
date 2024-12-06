const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, i32);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var grid_list = std.ArrayList([]u8).init(ally);
    while (lines.next()) |line| {
        try grid_list.append(try ally.dupe(u8, line));
    }
    const grid = try grid_list.toOwnedSlice();

    const visited = try ally.alloc([]bool, grid.len);
    for (visited) |*row| {
        row.* = try ally.alloc(bool, grid[0].len);
        for (row.*) |*col| {
            col.* = false;
        }
    }

    const start_dir = vec2{ 0, -1 };
    const start_cell = blk: {
        for (grid, 0..) |row, y| {
            for (row, 0..) |col, x| {
                if (col == '^') {
                    break :blk vec2{ @intCast(x), @intCast(y) };
                }
            }
        }
        return error.GuardNotFound;
    };

    _ = try patrolLoop(start_cell, start_dir, grid, visited);

    var res: u32 = 0;
    for (visited, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == true and grid[y][x] != '^') {
                grid[y][x] = '#';
                if (try patrolLoop(start_cell, start_dir, grid, null)) {
                    res += 1;
                }
                grid[y][x] = '.';
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn patrolLoop(start_cell: vec2, start_dir: @Vector(2, i32), grid: [][]const u8, store_visited: ?[][]bool) !bool {
    var history = std.AutoHashMap(vec2, @Vector(2, i32)).init(ally);

    var guard = start_cell;
    var dir = start_dir;
    if (store_visited) |visited| {
        visited[@intCast(guard[1])][@intCast(guard[0])] = true;
    }
    while (true) {
        const next = guard + dir;
        if (next[0] < 0 or next[0] >= grid[0].len or next[1] < 0 or next[1] >= grid.len) {
            return false;
        }

        if (grid[@intCast(next[1])][@intCast(next[0])] == '#') {
            if (history.get(guard)) |history_dir| {
                if (@reduce(.And, dir == history_dir)) {
                    return true;
                }
            } else {
                try history.put(guard, dir);
            }

            // rotate
            const tmp = dir[0];
            dir[0] = -dir[1];
            dir[1] = tmp;
        } else {
            guard = next;
            if (store_visited) |visited| {
                visited[@intCast(guard[1])][@intCast(guard[0])] = true;
            }
        }
    }
}
