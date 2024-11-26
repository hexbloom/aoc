const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    var num_copies = try ctx.ally.alloc(i32, ctx.lines.len);
    for (num_copies) |*c| {
        c.* = 0;
    }
    for (ctx.lines, 0..) |line, line_idx| {
        var split_it = std.mem.tokenizeAny(u8, line, ":|");
        _ = split_it.next();
        const vals = split_it.next().?;
        const check = split_it.next().?;

        var val_arr = std.ArrayList([]const u8).init(ctx.ally);
        var val_it = std.mem.tokenizeAny(u8, vals, " ");
        while (val_it.next()) |val| {
            try val_arr.append(val);
        }

        var check_arr = std.ArrayList([]const u8).init(ctx.ally);
        var check_it = std.mem.tokenizeAny(u8, check, " ");
        while (check_it.next()) |chk| {
            try check_arr.append(chk);
        }

        var num_matches: usize = 0;
        for (check_arr.items) |i| {
            for (val_arr.items) |v| {
                if (std.mem.eql(u8, i, v)) {
                    num_matches += 1;
                }
            }
        }

        num_copies[line_idx] += 1;
        for (0..num_matches) |match_idx| {
            const set_idx = line_idx + match_idx + 1;
            if (set_idx >= ctx.lines.len) {
                break;
            }
            num_copies[set_idx] += num_copies[line_idx];
        }
    }

    for (num_copies) |ncpy| {
        res += ncpy;
    }

    std.debug.print("{}", .{res});
}
