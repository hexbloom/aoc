const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const ConnectionSet = std.StringArrayHashMap(void);
const ConnectionMap = std.StringHashMap(ConnectionSet);

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

    var largest_set: ?ConnectionSet = null;
    var it = map.iterator();
    while (it.next()) |entry| {
        var set = ConnectionSet.init(ally);
        try gatherConnections(map, &set, entry.key_ptr.*);
        if (largest_set == null or set.count() > largest_set.?.count()) {
            largest_set = set;
        }
    }

    const largest_set_sorted = largest_set.?.keys();
    std.mem.sort([]const u8, largest_set_sorted, {}, lessThanStr);
    for (largest_set_sorted) |src| {
        std.debug.print("{s},", .{src});
    }
}

fn lessThanStr(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
}

fn gatherConnections(map: ConnectionMap, set: *ConnectionSet, src: []const u8) !void {
    if (set.get(src) != null) {
        return;
    }

    var src_connected = true;
    var set_it = set.iterator();
    while (set_it.next()) |set_entry| {
        src_connected = false;
        const connected_set = map.get(set_entry.key_ptr.*).?;
        var connected_it = connected_set.iterator();
        while (connected_it.next()) |connected_entry| {
            if (std.mem.eql(u8, src, connected_entry.key_ptr.*)) {
                src_connected = true;
                break;
            }
        }
        if (!src_connected) {
            break;
        }
    }

    if (src_connected) {
        try set.put(src, {});
        var src_set = map.get(src).?;
        var src_it = src_set.iterator();
        while (src_it.next()) |src_entry| {
            try gatherConnections(map, set, src_entry.key_ptr.*);
        }
    }
}

fn addConnection(map: *ConnectionMap, src: []const u8, dst: []const u8) !void {
    const entry = try map.getOrPut(src);
    if (!entry.found_existing) {
        entry.value_ptr.* = ConnectionSet.init(ally);
    }
    try entry.value_ptr.put(dst, {});
}
