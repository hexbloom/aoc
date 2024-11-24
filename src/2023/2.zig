const std = @import("std");
const Context = @import("../Context.zig");

pub fn solve(ctx: Context) !void {
    var sum: i32 = 0;
    var game_id: i32 = 1;
    for (try ctx.lines()) |line| {
        var game_is_valid = true;

        var color_count_it = std.mem.tokenizeAny(u8, line, ":,;");
        _ = color_count_it.next();

        while (color_count_it.next()) |color_count| {
            var color_count_elem_it = std.mem.tokenizeScalar(u8, color_count, ' ');
            const count = color_count_elem_it.next() orelse return error.InvalidInput;
            const color = color_count_elem_it.next() orelse return error.InvalidInput;

            const max_count: u32 = blk: {
                if (std.mem.eql(u8, color, "red")) {
                    break :blk 12;
                } else if (std.mem.eql(u8, color, "green")) {
                    break :blk 13;
                } else if (std.mem.eql(u8, color, "blue")) {
                    break :blk 14;
                } else {
                    return error.InvalidInput;
                }
            };

            if (try std.fmt.parseInt(u32, count, 10) > max_count) {
                game_is_valid = false;
                break;
            }
        }

        if (game_is_valid) {
            sum += game_id;
        }

        game_id += 1;
    }

    std.debug.print("{}", .{sum});
}
