const std = @import("std");
const utils = @import("utils");
const Context = utils.Context;

pub fn solve(ctx: Context) !void {
    var res: i64 = 0;

    var left = std.ArrayList(i64).init(ctx.ally);
    var right = std.ArrayList(i64).init(ctx.ally);
    for (ctx.lines) |line| {
        const split = try utils.split(ctx.ally, line, " ");
        try left.append(try std.fmt.parseInt(i64, split[0], 10));
        try right.append(try std.fmt.parseInt(i64, split[1], 10));
    }

    std.sort.pdq(i64, left.items, {}, std.sort.asc(i64));
    std.sort.pdq(i64, right.items, {}, std.sort.asc(i64));

    for (left.items, right.items) |l, r| {
        res += @intCast(@abs(r - l));
    }

    std.debug.print("{}", .{res});
}
