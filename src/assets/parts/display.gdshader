shader_type canvas_item;

uniform bool a = true;
uniform bool b = true;
uniform bool c = true;
uniform bool d = true;
uniform bool e = true;
uniform bool f = true;
uniform bool g = true;
uniform bool dp = true;
uniform vec4 color: source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 bg_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

bool hbar(float x, float y) {
	float dx = 1.4 - abs(x - 2.5);
	return y < dx;
}

bool vbar(float x, float y) {
	float dy = 1.4 - y;
	return x < dy;
}

void fragment() {
	const float v = 0.2;
	float x = UV.x * 5.5;
	float y = UV.y * 8.0;
	vec4 col = bg_color;
	if (a && y > 0.5 + v  && y < 1.5 - v && hbar(x, abs(y - 1.0))) {
		col = color;
	}
	if (g && y > 3.5+ v && y < 4.5 - v && hbar(x, abs(y - 4.0))) {
		col = color;
	}
	if (d && y > 6.5 + v && y < 7.5 - v && hbar(x, abs(y - 7.0))) {
		col = color;
	}
	if (x > 3.5 + v && x < 4.5 - v) {
		if (b && y > 1.0 && y < 4.0 && vbar(abs(x - 4.0), abs(y - 2.5))) {
			col = color;
		}
		if (c && y > 4.0 && y < 7.0 && vbar(abs(x - 4.0), abs(y - 5.5))) {
			col = color;
		}
	}
	if (x > 0.5 + v && x < 1.5 - v) {
		if (f && y > 1.0 && y < 4.0 && vbar(abs(x - 1.0), abs(y - 2.5))) {
			col = color;
		}
		if (e && y > 4.0 && y < 7.0 && vbar(abs(x - 1.0), abs(y - 5.5))) {
			col = color;
		}
	}
	if (dp && length(abs(vec2(x - 4.8, y - 7.0))) < 0.35) {
		col = color;
	}
	COLOR = col;
}
