const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    const grid_width = 101;
    const grid_height = 103;
    const vel_iters = 100;
    var quadrants: [4]usize = .{ 0, 0, 0, 0 };
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var split = std.mem.tokenizeAny(u8, line, "p=, v");

        const start = vec2{
            try std.fmt.parseInt(isize, split.next().?, 10),
            try std.fmt.parseInt(isize, split.next().?, 10),
        };

        const vel = vec2{
            try std.fmt.parseInt(isize, split.next().?, 10),
            try std.fmt.parseInt(isize, split.next().?, 10),
        };

        var end = start + vel * @as(vec2, @splat(vel_iters));
        end = @rem(end, vec2{ grid_width, grid_height });
        if (end[0] < 0) {
            end[0] += grid_width;
        }
        if (end[1] < 0) {
            end[1] += grid_height;
        }

        const mid_x = grid_width / 2;
        const mid_y = grid_height / 2;
        if (end[0] < mid_x and end[1] < mid_y) {
            quadrants[0] += 1;
        } else if (end[0] > mid_x and end[1] < mid_y) {
            quadrants[1] += 1;
        } else if (end[0] < mid_x and end[1] > mid_y) {
            quadrants[2] += 1;
        } else if (end[0] > mid_x and end[1] > mid_y) {
            quadrants[3] += 1;
        }
    }

    var res: usize = 1;
    for (quadrants) |q| {
        res *= q;
    }
    std.debug.print("{}", .{res});
}
