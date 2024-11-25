const std = @import("std");
const Context = @import("../Context.zig");
const String = std.ArrayList(u8);

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    for (ctx.lines, 0..) |line, y| {
        var it = std.mem.tokenizeAny(u8, line, "!@#$%^&*()-=_+/.");
        while (it.next()) |num| {
            var is_valid = false;
            const start = @intFromPtr(num.ptr) - @intFromPtr(line.ptr);
            for (0..num.len) |i| {
                const x = start + i;
                for (try ctx.getAdjacentCells(x, y)) |cell| {
                    const char = ctx.lines[cell.y][cell.x];
                    if (!std.ascii.isDigit(char) and char != '.') {
                        is_valid = true;
                    }
                }
            }
            if (is_valid) {
                res += try std.fmt.parseInt(i32, num, 10);
            }
        }
    }

    std.debug.print("{}", .{res});
}
