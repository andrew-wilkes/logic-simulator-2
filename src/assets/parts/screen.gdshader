shader_type canvas_item;

uniform sampler2D pixels;

void fragment() {
	COLOR = texture(pixels, UV);
}
