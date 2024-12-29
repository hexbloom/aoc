const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const ConnectionSet = std.StringHashMap(void);
const ConnectionMap = std.StringHashMap(ConnectionSet);

const Triplet = struct {
    vals: [3][2]u8,
};
const TripletSet = std.AutoHashMap(Triplet, void);

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var map = ConnectionMap.init(ally);
    while (lines.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, '-');
        const a = split.next().?;
        const b = split.next().?;
        try addConnection(&map, a, b);
        try addConnection(&map, b, a);
    }

    var triplets = TripletSet.init(ally);
    var it = map.iterator();
    while (it.next()) |entry| {
        if (std.mem.startsWith(u8, entry.key_ptr.*, "t")) {
            const a = entry.key_ptr.*;
            const a_set = map.get(a).?;
            var a_it = a_set.iterator();
            while (a_it.next()) |a_entry| {
                const b = a_entry.key_ptr.*;
                const b_set = map.get(b).?;
                var b_it = b_set.iterator();
                while (b_it.next()) |b_entry| {
                    const c = b_entry.key_ptr.*;
                    const c_set = map.get(c).?;
                    var c_it = c_set.iterator();
                    while (c_it.next()) |c_entry| {
                        if (std.mem.eql(u8, a, c_entry.key_ptr.*)) {
                            try addTriplet(&triplets, a, b, c);
                        }
                    }
                }
            }
        }
    }

    std.debug.print("{}", .{triplets.count()});
}

fn addConnection(map: *ConnectionMap, src: []const u8, dst: []const u8) !void {
    const entry = try map.getOrPut(src);
    if (!entry.found_existing) {
        entry.value_ptr.* = ConnectionSet.init(ally);
    }
    try entry.value_ptr.put(dst, {});
}

fn addTriplet(set: *TripletSet, a: []const u8, b: []const u8, c: []const u8) !void {
    var triplet: Triplet = undefined;
    @memcpy(&triplet.vals[0], a);
    @memcpy(&triplet.vals[1], b);
    @memcpy(&triplet.vals[2], c);
    std.mem.sort([2]u8, triplet.vals[0..], {}, lessThanTriplet);

    try set.put(triplet, {});
}

fn lessThanTriplet(_: void, a: [2]u8, b: [2]u8) bool {
    for (a, b) |a_elem, b_elem| {
        if (a_elem != b_elem) {
            return a_elem < b_elem;
        }
    }

    return false;
}
