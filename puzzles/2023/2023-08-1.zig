const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const MapValue = struct {
    left: []const u8,
    right: []const u8,
};
pub fn main() !void {
    var res: usize = 0;

    var map = std.StringHashMap(MapValue).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const instructions = lines.next().?;
    while (lines.next()) |line| {
        var split = std.mem.tokenizeAny(u8, line, " =(,)");
        try map.put(split.next().?, .{ .left = split.next().?, .right = split.next().? });
    }

    var i: usize = 0;
    var loc: []const u8 = "AAA";
    while (true) : (i = (i + 1) % instructions.len) {
        res += 1;
        const loc_val = map.get(loc).?;
        if (instructions[i] == 'L') {
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
