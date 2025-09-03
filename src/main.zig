const std = @import("std");
const Vec3 = @import("Vec3.zig");
const Ray = @import("Ray.zig");
const Writer = std.Io.Writer;

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    var file_writer = std.fs.File.stdout().writer(&buf);
    const out = &file_writer.interface;

    // Image
    const aspect_ratio: f64 = 16.0 / 9.0;
    const image_width: u32 = 400;
    const image_height: u32 = blk: {
        const h: u32 = image_width / aspect_ratio;
        if (h < 1) break :blk 1;
        break :blk h;
    };

    // Camera
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const ratio: f64 = blk: {
        const fw: f64 = @floatFromInt(image_width);
        const fh: f64 = @floatFromInt(image_height);
        break :blk fw / fh;
    };
    const viewport_width = viewport_height * ratio;
    const camera_center = Vec3.init(0, 0, 0);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.div(image_width);
    const pixel_delta_v = viewport_v.div(image_height);

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center.subtract(Vec3.init(0, 0, focal_length)).subtract(viewport_u.div(2)).subtract(viewport_v.div(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mul(0.5));

    try out.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });
    for (0..image_height) |h| {
        for (0..image_width) |w| {
            const fw: f64 = @floatFromInt(w);
            const fh: f64 = @floatFromInt(h);
            const pixel_center = pixel00_loc.add(pixel_delta_u.mul(fw)).add(pixel_delta_v.mul(fh));
            const ray_direction = pixel_center.subtract(camera_center);
            const r: Ray = .{ .ori = camera_center, .dir = ray_direction };
            // std.debug.print("{d:.3} ", .{@abs(r.dir.unit().y())});
            // std.debug.print("{f} ", .{vec.Fmt{ .data = r.dir.unit() }});
            // std.debug.print("{f} ", .{vec.Fmt{ .data = pixel_center }});
            const pixel_color = rayColor(r);
            try writeColor(pixel_color, out);
        }
        // std.debug.print("\n", .{});
    }
    try out.flush();
}

fn printP3(height: i32, width: i32, out: *Writer) !void {
    try out.print("P3\n{d} {d}\n255\n", .{ height, width });
    for (0..height) |h| {
        for (0..width) |w| {
            const fh: f32 = @floatFromInt(h);
            const fw: f32 = @floatFromInt(w);
            const v: Vec3 = .{ fh / (height - 1), fw / (width - 1), 0 };
            const rgb: Vec3.RGB256 = .{ .data = v };

            try out.print("{f}\n", .{rgb});
        }
    }
    try out.flush();
}

fn writeColor(color: Vec3, w: *Writer) !void {
    // const fh: f32 = @floatFromInt(h);
    // const fw: f32 = @floatFromInt(w);
    // const v: Vec3 = .{ fh / (height - 1), fw / (width - 1), 0 };
    const rgb: Vec3.RGB256 = .{ .data = color };
    try w.print("{f}\n", .{rgb});
}

fn rayColor(r: Ray) Vec3 {
    return raySimpleSphere(r);
}
fn raySimpleSphere(r: Ray) Vec3 {
    const center = Vec3.init(0, 0, -1);
    const raduis = 0.5;

    if (hitSphereTime(center, raduis, r)) |t| {
        if (t > 0.0) {
            const unit_nomal = r.at(t).subtract(center).unit();
            return Vec3.nomalColor(unit_nomal, -1, 1);
        }
    }
    return rayGradientColor(r);
}
fn rayGradientColor(r: Ray) Vec3 {
    const unit_dir: Vec3 = r.dir.unit();
    const a = 0.5 * (unit_dir.y() + 1.0);
    // std.debug.print("a: {d}, v: {f}\n", .{ a, vec.Fmt{ .data = unit_dir } });
    return (Vec3.init(1.0, 1.0, 1.0).mul(1.0 - a))
        .add(Vec3.init(1.0, 0.0, 1.0).mul(a));
}

fn hitSphereTime(center: Vec3, radius: f64, r: Ray) ?f64 {
    const oc: Vec3 = center.subtract(r.ori);
    const a = r.dir.dot(r.dir);
    const h = r.dir.dot(oc);
    const c = oc.dot(oc) - radius * radius;
    const discriminant = h * h - a * c;
    if (discriminant >= 0) {
        return (h - @sqrt(discriminant)) / a;
    }
    // null indicates no intersection
    return null;
}
// bool hit_sphere(const point3& center, double radius, const ray& r) {
//     vec3 oc = center - r.origin();
//     auto a = dot(r.direction(), r.direction());
//     auto b = -2.0 * dot(r.direction(), oc);
//     auto c = dot(oc, oc) - radius*radius;
//     auto discriminant = b*b - 4*a*c;
//     return (discriminant >= 0);
// }

// test "simple test" {
//     const gpa = std.testing.allocator;
//     var list: std.ArrayList(i32) = .empty;
//     defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
//     try list.append(gpa, 42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }

// test "fuzz example" {
//     const Context = struct {
//         fn testOne(context: @This(), input: []const u8) anyerror!void {
//             _ = context;
//             // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
//             try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
//         }
//     };
//     try std.testing.fuzz(Context{}, Context.testOne, .{});
// }

test "t1" {}
