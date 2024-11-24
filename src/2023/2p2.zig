const std = @import("std");
const Context = @import("../Context.zig");
const String = @import("../String.zig");

pub fn solve(ctx: Context) !void {
    var sum: u32 = 0;
    for (try ctx.lines()) |line| {
        var color_count_it = std.mem.tokenizeAny(u8, line, ":,;");
        _ = color_count_it.next();

        var max_red: u32 = 0;
        var max_green: u32 = 0;
        var max_blue: u32 = 0;
        while (color_count_it.next()) |color_count| {
            var color_count_elem_it = std.mem.tokenizeScalar(u8, color_count, ' ');
            const count = color_count_elem_it.next() orelse return error.InvalidInput;
            const color = color_count_elem_it.next() orelse return error.InvalidInput;

            const parsed_count = try std.fmt.parseInt(u32, count, 10);
            if (std.mem.eql(u8, color, "red")) {
                max_red = @max(max_red, parsed_count);
            } else if (std.mem.eql(u8, color, "green")) {
                max_green = @max(max_green, parsed_count);
            } else if (std.mem.eql(u8, color, "blue")) {
                max_blue = @max(max_blue, parsed_count);
            } else {
                return error.InvalidInput;
            }
        }

        sum += max_red * max_green * max_blue;
    }

    std.debug.print("{}", .{sum});
}