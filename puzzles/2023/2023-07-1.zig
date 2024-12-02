const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const HandType = enum { one, two, twotwo, three, full, four, five };

const Hand = struct {
    cards: []const u8,
    bid: i64,

    pub fn lessThan(self: Hand, other: Hand) bool {
        const self_hand = self.getHandType();
        const other_hand = other.getHandType();

        if (self_hand != other_hand) {
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
                'J' => 11,
                'Q' => 12,
                'K' => 13,
                'A' => 14,
                else => 0,
            };
        }
    }

    fn getHandType(hand: Hand) HandType {
        var map = std.AutoHashMap(u8, i64).init(ally);
        for (hand.cards) |c| {
            const entry = map.getOrPutValue(c, 0) catch unreachable;
            entry.value_ptr.* += 1;
        }

        var max_cards: i64 = 0;
        var val_it = map.valueIterator();
        while (val_it.next()) |num_cards| {
            max_cards = @max(max_cards, num_cards.*);
        }

        switch (max_cards) {
            5 => return .five,
            4 => return .four,
            3 => {
                var retest_it = map.valueIterator();
                while (retest_it.next()) |num_cards| {
                    if (num_cards.* == 2) {
                        return .full;
                    }
                }

                return .three;
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
                    return .twotwo;
                } else {
                    return .two;
                }
            },
            else => return .one,
        }
    }
};

pub fn main() !void {
    var res: i64 = 0;

    var hands = std.ArrayList(Hand).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ' ');
        try hands.append(.{
            .cards = split.next().?,
            .bid = try std.fmt.parseInt(i64, split.next().?, 10),
        });
    }

    std.sort.pdq(Hand, hands.items, {}, sortHand);

    for (hands.items, 0..) |hand, i| {
        res += hand.bid * @as(i32, @intCast(i + 1));
    }

    std.debug.print("{}", .{res});
}

fn sortHand(_: void, a: Hand, b: Hand) bool {
    return a.lessThan(b);
}
