shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled, cull_disabled, shadows_disabled;
// ============================================================
//  STYLIZED INDUSTRIAL POST-PROCESS  (full-screen quad)
//  Put PostQuad.tscn under your camera. It reads the colour, the depth and the
//  normal buffer, so outlines follow SHAPES instead of texture noise.
//
//  IMPORTANT: the quad must render BEFORE transparent objects (render_priority = -1,
//  already set in PostQuad.tscn). A higher priority would paint over doors, water,
//  particles and everything else that is transparent.
//  Transparent objects are therefore not outlined or graded. Fog and colour grading are
//  better done in the Environment, where they apply to everything.
//
//  Order: fog -> outline -> colour grade -> quantize -> vignette
// ============================================================

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_tex : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_tex : hint_normal_roughness_texture, repeat_disable, filter_nearest;

group_uniforms Fog;
uniform bool enable_fog = false; // Prefer the Environment's own fog: it also covers transparent objects
uniform vec4 fog_color : source_color = vec4(0.62, 0.78, 0.86, 1.0);
uniform float fog_start : hint_range(0.0, 200.0) = 10.0;
uniform float fog_end : hint_range(1.0, 400.0) = 70.0;
uniform float fog_max : hint_range(0.0, 1.0) = 0.75;
uniform float fog_height_weight : hint_range(0.0, 1.0) = 0.5; // 0 = distance only, 1 = mostly low-lying
uniform float fog_floor_y = 0.0;
uniform float fog_height_falloff : hint_range(0.0, 2.0) = 0.15;
group_uniforms;

group_uniforms Outline;
uniform bool enable_outline = true;
uniform float outline_width : hint_range(0.5, 4.0) = 1.2;
uniform vec4 outline_color : source_color = vec4(0.05, 0.09, 0.16, 1.0);
uniform float outline_scene_blend : hint_range(0.0, 1.0) = 0.4; // 1 = line is a darkened version of the scene colour
uniform float depth_threshold : hint_range(0.001, 0.5) = 0.05;
uniform float slope_compensation : hint_range(0.0, 1.0) = 0.9;
uniform float normal_threshold : hint_range(0.0, 2.0) = 0.6;
uniform float normal_weight : hint_range(0.0, 1.0) = 1.0;
uniform float outline_fade_start : hint_range(0.0, 400.0) = 40.0;
uniform float outline_fade_end : hint_range(1.0, 600.0) = 120.0;
group_uniforms;

group_uniforms ColorGrade;
uniform bool enable_grade = false; // Prefer the Environment's adjustments: they also cover transparent objects
uniform float exposure : hint_range(0.2, 3.0) = 1.0;
uniform float grade_saturation : hint_range(0.0, 2.0) = 1.15;
uniform float grade_contrast : hint_range(0.5, 1.8) = 1.08;
uniform vec4 shadow_tint : source_color = vec4(0.05, 0.10, 0.22, 1.0);    // added to dark areas
uniform vec4 highlight_tint : source_color = vec4(0.16, 0.10, 0.02, 1.0); // added to bright areas
uniform float split_strength : hint_range(0.0, 1.0) = 0.35;
group_uniforms;

group_uniforms ColorDepth;
uniform bool enable_quantize = false;
uniform int color_levels : hint_range(2, 64) = 24;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.6;
uniform float dither_pixel_size : hint_range(1.0, 8.0) = 1.0;
group_uniforms;

group_uniforms Vignette;
uniform bool enable_vignette = false;
uniform float vignette_strength : hint_range(0.0, 1.5) = 0.35;
uniform float vignette_radius : hint_range(0.2, 1.5) = 0.95;
group_uniforms;


float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

vec3 view_pos_from_depth(vec2 uv, float depth, mat4 inv_proj) {
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
	vec4 v = inv_proj * vec4(ndc, 1.0);
	return v.xyz / v.w;
}

float lin_depth(vec2 uv, mat4 inv_proj) {
	return -view_pos_from_depth(uv, texture(depth_tex, uv).r, inv_proj).z;
}

vec3 normal_at(vec2 uv) {
	return texture(normal_tex, uv).xyz * 2.0 - 1.0;
}

