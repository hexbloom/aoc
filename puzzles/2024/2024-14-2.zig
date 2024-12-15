const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Robot = struct {
    pos: vec2,
    vel: vec2,
};

pub fn main() !void {
    const grid_width = 101;
    const grid_height = 103;
    var robots_list = std.ArrayList(Robot).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var split = std.mem.tokenizeAny(u8, line, "p=, v");
        try robots_list.append(.{
            .pos = .{
                try std.fmt.parseInt(isize, split.next().?, 10),
                try std.fmt.parseInt(isize, split.next().?, 10),
            },

            .vel = vec2{
                try std.fmt.parseInt(isize, split.next().?, 10),
                try std.fmt.parseInt(isize, split.next().?, 10),
            },
        });
    }
    const robots = try robots_list.toOwnedSlice();

    var map = std.AutoHashMap(vec2, void).init(ally);
    var res: usize = 1;
    while (true) : (res += 1) {
        map.clearRetainingCapacity();
        for (robots) |*r| {
            r.pos += r.vel;
            r.pos = @rem(r.pos, vec2{ grid_width, grid_height });
            if (r.pos[0] < 0) {
                r.pos[0] += grid_width;
            }
            if (r.pos[1] < 0) {
                r.pos[1] += grid_height;
            }

            try map.put(r.pos, {});
        }

        var map_it = map.iterator();
        var num_double_diagonals: usize = 0;
        while (map_it.next()) |it| {
            const cell = it.key_ptr.*;
            if (isDoubleDiagonal(map, cell)) {
                num_double_diagonals += 1;
            }
        }

        if (num_double_diagonals >= 3) {
            printGrid(map, grid_width, grid_height);
            break;
        }
    }
    std.debug.print("{}", .{res});
}

fn isDoubleDiagonal(map: std.AutoHashMap(vec2, void), cell: vec2) bool {
    const len: usize = 5;
    const tr = isDoubleDiagonalDir(map, cell, .{ 1, -1 }, len);
    const br = isDoubleDiagonalDir(map, cell, .{ 1, 1 }, len);
    const bl = isDoubleDiagonalDir(map, cell, .{ -1, 1 }, len);
    const tl = isDoubleDiagonalDir(map, cell, .{ -1, -1 }, len);

    return (tr and br) or (br and bl) or (bl and tl) or (tl and tr);
}

fn isDoubleDiagonalDir(map: std.AutoHashMap(vec2, void), cell: vec2, dir: vec2, len: usize) bool {
    if (len == 0) {
        return true;
    }

    if (map.get(cell) == null) {
        return false;
    }

    return isDoubleDiagonalDir(map, cell + dir, dir, len - 1);
}

fn printGrid(map: std.AutoHashMap(vec2, void), width: usize, height: usize) void {
    for (0..height) |row| {
        for (0..width) |col| {
            const cell = vec2{ @intCast(col), @intCast(row) };
            if (map.get(cell) == null) {
                std.debug.print(".", .{});
            } else {
                std.debug.print("#", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}
