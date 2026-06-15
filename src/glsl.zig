const std = @import("std");

pub fn readShaderFromFile(
    io: std.Io,
    allocator: std.mem.Allocator,
    rel_path: []const u8
) ![]u8 {
    const f = try std.Io.Dir.cwd().openFile(io, rel_path, .{
        .mode = std.Io.File.OpenMode.read_only,
    });
    defer f.close(io);

    var buffer: [4096]u8 = undefined;
    const read_size = try f.readPositionalAll(io, &buffer, 0);
    const read_slice = buffer[0..read_size];
    const ret_buffer = try allocator.alloc(u8, read_size);
    @memcpy(ret_buffer, read_slice);

    return ret_buffer;
}

// zig vim:et:ts=4:sw=4:tw=80
