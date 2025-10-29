const std = @import("std");
const Alloc = std.mem.Allocator;

const GermanSlice = @import("GermanSlice.zig").GermanSlice;

pub fn main() !void {
    if (std.os.argv.len != 2) {
        std.debug.print(
            "Invalid arguments. Usage: `{s} german` or `{s} normal`\n",
            .{ std.os.argv[0], std.os.argv[0] },
        );
        return error.InvalidArguments;
    }

    const impl = std.mem.sliceTo(std.os.argv[1], @as(u8, 0));

    if (std.mem.eql(u8, "german", impl)) {
        const same, const different = try run_tests(GermanSlice);
        std.debug.print("Same: {d}\n", .{same});
        std.debug.print("Different: {d}\n", .{different});
    } else if (std.mem.eql(u8, "normal", impl)) {
        const same, const different = try run_tests(NormalSlice);
        std.debug.print("Same: {d}\n", .{same});
        std.debug.print("Different: {d}\n", .{different});
    } else {
        std.debug.print(
            "Invalid arguments. Usage: `{s} german` or `{s} normal`\n",
            .{ std.os.argv[0], std.os.argv[0] },
        );
        return error.InvalidArguments;
    }
}

fn run_tests(comptime T: type) !struct { usize, usize } {
    var same: usize = 0;
    var different: usize = 0;

    const buf_size = 128 * 256;
    var buf: [buf_size]u8 = undefined;
    for (0..128) |i| {
        for (0..256) |j| {
            const index: usize = (128 * i) + j;
            buf[index] = @intCast(i);
        }
    }

    var prng = std.Random.DefaultPrng.init(37);
    var random = prng.random();

    for (0..100_000) |_| {
        const case = random.intRangeLessThan(u8, 0, 100);
        if (case < 15) {
            // 15% of the time, compared strings are guaranteed to be identical
            const span = choose_span(&random, &buf);
            const s1: T = try .init(span);
            const s2: T = try .init(span);

            if (!s1.eql(s2)) {
                std.debug.print("Same strings not same? '{s}'\n", .{span});
                unreachable;
            }
            same += 1;
        } else {
            // 85% of the time, compared strings are randomly selected
            const span1 = choose_span(&random, &buf);
            const span2 = choose_span(&random, &buf);

            const s1: T = try .init(span1);
            const s2: T = try .init(span2);

            if (s1.eql(s2)) {
                same += 1;
            } else {
                different += 1;
            }
        }
    }

    return .{ same, different };
}

fn choose_span(random: *std.Random, buf: []u8) []const u8 {
    const case = random.intRangeLessThan(u8, 0, 100);
    if (case < 33) {
        // 33% of the time, strings are very small
        const run = random.intRangeLessThan(usize, 0, 32);
        const start = random.intRangeLessThan(usize, 0, buf.len - run - 1);
        return buf[start .. start + run];
    } else if (case < 66) {
        // 33% of the time, strings are medium sized
        const run = random.intRangeLessThan(usize, 32, 512);
        const start = random.intRangeLessThan(usize, 0, buf.len - run - 1);
        return buf[start .. start + run];
    } else if (case < 100) {
        // 34% of the time, strings are large
        const run = random.intRangeLessThan(usize, 512, 16384);
        const start = random.intRangeLessThan(usize, 0, buf.len - run - 1);
        return buf[start .. start + run];
    } else {
        unreachable;
    }
}

pub const NormalSlice = struct {
    content: []const u8,

    pub const InitError = error{TooLong};
    pub fn init(data: []const u8) InitError!NormalSlice {
        return .{
            .content = data,
        };
    }

    pub fn eql(this: NormalSlice, other: NormalSlice) bool {
        if (this.content.len != other.content.len) {
            return false;
        }

        return std.mem.eql(u8, this.content, other.content);
    }
};
