const Ray = @This();
const std = @import("std");
const vec = @import("vec.zig");
const Vec3 = vec.Vec3;

ori: Vec3,
dir: Vec3,

pub fn at(self: Ray, t: f64) Vec3 {
    return self.ori.add(self.dir.mul(t));
}

// pub fn origin(self: Ray) *Vec3 {
//     return self.ori;
// }
// pub fn direction(self: Ray) *Vec3 {
//     return self.dir;
// }
