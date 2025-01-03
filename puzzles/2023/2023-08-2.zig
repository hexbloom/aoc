const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const MapValue = struct {
    left: []const u8,
    right: []const u8,
};
const MapGhost = struct {
    loc: []const u8,
    steps: i64,
    found_end: bool,
};

pub fn main() !void {
    var map = std.StringHashMap(MapValue).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const instructions = lines.next().?;
    while (lines.next()) |line| {
        var split = std.mem.tokenizeAny(u8, line, " =(,)");
        try map.put(split.next().?, .{ .left = split.next().?, .right = split.next().? });
    }

    var ghosts = std.ArrayList(MapGhost).init(ally);
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
    while (true) : (i = (i + 1) % instructions.len) {
        var all_at_end = true;
        for (ghosts.items) |*ghost| {
            if (ghost.found_end) {
                continue;
            }
            all_at_end = false;

            ghost.steps += 1;
            const loc_val = map.get(ghost.loc).?;
            if (instructions[i] == 'L') {
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
