#version 330 core

in vec2 pos;

out vec4 color;

void main() {
    color = vec4(1.0, abs(pos.x), abs(pos.y), 1.0);
}