float bayer2(vec2 a) {
	a = floor(a);
	return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

float bayer4(vec2 a) {
	return bayer2(0.5 * a) * 0.25 + bayer2(a);
}


void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = 1.0 / VIEWPORT_SIZE;

	vec3 col = texture(screen_tex, uv).rgb;
	float depth0 = texture(depth_tex, uv).r;
	vec3 vpos = view_pos_from_depth(uv, depth0, INV_PROJECTION_MATRIX);
	float lin = -vpos.z;
	bool is_sky = depth0 < 0.00001;

	// ---- fog -----------------------------------------------------------
	if (enable_fog && !is_sky) {
		float dist = length(vpos);
		float f_dist = smoothstep(fog_start, fog_end, dist);
		vec3 wpos = (INV_VIEW_MATRIX * vec4(vpos, 1.0)).xyz;
		float f_height = exp(-max(wpos.y - fog_floor_y, 0.0) * fog_height_falloff);
		float f = f_dist * mix(1.0, f_height, fog_height_weight) * fog_max;
		col = mix(col, fog_color.rgb, f);
	}

	// ---- outline from depth + normals ----------------------------------
	if (enable_outline) {
		vec2 o = px * outline_width;
		float dl = lin_depth(uv + vec2(-o.x, 0.0), INV_PROJECTION_MATRIX);
		float dr = lin_depth(uv + vec2( o.x, 0.0), INV_PROJECTION_MATRIX);
		float du = lin_depth(uv + vec2(0.0, -o.y), INV_PROJECTION_MATRIX);
		float dd = lin_depth(uv + vec2(0.0,  o.y), INV_PROJECTION_MATRIX);

		vec3 n = normal_at(uv);
		float facing = clamp(abs(n.z), 0.05, 1.0);

		float d_edge = (abs(dl - lin) + abs(dr - lin) + abs(du - lin) + abs(dd - lin)) / max(lin, 0.001);
		d_edge *= mix(1.0, facing, slope_compensation);
		float depth_mask = smoothstep(depth_threshold, depth_threshold * 1.6, d_edge);

		float n_edge = length(normal_at(uv + vec2(-o.x, 0.0)) - n)
			+ length(normal_at(uv + vec2( o.x, 0.0)) - n)
			+ length(normal_at(uv + vec2(0.0, -o.y)) - n)
			+ length(normal_at(uv + vec2(0.0,  o.y)) - n);
		float normal_mask = smoothstep(normal_threshold, normal_threshold + 0.5, n_edge) * normal_weight;

		float edge = max(depth_mask, normal_mask);

		float nearest = min(min(dl, dr), min(min(du, dd), lin));
		edge *= 1.0 - smoothstep(outline_fade_start, outline_fade_end, nearest);

		vec3 line_col = mix(outline_color.rgb, col * outline_color.rgb * 3.0, outline_scene_blend);
		col = mix(col, line_col, edge * outline_color.a);
	}

	// ---- work in a perceptual space for grading ------------------------
	col = pow(max(col, vec3(0.0)), vec3(1.0 / 2.2));

	if (enable_grade) {
		col *= exposure;
		float l = luma(col);
		col = mix(vec3(l), col, grade_saturation);
		col = (col - 0.5) * grade_contrast + 0.5;
		float l2 = clamp(luma(col), 0.0, 1.0);
		col += mix(shadow_tint.rgb, highlight_tint.rgb, l2) * split_strength;
		col = max(col, vec3(0.0));
	}

	if (enable_quantize) {
		float levels = float(color_levels);
		float step_size = 1.0 / (levels - 1.0);
		float dth = bayer4(floor(FRAGCOORD.xy / dither_pixel_size)) - 0.5;
		col += dth * step_size * dither_strength;
		col = clamp(round(col * (levels - 1.0)) / (levels - 1.0), 0.0, 1.0);
	}

	if (enable_vignette) {
		float d = distance(uv, vec2(0.5));
		float v = smoothstep(vignette_radius, vignette_radius - 0.45, d);
		col *= mix(1.0, v, vignette_strength);
	}

	ALBEDO = pow(max(col, vec3(0.0)), vec3(2.2));
}

void vertex() {
	// Cover the whole screen no matter where the quad sits.
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}
