#version 330 core

layout (location = 0) in vec2 p;

out vec2 pos;

void main() {
    gl_Position = vec4(p, 1.0, 1.0);
    pos = p;
}
