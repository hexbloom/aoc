const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    _ = try parseRegister(lines.next().?);
    _ = try parseRegister(lines.next().?);
    _ = try parseRegister(lines.next().?);
    const program = try parseProgram(lines.next().?);

    var output_map: [8]std.ArrayList(u10) = undefined;
    for (&output_map) |*m| {
        m.* = std.ArrayList(u10).init(ally);
    }
    for (0..std.math.maxInt(u10)) |i| {
        const output = try executeProgram(program, i);
        try output_map[output[0]].append(@intCast(i));
    }

    var reg_vals = try ally.alloc(usize, program.len);
    for (reg_vals) |*r| {
        r.* = 0;
    }
    var program_idx = program.len - 1;
    while (true) {
        const desired_output = program[program_idx];
        const valid_inputs = output_map[desired_output];
        if (reg_vals[program_idx] >= valid_inputs.items.len) {
            program_idx += 1;
            if (program_idx >= program.len) {
                return error.NoSolution;
            }
            reg_vals[program_idx] = 0;
        }
        const reg = valid_inputs.items[reg_vals[program_idx]];
        var is_valid = true;
        const program_idx2 = program_idx + 1;
        if (program_idx2 < program.len) {
            const desired_output2 = program[program_idx2];
            const valid_inputs2 = output_map[desired_output2];
            const reg2 = valid_inputs2.items[reg_vals[program_idx2]];
            const reg_input: u7 = @truncate(reg2);
            if ((reg >> 3) != reg_input) {
                is_valid = false;
            }
        }

        if (is_valid) {
            if (program_idx == 0) {
                break;
            }
            program_idx -= 1;
        } else {
            reg_vals[program_idx] += 1;
            if (reg_vals[program_idx] >= valid_inputs.items.len) {
                program_idx += 1;
                if (program_idx >= program.len) {
                    return error.NoSolution;
                }
                for (reg_vals[0..program_idx]) |*val| {
                    val.* = 0;
                }
                reg_vals[program_idx] += 1;
            }
        }
    }

    var res: usize = 0;
    for (reg_vals, 0..) |r, i| {
        const desired_output = program[i];
        const valid_inputs = output_map[desired_output];
        const reg = valid_inputs.items[r];
        res |= @as(usize, @intCast(reg)) << (@intCast(i * 3));
    }
    const out = try executeProgram(program, res);
    for (out) |o| {
        std.debug.print("{},", .{o});
    }
    std.debug.print("{}\n", .{res});
}

fn executeProgram(program: []const u3, start_a: usize) ![]u3 {
    var reg_a: usize = start_a;
    var reg_b: usize = 0;
    var reg_c: usize = 0;

    var output = std.ArrayList(u3).init(ally);
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
            0 => reg_a = reg_a >> @intCast(combo),
            1 => reg_b ^= literal,
            2 => reg_b = combo % 8,
            3 => if (reg_a != 0) {
                ip = literal;
                inc_ip = false;
            },
            4 => reg_b ^= reg_c,
            5 => try output.append(@intCast(combo % 8)),
            6 => reg_b = reg_a >> @intCast(combo),
            7 => reg_c = reg_a >> @intCast(combo),
        }

        if (inc_ip) {
            ip += 2;
        }
    }

    return try output.toOwnedSlice();
}

fn parseRegister(line: []const u8) !usize {
    var split = std.mem.tokenizeScalar(u8, line, ' ');
    _ = split.next();
    _ = split.next();
    return try std.fmt.parseInt(usize, split.next().?, 10);
}

fn parseProgram(line: []const u8) ![]const u3 {
    var program_list = std.ArrayList(u3).init(ally);
    var split = std.mem.tokenizeAny(u8, line, " ,");
    _ = split.next();
    while (split.next()) |instruction| {
        try program_list.append(try std.fmt.parseInt(u3, instruction, 10));
    }
    return program_list.toOwnedSlice();
}
