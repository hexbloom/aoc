const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, isize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    const num_pad = &[_][]const u8{ "789", "456", "123", "X0A" };
    const key_pad = &[_][]const u8{ "X^A", "<v>" };

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var res: usize = 0;
    while (lines.next()) |line| {
        var presses = line;
        for (0..3) |i| {
            const pad = if (i == 0) num_pad else key_pad;
            presses = try getKeyPresses(pad, presses);
        }
        const val = try std.fmt.parseInt(usize, line[0 .. line.len - 1], 10);
        res += presses.len * val;
    }
    std.debug.print("{}", .{res});
}

fn getKeyPresses(pad: []const []const u8, keys: []const u8) ![]const u8 {
    var key_presses = std.ArrayList(u8).init(ally);
    var cur = try getKeyCell(pad, 'A');
    for (keys) |key| {
        const dst = try getKeyCell(pad, key);
        const x_dir: isize = if (dst[0] > cur[0]) 1 else -1;
        var x_first = true;
        var x_test = cur[0];
        while (x_test != dst[0] + x_dir) : (x_test += x_dir) {
            if (!isCellValid(pad, .{ x_test, cur[1] })) {
                x_first = false;
                break;
            }
        }
        const delta = dst - cur;
        const x_char: u8 = if (delta[0] > 0) '>' else '<';
        const y_char: u8 = if (delta[1] > 0) 'v' else '^';
        if (x_first) {
            for (0..@abs(delta[0])) |_| {
                try key_presses.append(x_char);
            }
            for (0..@abs(delta[1])) |_| {
                try key_presses.append(y_char);
            }
        } else {
            for (0..@abs(delta[1])) |_| {
                try key_presses.append(y_char);
            }
            for (0..@abs(delta[0])) |_| {
                try key_presses.append(x_char);
            }
        }
        try key_presses.append('A');
        cur = dst;
    }

    return try key_presses.toOwnedSlice();
}

fn isCellValid(pad: []const []const u8, cell: vec2) bool {
    if (cell[0] < 0 or cell[0] >= pad[0].len or cell[1] < 0 or cell[1] >= pad.len) {
        return false;
    }

    if (pad[@intCast(cell[1])][@intCast(cell[0])] == 'X') {
        return false;
    }

    return true;
}

fn getKeyCell(pad: []const []const u8, key: u8) !vec2 {
    for (pad, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == key) {
                return .{ @intCast(x), @intCast(y) };
            }
        }
    }
    return error.NoCellFoundForKey;
}
