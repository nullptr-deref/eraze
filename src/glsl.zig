const std = @import("std");

pub fn readShaderFromFile(allocator: std.mem.Allocator, rel_path: []const u8) ![]u8 {
    const f = try std.fs.cwd().openFile(rel_path, .{
        .mode = std.fs.File.OpenMode.read_only,
    });
    defer f.close();

    return try f.reader().readAllAlloc(allocator, std.math.maxInt(u32));
}
