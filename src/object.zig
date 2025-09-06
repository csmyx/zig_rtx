const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const builtin = @import("builtin");
const std = @import("std");
const assert = std.debug.assert;
const testing = std.testing;
const Allocator = std.mem.Allocator;
const util = @import("util.zig");
const Interval = util.Interval;

pub const Object = union(enum) {
    sphere: Sphere,
    pub fn hit(o: Object, r: Ray, ray_t: Interval) ?HitRecord {
        return switch (o) {
            inline else => |o_| o_.hit(r, ray_t),
        };
    }
};

pub const Sphere = struct {
    center: Vec3,
    radius: f64,
    pub fn hit(s: Sphere, r: Ray, ray_t: Interval) ?HitRecord {
        const oc: Vec3 = s.center.subtract(r.ori);
        const a = r.dir.dot(r.dir);
        const h = r.dir.dot(oc);
        const c = oc.dot(oc) - s.radius * s.radius;
        const discriminant = h * h - a * c;
        if (discriminant >= 0) {
            const sqrt_d = @sqrt(discriminant);
            var t = (h - sqrt_d) / a; // try first root
            if (!ray_t.surrounds(t)) {
                t = (h + sqrt_d) / a; // try second root
                if (!ray_t.surrounds(t)) {
                    return null;
                }
            }
            const hit_point: Vec3.Point = r.at(t);
            const outward_normal: Vec3 = hit_point.subtract(s.center).unit();
            return .init(t, hit_point, r, outward_normal);
        }
        return null;
    }
};

const HitRecord = struct {
    t: f64, // hit time
    p: Vec3.Point, // hit point
    normal: Vec3, // hit normal vector
    front_face: bool, // true if hit from outside

    pub fn init(t: f64, p: Vec3.Point, r: Ray, outward_normal: Vec3) HitRecord {
        if (builtin.mode == .Debug) {
            // NOTE: the parameter `outward_normal` is assumed to be an unit vector
            const mag = outward_normal.magnitude();
            assert(std.math.approxEqAbs(f64, mag, 1, 0.001));
        }
        var normal = outward_normal;
        var front_face = true;
        if (r.dir.dot(normal) > 0) {
            normal = normal.opposite();
            front_face = false;
        }
        return .{
            .t = t,
            .p = p,
            .normal = normal,
            .front_face = front_face,
        };
    }

    pub fn equal(self: HitRecord, other: HitRecord) bool {
        return self.t == other.t and
            self.front_face == other.front_face and
            self.p.equal(other.p) and
            self.normal.equal(other.normal);
    }
};

pub const World = struct {
    list: []const Object,
    // Return HitRecord with the minimum ray_t among hits on the object list (if any).
    pub fn minimum_hit(self: World, r: Ray, ray_t: Interval) ?HitRecord {
        var hit_anything = false;
        var min_hit_t = ray_t.max;
        var min_hit_record: ?HitRecord = null;
        for (self.list) |o| {
            if (o.hit(r, .init(ray_t.min, min_hit_t))) |hr| {
                hit_anything = true;
                min_hit_t = hr.t;
                min_hit_record = hr;
            }
        }
        return min_hit_record;
    }
};
// const ObjectList = struct {
//     a: std.ArrayList(Object),
//     pub fn init(gpa: Allocator, obj_list: []Object) ObjectList {
//         var list: ObjectList = .{ .a = .empty };
//         for (obj_list) |o| {
//             try list.a.append(gpa, o);
//         }
//         return list;
//     }

//     pub fn add(list: *ObjectList, gpa: Allocator, o: Object) void {
//         try list.a.append(gpa, o);
//     }

//     // Return HitRecord with the minimum ray_t (if any).
//     pub fn hit(list: ObjectList, r: Ray, ray_tmin: f64, ray_tmax: f64) ?HitRecord {
//         var hit_anything = false;
//         var min_hit_t = ray_tmax;
//         var min_hit_record: ?HitRecord = null;
//         for (list.a.items) |o| {
//             if (o.hit(r, ray_tmin, min_hit_t)) |hr| {
//                 hit_anything = true;
//                 min_hit_t = hr.t;
//                 min_hit_record = hr;
//             }
//         }
//         return min_hit_record;
//     }
//     pub fn deinit(list: *ObjectList, gpa: Allocator) void {
//         list.a.deinit(gpa);
//     }
// };

test "sphere" {
    const sphere = Object{ .sphere = .{ .center = .init(0, 0, -1), .radius = 0.5 } };
    const r: Ray = .{ .ori = .init(0, 0, 0), .dir = .init(0, 0, -1) };
    const hr = sphere.hit(r, 0.0, 1.0);
    try testing.expect(hr != null);
    try testing.expect(hr.?.equal(.init(0.5, .init(0, 0, -0.5), r, .init(0, 0, 1))));
}
