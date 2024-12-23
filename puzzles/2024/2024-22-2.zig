const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const cache_len = 4;
const num_iterations = 2000;

pub fn main() !void {
    var best_sale_map = std.AutoHashMap([cache_len]isize, isize).init(ally);
    var visited_deltas = std.AutoHashMap([cache_len]isize, void).init(ally);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var secret = try std.fmt.parseInt(isize, line, 10);
        var prev_sale = @rem(secret, 10);
        var delta_sale: [cache_len]isize = undefined;
        var write_index: usize = 0;

        for (0..num_iterations) |secret_index| {
            secret = getNextSecret(secret);

            const cur_sale = @rem(secret, 10);
            delta_sale[write_index] = cur_sale - prev_sale;
            write_index = (write_index + 1) % cache_len;

            prev_sale = cur_sale;

            if (secret_index < cache_len - 1) {
                continue;
            }

            var delta_key: [cache_len]isize = undefined;
            var read_index = write_index;
            for (0..cache_len) |key_index| {
                delta_key[key_index] = delta_sale[read_index];
                read_index = (read_index + 1) % cache_len;
            }

            if (visited_deltas.get(delta_key) != null) {
                continue;
            }

            const entry = try best_sale_map.getOrPutValue(delta_key, 0);
            entry.value_ptr.* += cur_sale;
            try visited_deltas.put(delta_key, {});
        }

        visited_deltas.clearRetainingCapacity();
    }

    var best_sales = best_sale_map.iterator();
    var best_sale: isize = 0;
    while (best_sales.next()) |entry| {
        best_sale = @max(best_sale, entry.value_ptr.*);
    }
    std.debug.print("{}", .{best_sale});
}

fn getNextSecret(secret: isize) isize {
    var next_secret = secret;
    next_secret = prune(mix(next_secret, next_secret << 6));
    next_secret = prune(mix(next_secret, next_secret >> 5));
    next_secret = prune(mix(next_secret, next_secret << 11));
    return next_secret;
}

fn mix(a: isize, b: isize) isize {
    return a ^ b;
}

fn prune(a: isize) isize {
    return @rem(a, 16777216);
}
