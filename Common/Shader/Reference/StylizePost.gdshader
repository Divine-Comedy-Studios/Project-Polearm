shader_type canvas_item;
// ============================================================
//  COMBINED STYLIZATION POST-PROCESS  (all-in-one reference)
//  Attach to a full-screen ColorRect under a CanvasLayer.
//  This is the monolithic version - handy for a quick test.
//  For modular / node-graph use, build a VisualShader from the
//  custom nodes in Common/Shader/Nodes instead.
//
//  Pipeline: sample(+chromatic) -> Kuwahara -> gradient map ->
//  palette -> quantize(+dither) -> halftone -> hatch -> outline
//  -> paper grain -> vignette
// ============================================================
// NOTE: Godot 4 fragment built-ins (FRAGCOORD, SCREEN_UV, SCREEN_PIXEL_SIZE) are NOT
// visible inside custom functions - only inside fragment(). Anything a helper needs
// must be passed in as a parameter. Uniforms and textureSize() are fine everywhere.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

// Godot 4 canvas_item has no SCREEN_PIXEL_SIZE built-in; derive it from the screen texture.
vec2 screen_px() { return 1.0 / vec2(textureSize(screen_texture, 0)); }

float bayer2(vec2 a) {
	a = floor(a);
	return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

float bayer4(vec2 a) {
	return bayer2(0.5 * a) * 0.25 + bayer2(a);
}

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

group_uniforms Textures;
// 0.0 = every input texture (ramp / palette / paper) is read as pure greyscale,
//       so a colourful texture is translated to its black-and-white values.
// 1.0 = the texture's own colours come through unchanged.
uniform float texture_color_amount : hint_range(0.0, 1.0) = 0.0;
group_uniforms;

// Reads a texture as tone. Colourful input -> greyscale, unless dialled back in.
vec3 as_tone(vec3 c) {
	return mix(vec3(luma(c)), c, texture_color_amount);
}

group_uniforms Sampling;
uniform bool enable_chromatic = false;
uniform vec2 chromatic_offset = vec2(1.5, 0.0);
group_uniforms;

group_uniforms Kuwahara;
uniform bool enable_kuwahara = false;
uniform int kuwahara_radius : hint_range(1, 6) = 3;
group_uniforms;

group_uniforms GradientMap;
uniform bool enable_gradient_map = false;
uniform sampler2D gradient_ramp : source_color;
uniform float gradient_mix : hint_range(0.0, 1.0) = 1.0;
group_uniforms;

group_uniforms Palette;
uniform bool enable_palette = false;
uniform sampler2D palette_tex : source_color, filter_nearest;
uniform int palette_size : hint_range(1, 64) = 6;
group_uniforms;

group_uniforms ColorDepth;
uniform bool enable_quantize = true;
uniform int color_levels : hint_range(2, 64) = 5;
uniform int dither_type : hint_range(0, 2) = 1;
uniform float dither_strength : hint_range(0.0, 1.0) = 1.0;
uniform float dither_pixel_size : hint_range(1.0, 12.0) = 2.0;
group_uniforms;

group_uniforms Halftone;
uniform bool enable_halftone = false;
uniform float halftone_scale : hint_range(2.0, 24.0) = 6.0;
uniform float halftone_angle : hint_range(0.0, 3.14159) = 0.6;
uniform vec4 halftone_ink : source_color = vec4(0.10, 0.10, 0.12, 1.0);
uniform vec4 halftone_paper : source_color = vec4(0.96, 0.94, 0.86, 1.0);
group_uniforms;

group_uniforms CrossHatch;
uniform bool enable_hatch = false;
uniform float hatch_scale : hint_range(2.0, 20.0) = 7.0;
uniform vec4 hatch_ink : source_color = vec4(0.12, 0.10, 0.10, 1.0);
uniform vec4 hatch_paper : source_color = vec4(0.95, 0.92, 0.84, 1.0);
group_uniforms;

group_uniforms Outline;
uniform bool enable_outline = false;
uniform float outline_width : hint_range(0.5, 4.0) = 1.2;
uniform float outline_threshold : hint_range(0.0, 1.0) = 0.25;
uniform vec4 outline_color : source_color = vec4(0.05, 0.05, 0.06, 1.0);
group_uniforms;

group_uniforms Paper;
uniform bool enable_paper = false;
uniform sampler2D paper_tex : hint_default_white, repeat_enable;
uniform float paper_scale : hint_range(0.5, 8.0) = 2.0;
uniform float paper_strength : hint_range(0.0, 1.0) = 0.5;
group_uniforms;

group_uniforms Vignette;
uniform bool enable_vignette = false;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.5;
uniform float vignette_radius : hint_range(0.1, 1.5) = 0.9;
group_uniforms;

vec3 sample_screen(vec2 uv) {
	if (enable_chromatic) {
		vec2 off = chromatic_offset * screen_px();
		float r = texture(screen_texture, uv + off).r;
		float g = texture(screen_texture, uv).g;
		float b = texture(screen_texture, uv - off).b;
		return vec3(r, g, b);
	}
	return texture(screen_texture, uv).rgb;
}

vec3 kuwahara(vec2 uv) {
	vec2 px = screen_px();
	float best = 1e9;
	vec3 out_c = texture(screen_texture, uv).rgb;
	for (int q = 0; q < 4; q++) {
		vec3 sum = vec3(0.0);
		vec3 sum2 = vec3(0.0);
		float n = 0.0;
		for (int j = 0; j <= 6; j++) {
			if (j > kuwahara_radius) break;
			for (int i = 0; i <= 6; i++) {
				if (i > kuwahara_radius) break;
				vec2 sq = vec2((q == 0 || q == 2) ? -1.0 : 1.0, (q < 2) ? -1.0 : 1.0);
				vec2 o = sq * vec2(float(i), float(j)) * px;
				vec3 c = texture(screen_texture, uv + o).rgb;
				sum += c;
				sum2 += c * c;
				n += 1.0;
			}
		}
		vec3 m = sum / n;
		vec3 v = sum2 / n - m * m;
		float variance = v.r + v.g + v.b;
		if (variance < best) { best = variance; out_c = m; }
	}
	return out_c;
}

vec3 gradient_map(vec3 c) {
	float l = luma(c);
	vec3 ramp = as_tone(texture(gradient_ramp, vec2(l, 0.5)).rgb);
	return mix(c, ramp, gradient_mix);
}

vec3 palette_map(vec3 c) {
	float best = 1e9;
	vec3 out_c = c;
	for (int i = 0; i < 64; i++) {
		if (i >= palette_size) break;
		vec3 p = as_tone(texture(palette_tex, vec2((float(i) + 0.5) / float(palette_size), 0.5)).rgb);
		float d = distance(c, p);
		if (d < best) { best = d; out_c = p; }
	}
	return out_c;
}

vec3 quantize(vec3 c, vec2 frag) {
	float levels = float(color_levels);
	float step_size = 1.0 / (levels - 1.0);
	float d = 0.0;
	if (dither_type == 1) {
		d = bayer4(floor(frag / dither_pixel_size)) - 0.5;
	} else if (dither_type == 2) {
		d = hash12(floor(frag / dither_pixel_size)) - 0.5;
	}
	c += d * step_size * dither_strength;
	c = round(c * (levels - 1.0)) / (levels - 1.0);
	return clamp(c, 0.0, 1.0);
}

vec3 halftone(vec3 c, vec2 frag) {
	float l = luma(c);
	float a = halftone_angle;
	mat2 rot = mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));
	vec2 cell = (rot * frag) / halftone_scale;
	vec2 f = fract(cell) - 0.5;
	float dist = length(f) * 2.0;
	float radius = sqrt(clamp(1.0 - l, 0.0, 1.0));
	float dot_mask = smoothstep(radius + 0.05, radius - 0.05, dist);
	return mix(halftone_paper.rgb, halftone_ink.rgb, dot_mask);
}

