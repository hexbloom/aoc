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

    const visited = try ally.alloc([]bool, grid.len);
    for (visited) |*row| {
        row.* = try ally.alloc(bool, grid[0].len);
        for (row.*) |*col| {
            col.* = false;
        }
    }

    var dir = vec2{ 0, -1 };
    var guard = blk: {
        for (grid, 0..) |row, y| {
            for (row, 0..) |col, x| {
                if (col == '^') {
                    break :blk vec2{ @intCast(x), @intCast(y) };
                }
            }
        }
        return error.GuardNotFound;
    };

    var res: u32 = 0;
    setVisited(visited, guard, &res);
    while (true) {
        const next = guard + dir;
        if (next[0] < 0 or next[0] >= grid[0].len or next[1] < 0 or next[1] >= grid.len) {
            break;
        }

        if (grid[@intCast(next[1])][@intCast(next[0])] == '#') {
            // rotate
            const tmp = dir[0];
            dir[0] = -dir[1];
            dir[1] = tmp;
        } else {
            guard = next;
            setVisited(visited, guard, &res);
        }
    }

    std.debug.print("{}", .{res});
}

fn setVisited(visited: [][]bool, cell: vec2, visit_count: *u32) void {
    const visited_cell = &visited[@intCast(cell[1])][@intCast(cell[0])];
    if (visited_cell.* == false) {
        visited_cell.* = true;
        visit_count.* += 1;
    }
}
