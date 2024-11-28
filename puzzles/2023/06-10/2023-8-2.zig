const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

const MapValue = struct {
    left: []const u8,
    right: []const u8,
};
const MapGhost = struct {
    loc: []const u8,
    steps: i64,
    found_end: bool,
};

pub fn solve(ctx: Context) !void {
    var map = std.StringHashMap(MapValue).init(ctx.ally);
    for (ctx.lines[2..]) |line| {
        const split = try utils.split(ctx.ally, line, " =(,)");
        try map.put(split[0], .{ .left = split[1], .right = split[2] });
    }

    var ghosts = std.ArrayList(MapGhost).init(ctx.ally);
    var map_it = map.keyIterator();
    while (map_it.next()) |key| {
        if (std.mem.endsWith(u8, key.*, "A")) {
            try ghosts.append(.{
                .loc = key.*,
                .steps = 0,
                .found_end = false,
            });
        }
    }

    var i: usize = 0;
    while (true) : (i = (i + 1) % ctx.lines[0].len) {
        var all_at_end = true;
        for (ghosts.items) |*ghost| {
            if (ghost.found_end) {
                continue;
            }
            all_at_end = false;

            ghost.steps += 1;
            const loc_val = map.get(ghost.loc).?;
            if (ctx.lines[0][i] == 'L') {
                ghost.loc = loc_val.left;
            } else {
                ghost.loc = loc_val.right;
            }
            if (std.mem.endsWith(u8, ghost.loc, "Z")) {
                ghost.found_end = true;
            }
        }

        if (all_at_end) {
            break;
        }
    }

    var res: usize = 1;
    for (ghosts.items) |ghost| {
        res = lcm(res, @intCast(ghost.steps));
    }

    std.debug.print("{}", .{res});
}

fn lcm(a: usize, b: usize) usize {
    return (a * b) / std.math.gcd(a, b);
}
