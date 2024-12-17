const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var reg_a = try parseRegister(lines.next().?);
    var reg_b = try parseRegister(lines.next().?);
    var reg_c = try parseRegister(lines.next().?);
    const program = try parseProgram(lines.next().?);

    var output = std.ArrayList(usize).init(ally);
    var ip: usize = 0;
    while (ip < program.len - 1) {
        const opcode = program[ip];
        const literal = program[ip + 1];
        const combo: usize = switch (literal) {
            0, 1, 2, 3 => |i| @intCast(i),
            4 => reg_a,
            5 => reg_b,
            6 => reg_c,
            7 => undefined,
        };
        var inc_ip = true;
        switch (opcode) {
            0 => reg_a = reg_a / std.math.pow(usize, 2, combo),
            1 => reg_b ^= literal,
            2 => reg_b = combo % 8,
            3 => if (reg_a != 0) {
                ip = literal;
                inc_ip = false;
            },
            4 => reg_b ^= reg_c,
            5 => try output.append(combo % 8),
            6 => reg_b = reg_a / std.math.pow(usize, 2, combo),
            7 => reg_c = reg_a / std.math.pow(usize, 2, combo),
        }

        if (inc_ip) {
            ip += 2;
        }
    }

    for (output.items, 0..) |val, i| {
        std.debug.print("{}", .{val});
        if (i < output.items.len - 1) {
            std.debug.print(",", .{});
        }
    }
}

fn parseRegister(line: []const u8) !usize {
    var split = std.mem.tokenizeScalar(u8, line, ' ');
    _ = split.next();
    _ = split.next();
    return try std.fmt.parseInt(usize, split.next().?, 10);
}

fn parseProgram(line: []const u8) ![]u3 {
    var program_list = std.ArrayList(u3).init(ally);
    var split = std.mem.tokenizeAny(u8, line, " ,");
    _ = split.next();
    while (split.next()) |instruction| {
        try program_list.append(try std.fmt.parseInt(u3, instruction, 10));
    }
    return program_list.toOwnedSlice();
}
