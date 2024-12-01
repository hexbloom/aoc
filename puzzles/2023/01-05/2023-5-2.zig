const puzzle = @import("puzzle");
const std = @import("std");
const utils = @import("utils");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Range = struct { dst: usize, src: usize, len: usize };

pub fn main() !void {
    const lines = try utils.readLines(ally, puzzle.input_path);

    var res: usize = std.math.maxInt(usize);

    const Map = std.ArrayList(Range);
    var maps = std.ArrayList(Map).init(ally);
    var map: *Map = undefined;
    for (lines[1..]) |line| {
        if (line.len == 0) {
            map = try maps.addOne();
            map.* = Map.init(ally);
            continue;
        }
        if (line.len > 0 and !std.ascii.isDigit(line[0])) {
            continue;
        }
        const vals = try utils.split(ally, line, " ");
        try map.append(.{
            .dst = try std.fmt.parseInt(usize, vals[0], 10),
            .src = try std.fmt.parseInt(usize, vals[1], 10),
            .len = try std.fmt.parseInt(usize, vals[2], 10),
        });
    }

    const seeds = try utils.split(ally, lines[0], " ");
    var i: usize = 1;
    while (i < seeds.len) : (i += 2) {
        const seed_start = try std.fmt.parseInt(usize, seeds[i], 10);
        const seed_range = try std.fmt.parseInt(usize, seeds[i + 1], 10);

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
