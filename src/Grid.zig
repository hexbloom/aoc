const std = @import("std");
const Context = @import("Context.zig");

pub const Cell = struct {
    x: usize,
    y: usize,
};

pub const adj_corners = [_]i32{ -1, -1, 1, -1, -1, 1, 1, 1 };
pub const adj_sides = [_]i32{ 0, -1, -1, 0, 1, 0, 0, 1 };
pub const adj_all = adj_corners ++ adj_sides;

pub fn getAdjacentCells(ctx: Context, x: usize, y: usize, offsets: []const i32) ![]Cell {
    var cells = std.ArrayList(Cell).init(ctx.ally);

    for (0..offsets.len / 2) |i| {
        const x_pos = @as(i32, @intCast(x)) + offsets[i * 2];
        const y_pos = @as(i32, @intCast(y)) + offsets[i * 2 + 1];
        if (x_pos < 0 or x_pos >= ctx.lines[0].len or y_pos < 0 or y_pos >= ctx.lines.len) {
            continue;
        }

        try cells.append(Cell{ .x = @intCast(x_pos), .y = @intCast(y_pos) });
    }

    return try cells.toOwnedSlice();
}
