const std = @import("std");
const input = @embedFile("puzzle_input");

const vec2 = @Vector(2, usize);

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Button = struct {
    tokens: usize,
    move: vec2,
};

pub fn main() !void {
    var res: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.peek()) |_| {
        const a = try parseButton(lines.next().?, 3);
        const b = try parseButton(lines.next().?, 1);
        const dst = try parsePrize(lines.next().?);

        var lo = a;
        var hi = b;
        if (costPerPress(a) > costPerPress(b)) {
            std.mem.swap(Button, &lo, &hi);
        }

        res += calcMinTokens(lo, hi, dst);
    }

    std.debug.print("{}", .{res});
}

fn calcMinTokens(lo: Button, hi: Button, dst: vec2) usize {
    var lo_tokens: usize = 0;
    var lo_pos = vec2{ 0, 0 };
    while (@reduce(.And, lo_pos < dst)) {
        lo_pos += lo.move;
        lo_tokens += lo.tokens;
    }

    if (@reduce(.And, lo_pos == dst)) {
        return lo_tokens;
    }

    while (@reduce(.And, lo_pos != vec2{ 0, 0 })) {
        lo_pos -= lo.move;
        lo_tokens -= lo.tokens;

        var hi_pos = lo_pos;
        var hi_tokens = lo_tokens;
        while (@reduce(.And, hi_pos < dst)) {
            hi_pos += hi.move;
            hi_tokens += hi.tokens;

            if (@reduce(.And, hi_pos == dst)) {
                return hi_tokens;
            }
        }
    }

    return 0;
}

fn costPerPress(button: Button) usize {
    return (button.move[0] + button.move[1]) * button.tokens;
}

fn parseButton(str: []const u8, tokens: usize) !Button {
    var split = std.mem.tokenizeAny(u8, str, " ,");
    _ = split.next();
    _ = split.next();
    const x = split.next().?;
    const y = split.next().?;

    return .{
        .tokens = tokens,
        .move = .{
            try std.fmt.parseInt(usize, x[2..], 10),
            try std.fmt.parseInt(usize, y[2..], 10),
        },
    };
}

fn parsePrize(str: []const u8) !vec2 {
    var split = std.mem.tokenizeAny(u8, str, " ,");
    _ = split.next();
    const x = split.next().?;
    const y = split.next().?;
    return .{
        try std.fmt.parseInt(usize, x[2..], 10),
        try std.fmt.parseInt(usize, y[2..], 10),
    };
}
