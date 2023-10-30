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

bool hbar(float x, float y) {
	float dx = 1.4 - abs(x - 3.0);
	return y < dx;
}

bool vbar(float x, float y) {
	float dy = 1.4 - y;
	return x < dy;
}

void fragment() {
	const float v = 0.2;
	float x = UV.x * 7.0;
	float y = UV.y * 9.0;
	vec4 col = vec4(0.0, 0.0, 0.0, 1.0);
	if (a && y > 1.0 + v  && y < 2.0 - v && hbar(x, abs(y - 1.5))) {
		col = color;
	}
	if (g && y > 4.0 + v && y < 5.0 - v && hbar(x, abs(y - 4.5))) {
		col = color;
	}
	if (d && y > 7.0 + v && y < 8.0 - v && hbar(x, abs(y - 7.5))) {
		col = color;
	}
	if (x > 4.0 + v && x < 5.0 - v) {
		if (b && y > 1.5 && y < 4.5 && vbar(abs(x - 4.5), abs(y - 3.0))) {
			col = color;
		}
		if (c && y > 4.5 && y < 7.5 && vbar(abs(x - 4.5), abs(y - 6.0))) {
			col = color;
		}
	}
	if (x > 1.0 + v && x < 2.0 - v) {
		if (f && y > 1.5 && y < 4.5 && vbar(abs(x - 1.5), abs(y - 3.0))) {
			col = color;
		}
		if (e && y > 4.5 && y < 7.5 && vbar(abs(x - 1.5), abs(y - 6.0))) {
			col = color;
		}
	}
	if (dp && length(abs(vec2(x - 5.525, y - 7.5))) < 0.35) {
		col = color;
	}
	COLOR = col;
}
