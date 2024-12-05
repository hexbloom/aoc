const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const BeforeMap = std.AutoHashMap(u32, std.ArrayList(u32));

pub fn main() !void {
    var res: u32 = 0;

    var before_map = BeforeMap.init(ally);
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var split = std.mem.splitScalar(u8, line, '|');
        const before = try std.fmt.parseInt(u32, split.next().?, 10);
        const after = try std.fmt.parseInt(u32, split.next().?, 10);

        const entry = try before_map.getOrPut(before);
        if (!entry.found_existing) {
            entry.value_ptr.* = std.ArrayList(u32).init(ally);
        }
        try entry.value_ptr.append(after);
    }

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var split = std.mem.splitScalar(u8, line, ',');
        var pages_list = std.ArrayList(u32).init(ally);
        while (split.next()) |val| {
            try pages_list.append(try std.fmt.parseInt(u32, val, 10));
        }
        const pages = try pages_list.toOwnedSlice();
        if (!arePagesInOrder(pages, before_map)) {
            sortPages(pages, before_map);
            res += pages[pages.len / 2];
        }
    }

    std.debug.print("{}", .{res});
}

fn arePagesInOrder(pages: []const u32, before_map: BeforeMap) bool {
    for (pages, 0..) |before, i| {
        for (pages[i + 1 ..]) |after| {
            if (before_map.get(before)) |before_list| {
                if (std.mem.indexOfScalar(u32, before_list.items, after) != null) {
                    continue;
                }
            }
            return false;
        }
    }

    return true;
}

fn sortPages(pages: []u32, before_map: BeforeMap) void {
    var i: usize = 0;
    var j: usize = 1;
    while (i < pages.len) : (j = i + 1) {
        var in_order = true;
        const before = pages[i];
        while (j < pages.len) : (j += 1) {
            const after = pages[j];
            if (before_map.get(before)) |before_list| {
                if (std.mem.indexOfScalar(u32, before_list.items, after) != null) {
                    continue;
                }
            }
            std.mem.swap(u32, &pages[i], &pages[j]);
            in_order = false;
            break;
        }

        if (in_order) {
            i += 1;
        }
    }
}
