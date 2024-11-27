const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    for (ctx.lines) |line| {
        const split = try utils.split(ctx.ally, line, ":|");
        const vals = try utils.split(ctx.ally, split[1], " ");
        const checks = try utils.split(ctx.ally, split[2], " ");

        var num_matches: i32 = 0;
        for (checks) |c| {
            for (vals) |v| {
                if (std.mem.eql(u8, c, v)) {
                    num_matches += 1;
                }
            }
        }

        if (num_matches > 0) {
            res += std.math.pow(i32, 2, num_matches - 1);
        }
    }

    std.debug.print("{}", .{res});
}
