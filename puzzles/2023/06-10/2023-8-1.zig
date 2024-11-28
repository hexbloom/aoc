const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

const MapValue = struct {
    left: []const u8,
    right: []const u8,
};
pub fn solve(ctx: Context) !void {
    var res: usize = 0;

    var map = std.StringHashMap(MapValue).init(ctx.ally);
    for (ctx.lines[2..]) |line| {
        const split = try utils.split(ctx.ally, line, " =(,)");
        try map.put(split[0], .{ .left = split[1], .right = split[2] });
    }

    var i: usize = 0;
    var loc: []const u8 = "AAA";
    while (true) : (i = (i + 1) % ctx.lines[0].len) {
        res += 1;
        const loc_val = map.get(loc).?;
        if (ctx.lines[0][i] == 'L') {
            loc = loc_val.left;
        } else {
            loc = loc_val.right;
        }
        if (std.mem.eql(u8, loc, "ZZZ")) {
            break;
        }
    }

    std.debug.print("{}", .{res});
}
