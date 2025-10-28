const std = @import("std");
const Alloc = std.mem.Allocator;

const GermanSlice = @import("GermanSlice.zig").GermanSlice;

pub fn main() !void {
    var da = std.heap.DebugAllocator(.{}).init;
    defer _ = da.deinit();

    if (std.os.argv.len != 2) {
        std.debug.print(
            "Invalid arguments. Usage: `{s} german` or `{s} normal`\n",
            .{ std.os.argv[0], std.os.argv[0] },
        );
        return error.InvalidArguments;
    }

    const alloc = da.allocator();
    const impl = std.mem.sliceTo(std.os.argv[1], @as(u8, 0));

    if (std.mem.eql(u8, "german", impl)) {
        const same, const different = try run_tests(GermanSlice, alloc);
        std.debug.print("Same: {d}\n", .{same});
        std.debug.print("Different: {d}\n", .{different});
    } else if (std.mem.eql(u8, "normal", impl)) {
        const same, const different = try run_tests(NormalSlice, alloc);
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

fn run_tests(comptime T: type, alloc: Alloc) !struct { usize, usize } {
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

    for (0..10_000) |_| {
        const case = random.intRangeLessThan(u8, 0, 100);
        if (case < 15) {
            // 15% of the time, compared strings are guaranteed to be identical
            const span = choose_span(&random, &buf);
            var s1: T = try .init(alloc, span);
            var s2: T = try .init(alloc, span);

            if (!s1.eql(s2)) {
                std.debug.print("Same strings not same? '{s}'\n", .{span});
                unreachable;
            }
            same += 1;

            s1.deinit(alloc);
            s2.deinit(alloc);
        } else {
            // 85% of the time, compared strings are randomly selected
            const span1 = choose_span(&random, &buf);
            const span2 = choose_span(&random, &buf);

            var s1: T = try .init(alloc, span1);
            var s2: T = try .init(alloc, span2);

            if (s1.eql(s2)) {
                same += 1;
            } else {
                different += 1;
            }

            s1.deinit(alloc);
            s2.deinit(alloc);
        }
    }

    return .{ same, different };
}

fn choose_span(random: *std.Random, buf: []u8) []const u8 {
    const case = random.intRangeLessThan(u8, 0, 100);
    if (case < 60) {
        // 60% of the time, strings are very small
        const run = random.intRangeLessThan(usize, 0, 32);
        const start = random.intRangeLessThan(usize, 0, buf.len - run - 1);
        return buf[start .. start + run];
    } else if (case < 90) {
        // 30% of the time, strings are medium sized
        const run = random.intRangeLessThan(usize, 32, 512);
        const start = random.intRangeLessThan(usize, 0, buf.len - run - 1);
        return buf[start .. start + run];
    } else if (case < 100) {
        // 10% of the time, strings are large
        const run = random.intRangeLessThan(usize, 512, 4096);
        const start = random.intRangeLessThan(usize, 0, buf.len - run - 1);
        return buf[start .. start + run];
    } else {
        unreachable;
    }
}

pub const NormalSlice = struct {
    len: u32,
    content: []const u8,

    pub const InitError = error{TooLong} || Alloc.Error;
    pub fn init(alloc: Alloc, data: []const u8) InitError!NormalSlice {
        if (data.len > std.math.maxInt(u32)) {
            return error.TooLong;
        }

        const copy = try alloc.dupe(u8, data);
        return .{
            .len = @intCast(data.len),
            .content = copy,
        };
    }

    pub fn deinit(this: *NormalSlice, alloc: Alloc) void {
        alloc.free(this.content);
    }

    pub fn eql(this: NormalSlice, other: NormalSlice) bool {
        if (this.len != other.len) {
            return false;
        }

        return std.mem.eql(u8, this.content, other.content);
    }
};
