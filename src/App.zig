const std = @import("std");
const gl = @import("zgl");
const glsl = @import("glsl.zig");

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));

const Renderer = @import("Renderer.zig");

const App = @This();

running: bool,
renderer: Renderer,
allocator: std.mem.Allocator,

pub fn init(width: usize,
    height: usize,
    title: []const u8,
    allocator: std.mem.Allocator,
) !App {
    return App{
        .running = true,
        .renderer = try Renderer.init(width, height, title, allocator),
        .allocator = allocator,
    };
}

pub fn deinit(self: *App) void {
    self.running = false;
    self.renderer.deinit();
}

pub fn run(self: *App) anyerror!void {
    self.running = true;
    var brick = Renderer.RenderTarget{
        .program = gl.createProgram(),
        .vao = gl.genVertexArray(),
        .vbo = Renderer.SizedBuffer{
            .buffer = gl.genBuffer(),
            .len = 0,
            .element_type = null,
        },
        .indices = null,
        .primitive_type = gl.PrimitiveType.triangles,
    };

    const vshader = gl.createShader(gl.ShaderType.vertex);
    const vertex_shader_source = try glsl.readShaderFromFile(
        self.allocator,
        "resources/vertex.glsl",
    );
    defer self.allocator.free(vertex_shader_source);
    vshader.source(1, &[1][]const u8 {vertex_shader_source});
    vshader.compile();
    var compile_status = vshader.get(gl.ShaderParameter.compile_status);
    if (compile_status == 0) {
        std.debug.panic("vertex shader compilation failed", .{});
    }

    const fshader = gl.Shader.create(gl.ShaderType.fragment);
    const fragment_shader_source = try glsl.readShaderFromFile(
        self.allocator,
        "resources/fragment.glsl",
    );
    defer self.allocator.free(fragment_shader_source);
    fshader.source(1, &[1][]const u8{fragment_shader_source});
    fshader.compile();
    compile_status = fshader.get(gl.ShaderParameter.compile_status);
    if (compile_status == 0) {
        std.debug.panic("fragment shader compilation failed", .{});
    }

    brick.program.attach(vshader);
    brick.program.attach(fshader);
    brick.program.link();
    const link_status = brick.program.get(gl.ProgramParameter.link_status);
    if (link_status == 0) {
        std.debug.panic("program linkage failed", .{});
    }

    brick.vao.bind();

    const vertices = [_]f32 {
        0,     0,
        1.0,   0,
        0,   1.0
    };
    brick.vbo.buffer.bind(gl.BufferTarget.array_buffer);
    brick.vbo.len = vertices.len;
    gl.bufferData(gl.BufferTarget.array_buffer, f32, &vertices, gl.BufferUsage.static_draw);

    gl.vertexAttribPointer(0, 2, gl.Type.float, true, 2 * @sizeOf(f32), 0);
    gl.enableVertexAttribArray(0);

    gl.bindBuffer(gl.Buffer.invalid, gl.BufferTarget.array_buffer);
    gl.bindVertexArray(gl.VertexArray.invalid);

    try self.renderer.registerTarget(brick);

    while (!self.renderer.windowShouldClose()) {
        glfw.glfwPollEvents();
        self.renderer.renderFrame();
    }
}

//zig vim:et:ts=4:sw=4:tw=80
