const std = @import("std");
const utils = @import("utils");
const Context = utils.Context;

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    for (ctx.lines) |line| {
        var str = std.ArrayList(u8).init(ctx.ally);
        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                if (str.items.len < 2) {
                    try str.append(char);
                } else {
                    str.items[1] = char;
                }
            }
        }

        if (str.items.len == 1) {
            try str.append(str.items[0]);
        }

        res += try std.fmt.parseInt(i32, str.items, 10);
    }

    std.debug.print("{}", .{res});
}
