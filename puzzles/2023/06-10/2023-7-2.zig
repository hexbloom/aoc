const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

const HandType = enum { one, two, twotwo, three, full, four, five };

const Hand = struct {
    cards: []const u8,
    bid: i64,

    pub fn lessThan(self: Hand, other: Hand, ally: std.mem.Allocator) bool {
        const self_hand = self.getHandType(ally);
        const other_hand = other.getHandType(ally);

        if (@intFromEnum(self_hand) != @intFromEnum(other_hand)) {
            return @intFromEnum(self_hand) < @intFromEnum(other_hand);
        } else {
            for (self.cards, other.cards) |self_card, other_card| {
                if (getCardValue(self_card) != getCardValue(other_card)) {
                    return getCardValue(self_card) < getCardValue(other_card);
                }
            }
        }

        return false;
    }

    fn getCardValue(card: u8) i64 {
        if (std.ascii.isDigit(card)) {
            return card - '0';
        } else {
            return switch (card) {
                'T' => 10,
                'J' => -1,
                'Q' => 12,
                'K' => 13,
                'A' => 14,
                else => 0,
            };
        }
    }

    fn getHandType(hand: Hand, ally: std.mem.Allocator) HandType {
        var map = std.AutoHashMap(u8, i64).init(ally);
        var num_jacks: i64 = 0;
        for (hand.cards) |c| {
            if (c == 'J') {
                num_jacks += 1;
            } else {
                const entry = map.getOrPutValue(c, 0) catch unreachable;
                entry.value_ptr.* += 1;
            }
        }

        var max_cards: i64 = 0;
        var val_it = map.valueIterator();
        while (val_it.next()) |num_cards| {
            max_cards = @max(max_cards, num_cards.*);
        }

        switch (max_cards) {
            5 => return .five,
            4 => return if (num_jacks == 1) .five else .four,
            3 => {
                var retest_it = map.valueIterator();
                while (retest_it.next()) |num_cards| {
                    if (num_cards.* == 2) {
                        return .full;
                    }
                }

                return switch (num_jacks) {
                    0 => .three,
                    1 => .four,
                    2 => .five,
                    else => unreachable,
                };
            },
            2 => {
                var num_pairs: i64 = 0;
                var retest_it = map.valueIterator();
                while (retest_it.next()) |num_cards| {
                    if (num_cards.* == 2) {
                        num_pairs += 1;
                    }
                }

                if (num_pairs == 2) {
                    if (num_jacks == 1) {
                        return .full;
                    } else {
                        return .twotwo;
                    }
                } else {
                    return switch (num_jacks) {
                        0 => .two,
                        1 => .three,
                        2 => .four,
                        3 => .five,
                        else => unreachable,
                    };
                }
            },
            1, 0 => {
                return switch (max_cards + num_jacks) {
                    5 => .five,
                    4 => .four,
                    3 => .three,
                    2 => .two,
                    1 => .one,
                    else => unreachable,
                };
            },
            else => unreachable,
        }
    }
};

pub fn solve(ctx: Context) !void {
    var res: i64 = 0;

    var hands = std.ArrayList(Hand).init(ctx.ally);
    for (ctx.lines) |line| {
        const split = try utils.split(ctx.ally, line, " ");
        try hands.append(.{
            .cards = split[0],
            .bid = try std.fmt.parseInt(i64, split[1], 10),
        });
    }

    std.sort.pdq(Hand, hands.items, ctx, sortHand);

    for (hands.items, 0..) |hand, i| {
        res += hand.bid * @as(i32, @intCast(i + 1));
    }

    std.debug.print("{}", .{res});
}

fn sortHand(ctx: Context, a: Hand, b: Hand) bool {
    return a.lessThan(b, ctx.ally);
}
