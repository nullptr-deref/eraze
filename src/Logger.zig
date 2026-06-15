const std = @import("std");

pub const Logger = @This();

const BUF_SIZE = 4096;

io: std.Io,
write_buffer: [BUF_SIZE]u8 = undefined,

pub fn printError(self: *Logger, comptime fmt_str: []const u8, ins: anytype) !void {
    try self.printToFile(std.Io.File.stderr(), fmt_str, ins);
}

pub fn printMessage(self: *Logger, comptime fmt_str: []const u8, ins: anytype) !void {
    try self.printToFile(std.Io.File.stdout(), fmt_str, ins);
}

pub fn printToFile(self: *Logger,
    file: std.Io.File,
    comptime fmt_str: []const u8,
    ins: anytype
) !void {
    var file_writer = file.writer(self.io, &self.write_buffer);
    const writer = &file_writer.interface;

    const newlined_fmt = fmt_str ++ [_]u8{'\n'};
    try writer.print(newlined_fmt, ins);
    try writer.flush();
}

// zig vim:et:ts=4:sw=4:tw=80
