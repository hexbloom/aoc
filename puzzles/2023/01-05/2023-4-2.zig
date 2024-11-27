const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    var copies = try ctx.ally.alloc(i32, ctx.lines.len);
    for (copies) |*c| {
        c.* = 0;
    }

    for (ctx.lines, 0..) |line, line_idx| {
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

        copies[line_idx] += 1;
        for (0..@intCast(num_matches)) |match_idx| {
            const set_idx = line_idx + match_idx + 1;
            if (set_idx >= copies.len) {
                break;
            }
            copies[set_idx] += copies[line_idx];
        }
    }

    for (copies) |c| {
        res += c;
    }

    std.debug.print("{}", .{res});
}
