const puzzle = @import("puzzle");
const std = @import("std");
const utils = @import("utils");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const MapValue = struct {
    left: []const u8,
    right: []const u8,
};
pub fn main() !void {
    const lines = try utils.readLines(ally, puzzle.input_path);

    var res: usize = 0;

    var map = std.StringHashMap(MapValue).init(ally);
    for (lines[2..]) |line| {
        const split = try utils.split(ally, line, " =(,)");
        try map.put(split[0], .{ .left = split[1], .right = split[2] });
    }

    var i: usize = 0;
    var loc: []const u8 = "AAA";
    while (true) : (i = (i + 1) % lines[0].len) {
        res += 1;
        const loc_val = map.get(loc).?;
        if (lines[0][i] == 'L') {
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
