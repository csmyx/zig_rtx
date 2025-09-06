const std = @import("std");

pub const Interval = struct {
    min: f64,
    max: f64,

    const empty: Interval = .init(std.math.floatMax(f64), -std.math.floatMax(f64));
    const universe: Interval = .init(-std.math.floatMax(f64), std.math.floatMax(f64));

    pub fn init(min: f64, max: f64) Interval {
        return .{ .min = min, .max = max };
    }
    pub fn size(self: Interval) f64 {
        return self.max - self.min;
    }
    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }
    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }
};

// test "1" {
//     const f: f64 = std.math.floatMax(f64);
//     std.debug.print("\n{d}\n", .{f});
//     var d: f64 = -std.math.floatMax(f64);
//     std.debug.print("\n{d}\n", .{d});
//     d -= 1;
//     std.debug.print("\n{d}\n", .{d});
//     var x: f64 = 100000000;
//     x -= 1;
//     std.debug.print("\n{d}\n", .{x});
// }
