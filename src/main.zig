const std = @import("std");
const gl = @import("gl");
const glfw = @import("zglfw");

var procs: gl.ProcTable = undefined;

const scr_width = 800;
const scr_height = 600;

const vertex_shader_source: [*:0]const u8 =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\void main() {
    \\    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\}
;

const fragment_shader_source: [*:0]const u8 =
    \\#version 330 core
    \\out vec4 FragColor;
    \\void main() {
    \\    FragColor = vec4(1.0, 0.5, 0.2, 1.0);
    \\}
;

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    glfw.windowHint(.context_version_major, 3);
    glfw.windowHint(.context_version_minor, 3);
    glfw.windowHint(.opengl_profile, .opengl_core_profile);
    glfw.windowHint(.opengl_forward_compat, true);

    const window = try glfw.createWindow(scr_width, scr_height, "LearnOpenGL", null);
    defer window.destroy();

    glfw.makeContextCurrent(window);
    _ = glfw.setFramebufferSizeCallback(window, framebufferSizeCallback);

    if (!procs.init(glfw.getProcAddress)) return error.InitFailed;
    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    // Build and compile shader program
    const vertex_shader = gl.CreateShader(gl.VERTEX_SHADER);
    defer gl.DeleteShader(vertex_shader);
    gl.ShaderSource(vertex_shader, 1, @ptrCast(&vertex_shader_source), null);
    gl.CompileShader(vertex_shader);
    try checkShaderError(vertex_shader, .compile);

    const fragment_shader = gl.CreateShader(gl.FRAGMENT_SHADER);
    defer gl.DeleteShader(fragment_shader);
    gl.ShaderSource(fragment_shader, 1, @ptrCast(&fragment_shader_source), null);
    gl.CompileShader(fragment_shader);
    try checkShaderError(fragment_shader, .compile);

    const shader_program = gl.CreateProgram();
    defer gl.DeleteProgram(shader_program);
    gl.AttachShader(shader_program, vertex_shader);
    gl.AttachShader(shader_program, fragment_shader);
    gl.LinkProgram(shader_program);
    try checkShaderError(shader_program, .link);

    // Set up vertex data and buffers
    const vertices = [_]f32{
        -0.5, -0.5, 0.0, // left
        0.5, -0.5, 0.0, // right
        0.0, 0.5, 0.0, // top
    };

    var vao: gl.uint = undefined;
    var vbo: gl.uint = undefined;
    gl.GenVertexArrays(1, @ptrCast(&vao));
    defer gl.DeleteVertexArrays(1, @ptrCast(&vao));
    gl.GenBuffers(1, @ptrCast(&vbo));
    defer gl.DeleteBuffers(1, @ptrCast(&vbo));

    gl.BindVertexArray(vao);

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.BufferData(gl.ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, gl.STATIC_DRAW);

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), 0);
    gl.EnableVertexAttribArray(0);

    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    gl.BindVertexArray(0);

    // Render loop
    while (!window.shouldClose()) {
        processInput(window);

        gl.ClearColor(0.2, 0.3, 0.3, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        gl.UseProgram(shader_program);
        gl.BindVertexArray(vao);
        gl.DrawArrays(gl.TRIANGLES, 0, 3);

        window.swapBuffers();
        glfw.pollEvents();
    }
}

fn checkShaderError(id: gl.uint, kind: enum { compile, link }) !void {
    var success: gl.int = undefined;
    switch (kind) {
        .compile => gl.GetShaderiv(id, gl.COMPILE_STATUS, @ptrCast(&success)),
        .link => gl.GetProgramiv(id, gl.LINK_STATUS, @ptrCast(&success)),
    }
    if (success != 0) return;

    var buf: [512]u8 = undefined;
    switch (kind) {
        .compile => gl.GetShaderInfoLog(id, buf.len, null, &buf),
        .link => gl.GetProgramInfoLog(id, buf.len, null, &buf),
    }
    const msg: [*:0]const u8 = @ptrCast(&buf);
    std.log.err("{s}", .{msg});
    return error.ShaderError;
}

fn framebufferSizeCallback(_: *glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    gl.Viewport(0, 0, width, height);
}

fn processInput(window: *glfw.Window) void {
    if (window.getKey(.escape) == .press) {
        window.setShouldClose(true);
    }
}
