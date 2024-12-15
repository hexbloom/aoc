const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Button = struct {
    tokens: usize,
    move: [2]f64,
};

pub fn main() !void {
    var res: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.peek()) |_| {
        const a = try parseButton(lines.next().?, 3);
        const b = try parseButton(lines.next().?, 1);
        const prize = try parsePrize(lines.next().?);

        const a_equation = [3]f64{ a.move[0], b.move[0], prize[0] };
        const b_equation = [3]f64{ a.move[1], b.move[1], prize[1] };
        const solution = cramer(.{ a_equation, b_equation });
        if (@trunc(solution[0]) != solution[0] or @trunc(solution[1]) != solution[1]) {
            continue;
        }

        const num_a = @as(usize, @intFromFloat(solution[0]));
        const num_b = @as(usize, @intFromFloat(solution[1]));
        res += a.tokens * num_a + b.tokens * num_b;
    }

    std.debug.print("{}", .{res});
}

fn cramer(system: [2][3]f64) [2]f64 {
    const d = (system[0][0] * system[1][1]) - (system[1][0] * system[0][1]);
    const dx = (system[0][2] * system[1][1]) - (system[1][2] * system[0][1]);
    const dy = (system[0][0] * system[1][2]) - (system[1][0] * system[0][2]);
    return .{ dx / d, dy / d };
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
            try std.fmt.parseFloat(f64, x[2..]),
            try std.fmt.parseFloat(f64, y[2..]),
        },
    };
}

fn parsePrize(str: []const u8) ![2]f64 {
    var split = std.mem.tokenizeAny(u8, str, " ,");
    _ = split.next();
    const x = split.next().?;
    const y = split.next().?;
    return .{
        try std.fmt.parseFloat(f64, x[2..]) + 10000000000000,
        try std.fmt.parseFloat(f64, y[2..]) + 10000000000000,
    };
}
