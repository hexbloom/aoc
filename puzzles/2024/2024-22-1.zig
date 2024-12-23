const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var res: usize = 0;
    while (lines.next()) |line| {
        var secret = try std.fmt.parseInt(usize, line, 10);
        for (0..2000) |_| {
            secret = getNextSecret(secret);
        }
        res += secret;
    }
    std.debug.print("{}", .{res});
}

fn getNextSecret(secret: usize) usize {
    var next_secret = secret;
    next_secret = prune(mix(next_secret, next_secret * 64));
    next_secret = prune(mix(next_secret, next_secret / 32));
    next_secret = prune(mix(next_secret, next_secret * 2048));
    return next_secret;
}

fn mix(a: usize, b: usize) usize {
    return a ^ b;
}

fn prune(a: usize) usize {
    return a % 16777216;
}
