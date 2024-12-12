const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Region = struct {
    id: u8,
    area: usize = 0,
    perimeter: usize = 0,
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
            var region = Region{ .id = col };
            _ = try addRegion(grid, .{ @intCast(x), @intCast(y) }, &region, visited);
            if (region.area > 0) {
                try regions.append(region);
            }
        }
    }

    var res: usize = 0;
    for (regions.items) |region| {
        res += region.area * region.perimeter;
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

    var perimeter: usize = 0;
    perimeter += if (try addRegion(grid, .{ cell[0] + 1, cell[1] }, region, visited)) 0 else 1;
    perimeter += if (try addRegion(grid, .{ cell[0] - 1, cell[1] }, region, visited)) 0 else 1;
    perimeter += if (try addRegion(grid, .{ cell[0], cell[1] + 1 }, region, visited)) 0 else 1;
    perimeter += if (try addRegion(grid, .{ cell[0], cell[1] - 1 }, region, visited)) 0 else 1;

    region.*.area += 1;
    region.*.perimeter += perimeter;

    return true;
}
