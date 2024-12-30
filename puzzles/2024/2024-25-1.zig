const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var keys = std.ArrayList([5]u8).init(ally);
    var locks = std.ArrayList([5]u8).init(ally);

    var read_height: u8 = 6;
    var read_key: bool = undefined;
    var read_char: u8 = undefined;
    var read_schematic: [5]u8 = undefined;
    var read_pending: [5]bool = undefined;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (read_height == 6) {
            read_key = std.mem.eql(u8, line, ".....");
            read_char = if (read_key) '#' else '.';
            read_schematic = .{ 0, 0, 0, 0, 0 };
            read_pending = .{ true, true, true, true, true };
            read_height -= 1;
        } else if (read_height == 0) {
            const list = if (read_key) &keys else &locks;
            try list.append(read_schematic);
            read_height = 6;
        } else {
            for (line, 0..) |c, i| {
                if (read_pending[i] and c == read_char) {
                    read_schematic[i] = read_height;
                    read_pending[i] = false;
                }
            }
            read_height -= 1;
        }
    }

    var res: usize = 0;
    for (keys.items) |key| {
        for (locks.items) |lock| {
            if (keyFitsLock(key, lock)) {
                res += 1;
            }
        }
    }
    std.debug.print("{}", .{res});
}

fn keyFitsLock(key: [5]u8, lock: [5]u8) bool {
    for (key, lock) |k, l| {
        if (k > l) {
            return false;
        }
    }
    return true;
}