float hatch_line(vec2 p, float angle, float scale) {
	vec2 dir = vec2(cos(angle), sin(angle));
	float d = dot(p, dir);
	float t = abs(fract(d / scale) - 0.5) * 2.0;
	return 1.0 - smoothstep(0.15, 0.35, t);
}

vec3 cross_hatch(vec3 c, vec2 frag) {
	float l = luma(c);
	vec2 p = frag;
	float s = hatch_scale;
	float ink = 0.0;
	if (l < 0.90) ink = max(ink, hatch_line(p,  0.4, s));
	if (l < 0.65) ink = max(ink, hatch_line(p, -0.4, s));
	if (l < 0.40) ink = max(ink, hatch_line(p,  1.2, s));
	if (l < 0.20) ink = max(ink, hatch_line(p, -1.2, s));
	return mix(hatch_paper.rgb, hatch_ink.rgb, ink);
}

float sobel_edge(vec2 uv) {
	vec2 px = screen_px() * outline_width;
	float l00 = luma(sample_screen(uv + px * vec2(-1.0, -1.0)));
	float l10 = luma(sample_screen(uv + px * vec2( 0.0, -1.0)));
	float l20 = luma(sample_screen(uv + px * vec2( 1.0, -1.0)));
	float l01 = luma(sample_screen(uv + px * vec2(-1.0,  0.0)));
	float l21 = luma(sample_screen(uv + px * vec2( 1.0,  0.0)));
	float l02 = luma(sample_screen(uv + px * vec2(-1.0,  1.0)));
	float l12 = luma(sample_screen(uv + px * vec2( 0.0,  1.0)));
	float l22 = luma(sample_screen(uv + px * vec2( 1.0,  1.0)));
	float gx = -l00 - 2.0 * l01 - l02 + l20 + 2.0 * l21 + l22;
	float gy = -l00 - 2.0 * l10 - l20 + l02 + 2.0 * l12 + l22;
	return length(vec2(gx, gy));
}

vec3 apply_paper(vec3 c, vec2 uv) {
	vec3 paper = as_tone(texture(paper_tex, uv * paper_scale).rgb);
	return mix(c, c * paper, paper_strength);
}

vec3 apply_vignette(vec3 c, vec2 uv) {
	float d = distance(uv, vec2(0.5));
	float v = smoothstep(vignette_radius, vignette_radius - 0.4, d);
	return c * mix(1.0, v, vignette_strength);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 col = enable_kuwahara ? kuwahara(uv) : sample_screen(uv);
	if (enable_gradient_map) col = gradient_map(col);
	if (enable_palette)      col = palette_map(col);
	if (enable_quantize)     col = quantize(col, FRAGCOORD.xy);
	if (enable_halftone)     col = halftone(col, FRAGCOORD.xy);
	if (enable_hatch)        col = cross_hatch(col, FRAGCOORD.xy);
	if (enable_outline) {
		float e = sobel_edge(uv);
		float m = smoothstep(outline_threshold, outline_threshold + 0.1, e);
		col = mix(col, outline_color.rgb, m);
	}
	if (enable_paper)    col = apply_paper(col, uv);
	if (enable_vignette) col = apply_vignette(col, uv);
	COLOR = vec4(col, 1.0);
}
