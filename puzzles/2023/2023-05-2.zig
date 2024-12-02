const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Range = struct { dst: usize, src: usize, len: usize };

pub fn main() !void {
    var res: usize = std.math.maxInt(usize);

    const Map = std.ArrayList(Range);
    var maps = std.ArrayList(Map).init(ally);
    var map: *Map = undefined;

    var lines = std.mem.splitScalar(u8, input, '\n');

    var seeds = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    _ = seeds.next();

    while (lines.next()) |line| {
        if (line.len == 0) {
            map = try maps.addOne();
            map.* = Map.init(ally);
            continue;
        }
        if (line.len > 0 and !std.ascii.isDigit(line[0])) {
            continue;
        }
        var vals = std.mem.tokenizeScalar(u8, line, ' ');
        try map.append(.{
            .dst = try std.fmt.parseInt(usize, vals.next().?, 10),
            .src = try std.fmt.parseInt(usize, vals.next().?, 10),
            .len = try std.fmt.parseInt(usize, vals.next().?, 10),
        });
    }

    while (true) {
        const seed_start = try std.fmt.parseInt(usize, seeds.next() orelse break, 10);
        const seed_range = try std.fmt.parseInt(usize, seeds.next() orelse break, 10);

        for (0..seed_range) |s| {
            var map_val = seed_start + s;
            for (maps.items) |cur_map| {
                for (cur_map.items) |range| {
                    if (map_val >= range.src and map_val < range.src + range.len) {
                        map_val = range.dst + (map_val - range.src);
                        break;
                    }
                }
            }
            res = @min(map_val, res);
        }
    }

    std.debug.print("{}", .{res});
}
