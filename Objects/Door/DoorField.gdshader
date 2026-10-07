shader_type spatial;
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, shadows_disabled;

uniform vec4 field_color : source_color = vec4(0.2, 0.7, 1.0, 1.0);
uniform float intensity = 2.0;
// 0 = field gone, 1 = field fully up. Animated by Door.gd
uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform vec2 field_size = vec2(3.0, 4.0);
uniform float hex_per_meter = 2.5;
uniform float scroll_speed = 0.6;


float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
		f.y);
}

float hexDist(vec2 p) {
	p = abs(p);
	return max(dot(p, vec2(0.5, 0.866025)), p.x);
}

// xy = position inside the hex cell, zw = id of the cell
vec4 hexCoords(vec2 uv) {
	vec2 r = vec2(1.0, 1.732);
	vec2 h = r * 0.5;
	vec2 a = mod(uv, r) - h;
	vec2 b = mod(uv - h, r) - h;
	vec2 gv = dot(a, a) < dot(b, b) ? a : b;
	return vec4(gv, uv - gv);
}


void fragment() {
	vec2 meters = UV * field_size;
	float height01 = 1.0 - UV.y; // 0 at the floor, 1 at the top

	// Hex grid with single cells that flicker
	vec4 hc = hexCoords(meters * hex_per_meter);
	float edge = 0.5 - hexDist(hc.xy);
	float gridLine = 1.0 - smoothstep(0.0, 0.07, edge);
	float cellPulse = pow(0.5 + 0.5 * sin(TIME * 2.0 + hash(hc.zw) * 6.2831), 6.0);
	float cells = cellPulse * 0.35;

	// Scrolling energy band and fine scanlines
	float band = pow(0.5 + 0.5 * sin((height01 * 2.0 - TIME * scroll_speed) * 6.2831), 8.0);
	float scan = 0.85 + 0.15 * sin(meters.y * 40.0 - TIME * 6.0);

	// Bright border around the whole door
	float borderDist = min(min(meters.x, field_size.x - meters.x), min(meters.y, field_size.y - meters.y));
	float border = 1.0 - smoothstep(0.0, 0.12, borderDist);

	// Brighter when seen at a grazing angle
	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.0);

	// Dissolve from the floor upwards with a glowing rim
	float n = vnoise(meters * 4.0 + vec2(0.0, TIME * 0.3));
	float v = height01 + n * 0.2;
	float t = progress * 1.3;
	float visible = step(v, t);
	float rim = step(t - 0.06, v) * visible;

	float glow = 0.18 + gridLine * 0.5 + cells + band * 0.35 + border * 0.9 + fres * 0.4;
	glow *= scan;
	glow += rim * 1.5;

	float flicker = 0.93 + 0.07 * sin(TIME * 23.0) * sin(TIME * 7.0);

	ALBEDO = field_color.rgb * intensity * glow * flicker;
	ALPHA = clamp(glow, 0.0, 1.0) * visible * field_color.a;
}
