const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Facing = enum { left, right, up, down };

const Side = struct {
    facing: Facing,
    start: vec2,
    end: vec2,
};

const Region = struct {
    id: u8,
    area: usize,
    sides: std.ArrayList(Side),
};

pub fn main() !void {
    var grid_list = std.ArrayList([]const u8).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
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

    var regions = std.ArrayList(Region).init(ally);
    for (grid, 0..) |row, y| {
        for (row, 0..) |col, x| {
            var region = Region{
                .id = col,
                .area = 0,
                .sides = std.ArrayList(Side).init(ally),
            };
            _ = try addRegion(grid, .{ @intCast(x), @intCast(y) }, &region, visited);
            if (region.area > 0) {
                try regions.append(region);
            }
        }
    }

    var res: usize = 0;
    for (regions.items) |region| {
        res += region.area * region.sides.items.len;
    }
    std.debug.print("{}", .{res});
}

fn addRegion(
    grid: [][]const u8,
    cell: vec2,
    region: *Region,
    visited: [][]bool,
) !bool {
    if (cell[0] < 0 or cell[0] >= grid[0].len or cell[1] < 0 or cell[1] >= grid.len) {
        return false;
    }

    if (grid[@intCast(cell[1])][@intCast(cell[0])] != region.id) {
        return false;
    }

    const visited_cell = &visited[@intCast(cell[1])][@intCast(cell[0])];
    if (visited_cell.*) {
        return true;
    }

    visited_cell.* = true;

    if (!try addRegion(grid, .{ cell[0] + 1, cell[1] }, region, visited)) {
        try addSide(&region.sides, cell, .right);
    }
    if (!try addRegion(grid, .{ cell[0], cell[1] + 1 }, region, visited)) {
        try addSide(&region.sides, cell, .down);
    }
    if (!try addRegion(grid, .{ cell[0] - 1, cell[1] }, region, visited)) {
        try addSide(&region.sides, cell, .left);
    }
    if (!try addRegion(grid, .{ cell[0], cell[1] - 1 }, region, visited)) {
        try addSide(&region.sides, cell, .up);
    }

    region.area += 1;

    return true;
}

fn addSide(sides: *std.ArrayList(Side), cell: vec2, facing: Facing) !void {
    const dir = switch (facing) {
        .left, .right => vec2{ 0, 1 },
        .up, .down => vec2{ 1, 0 },
    };

    for (sides.items) |*side| {
        if (side.facing != facing) {
            continue;
        }

        if (@reduce(.And, (side.start - dir) == cell)) {
            side.start = cell;
            for (sides.items, 0..) |merge_side, i| {
                if (merge_side.facing != facing) {
                    continue;
                }
                if (@reduce(.And, merge_side.end + dir == cell)) {
                    side.start = merge_side.start;
                    _ = sides.swapRemove(i);
                }
            }
            return;
        }
        if (@reduce(.And, (side.end + dir) == cell)) {
            side.end = cell;
            for (sides.items, 0..) |merge_side, i| {
                if (merge_side.facing != facing) {
                    continue;
                }
                if (@reduce(.And, merge_side.end - dir == cell)) {
                    side.end = merge_side.end;
                    _ = sides.swapRemove(i);
                }
            }
            return;
        }
    }

    try sides.append(.{
        .facing = facing,
        .start = cell,
        .end = cell,
    });
}
