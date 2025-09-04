const std = @import("std");
const Writer = std.Io.Writer;

const Vec3 = @This();
pub const Point = Vec3;
const Zero: Vec3 = .{ .e = @splat(0) };

e: E,

const E = @Vector(3, f64);

pub fn init(x_: f64, y_: f64, z_: f64) Vec3 {
    return .{ .e = .{ x_, y_, z_ } };
}

pub fn initE(e: E) Vec3 {
    return .{ .e = e };
}

pub fn x(self: Vec3) f64 {
    return self.e[0];
}

pub fn y(self: Vec3) f64 {
    return self.e[1];
}

pub fn z(self: Vec3) f64 {
    return self.e[2];
}

pub fn magnitude(self: Vec3) f64 {
    // const sum = v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
    // return std.math.sqrt(sum);
    return @sqrt(@reduce(.Add, self.e * self.e));
}

pub fn unit(self: Vec3) Vec3 {
    const mag = magnitude(self);
    if (mag == 0) return Zero;
    return self.div(mag);
}

pub fn opposite(self: Vec3) Vec3 {
    return self.mul(-1);
}

pub fn mul(self: Vec3, f: f64) Vec3 {
    const e: E = @splat(f);
    return .{ .e = self.e * e };
}

pub fn mul3(self: Vec3, other: Vec3) Vec3 {
    return .{ .e = self.e * other.e };
}

pub fn div(self: Vec3, f: f64) Vec3 {
    const e: E = @splat(f);
    return .{ .e = self.e / e };
}

pub fn dot(self: Vec3, other: Vec3) f64 {
    return @reduce(.Add, self.e * other.e);
}

pub fn cross(self: Vec3, other: Vec3) Vec3 {
    return .{ .e = .{
        self.e[1] * other.e[2] - self.e[2] * other.e[1],
        self.e[2] * other.e[0] - self.e[0] * other.e[2],
        self.e[0] * other.e[1] - self.e[1] * other.e[0],
    } };
}

pub fn add(self: Vec3, other: Vec3) Vec3 {
    return .{ .e = self.e + other.e };
}

pub fn subtract(self: Vec3, other: Vec3) Vec3 {
    return .{ .e = self.e - other.e };
}

pub fn equal(self: Vec3, other: Vec3) bool {
    return @reduce(.And, self.e == other.e);
}

pub const Fmt = std.fmt.Alt(Vec3, format);
fn format(v: Vec3, w: *Writer) !void {
    try w.print("<{d:.3} {d:.3} {d:.3}>", .{ v.e[0], v.e[1], v.e[2] });
}

pub const RGB256 = std.fmt.Alt(Vec3, rgb256Format);
fn rgb256Format(color: Vec3, w: *Writer) !void {
    const color_unit: Vec3 = .{ .e = @splat(255.999) };
    const rgb: Vec3 = color.mul3(color_unit);

    const r: u8 = @intFromFloat(rgb.x());
    const g: u8 = @intFromFloat(rgb.y());
    const b: u8 = @intFromFloat(rgb.z());

    try w.print("{d} {d} {d}", .{ r, g, b });
}

pub fn nomalColor(v: Vec3, mn: f64, mx: f64) Vec3 {
    const x_ = (v.e[0] - mn) / (mx - mn);
    const y_ = (v.e[1] - mn) / (mx - mn);
    const z_ = (v.e[2] - mn) / (mx - mn);
    return .{ .e = .{ x_, y_, z_ } };
}
