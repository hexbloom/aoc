const std = @import("std");

pub const Cell = struct {
    x: usize,
    y: usize,
};

pub const adj_corners = [_]i32{ -1, -1, 1, -1, -1, 1, 1, 1 };
pub const adj_sides = [_]i32{ 0, -1, -1, 0, 1, 0, 0, 1 };
pub const adj_all = adj_corners ++ adj_sides;

pub fn getAdjCells(
    ally: std.mem.Allocator,
    grid: [][]const u8,
    x: usize,
    y: usize,
    offsets: []const i32,
) ![]Cell {
    var cells = std.ArrayList(Cell).init(ally);

    for (0..offsets.len / 2) |i| {
        const x_pos = @as(i32, @intCast(x)) + offsets[i * 2];
        const y_pos = @as(i32, @intCast(y)) + offsets[i * 2 + 1];
        if (isValidPos(grid, x_pos, y_pos)) {
            try cells.append(Cell{ .x = @intCast(x_pos), .y = @intCast(y_pos) });
        }
    }

    return try cells.toOwnedSlice();
}

pub fn isValidPos(grid: [][]const u8, x: i32, y: i32) bool {
    return x >= 0 and x < grid[0].len and y >= 0 and y < grid.len;
}

pub fn distance(a: Cell, b: Cell) i32 {
    const x_dist = @as(i32, @intCast(b.x)) - @as(i32, @intCast(a.x));
    const y_dist = @as(i32, @intCast(b.y)) - @as(i32, @intCast(a.y));
    return @abs(x_dist) + @abs(y_dist);
}

pub const Walker = struct {
    grid: [][]const u8,
    x: i32,
    y: i32,
    dir_x: i32,
    dir_y: i32,

    pub fn init(grid: [][]const u8, x: i32, y: i32) Walker {
        return Walker{
            .grid = grid,
            .x = x,
            .y = y,
            .dir_x = 0,
            .dir_y = 0,
        };
    }

    pub fn initDir(grid: [][]const u8, x: i32, y: i32, dir_x: i32, dir_y: i32) Walker {
        return Walker{
            .grid = grid,
            .x = x,
            .y = y,
            .dir_x = dir_x,
            .dir_y = dir_y,
        };
    }

    pub fn move(it: *Walker, dir_x: i32, dir_y: i32) ?u8 {
        it.x += dir_x;
        it.y += dir_y;
        return it.getValue();
    }

    pub fn moveForward(it: *Walker) ?u8 {
        it.x += it.dir_x;
        it.y += it.dir_y;
        return it.getValue();
    }

    pub fn getValue(it: Walker) ?u8 {
        if (isValidPos(it.grid, it.x, it.y)) {
            return it.grid[it.y][it.x];
        } else {
            return null;
        }
    }

    pub fn getCell(it: Walker) ?Cell {
        if (isValidPos(it.grid, it.x, it.y)) {
            return Cell{
                .x = @intCast(it.x),
                .y = @intCast(it.y),
            };
        } else {
            return null;
        }
    }

    pub fn rotateR(it: *Walker) void {
        // 1, 0
        // 0, 1
        // -1, 0
        // 0, -1
        const tmp = it.dir_x;
        it.dir_x = -it.dir_y;
        it.dir_y = tmp;
    }

    pub fn rotateL(it: *Walker) void {
        // 1, 0
        // 0, -1
        // -1, 0
        // 0, 1
        const tmp = it.dir_x;
        it.dir_x = it.dir_y;
        it.dir_y = -tmp;
    }
};
