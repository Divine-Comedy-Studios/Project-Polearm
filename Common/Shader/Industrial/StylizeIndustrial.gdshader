shader_type spatial;
render_mode cull_back, diffuse_lambert;
// ============================================================
//  STYLIZED INDUSTRIAL MATERIAL
//  Replaces StylizeToon for the lab / factory look.
//  - flattens photographic (Poly Haven) textures into clean colour blocks
//  - banded cel lighting with coloured (cool) shadows
//  - hard stylized highlight for metal, optional rim and emission
//  Outlines, fog and colour grading live in StylizeIndustrialPost.
//  Keeps the parameter names of StylizeToon, so existing conversions still work.
// ============================================================

varying vec3 v_world_pos;
varying vec3 v_world_normal;

group_uniforms Surface;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform bool use_vertex_color = false;
group_uniforms;

group_uniforms Triplanar;
// World-space texturing: no UV stretching, no seams between blocks.
uniform bool use_triplanar = false;
uniform float triplanar_size = 2.0; // meters per texture tile
uniform float triplanar_sharpness : hint_range(1.0, 16.0) = 6.0;
group_uniforms;

group_uniforms Flatten;
// Turns detailed photo textures into calm colour areas.
uniform float detail_flatten : hint_range(0.0, 1.0) = 0.7;
uniform float flatten_lod : hint_range(0.0, 8.0) = 3.5;
uniform float contrast : hint_range(0.0, 2.0) = 0.6;
uniform float saturation : hint_range(0.0, 2.0) = 1.1;
uniform float brightness : hint_range(0.2, 2.5) = 1.0;
uniform float posterize_levels : hint_range(0.0, 12.0) = 0.0; // 0 = off. Painted colour plateaus; works best together with a strong detail_flatten.
uniform float posterize_softness : hint_range(0.0, 0.5) = 0.3;
uniform vec4 tint_color : source_color = vec4(0.45, 0.75, 0.80, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.0; // recolours the material to tint_color, keeps its light/dark structure
group_uniforms;

group_uniforms ToonLighting;
uniform int light_bands : hint_range(1, 6) = 3;
uniform float band_softness : hint_range(0.0, 0.3) = 0.04;
uniform float light_wrap : hint_range(0.0, 1.0) = 0.2;
uniform float light_strength : hint_range(0.0, 3.0) = 1.0;
uniform bool hard_shadows = true; // directional light only
uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.5;
uniform vec4 shadow_color : source_color = vec4(0.52, 0.58, 0.85, 1.0);
uniform float shadow_fill : hint_range(0.0, 1.0) = 0.30; // on top of the environment's ambient light
group_uniforms;

group_uniforms Metal;
uniform float metal_amount : hint_range(0.0, 1.0) = 0.0;
uniform float spec_power : hint_range(2.0, 200.0) = 40.0;
uniform float spec_threshold : hint_range(0.0, 1.0) = 0.55;
uniform float spec_strength : hint_range(0.0, 4.0) = 1.5;
group_uniforms;

group_uniforms RimLight;
uniform bool enable_rim = false;
uniform vec4 rim_color : source_color = vec4(0.75, 0.95, 1.0, 1.0);
uniform float rim_power : hint_range(0.5, 8.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 2.0) = 0.5;
uniform float rim_softness : hint_range(0.0, 1.0) = 0.15; // 0 = hard graphic edge
group_uniforms;

group_uniforms Emission;
uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_energy : hint_range(0.0, 16.0) = 2.0;
group_uniforms;


float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

vec3 sample_albedo(vec2 uv, bool blurred, float lod, vec3 wpos, vec3 wnormal) {
	if (use_triplanar) {
		vec3 w = pow(abs(wnormal), vec3(triplanar_sharpness));
		w /= (w.x + w.y + w.z + 0.0001);
		vec3 p = wpos / triplanar_size;
		vec3 cx; vec3 cy; vec3 cz;
		if (blurred) {
			cx = textureLod(albedo_tex, p.zy, lod).rgb;
			cy = textureLod(albedo_tex, p.xz, lod).rgb;
			cz = textureLod(albedo_tex, p.xy, lod).rgb;
		} else {
			cx = texture(albedo_tex, p.zy).rgb;
			cy = texture(albedo_tex, p.xz).rgb;
			cz = texture(albedo_tex, p.xy).rgb;
		}
		return cx * w.x + cy * w.y + cz * w.z;
	}
	if (blurred) {
		return textureLod(albedo_tex, uv, lod).rgb;
	}
	return texture(albedo_tex, uv).rgb;
}


void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 uv = UV * uv_scale + uv_offset;

	// --- simplify the texture -------------------------------------------
	vec3 sharp_c = sample_albedo(uv, false, 0.0, v_world_pos, v_world_normal);
	vec3 soft_c = sample_albedo(uv, true, flatten_lod, v_world_pos, v_world_normal);
	vec3 c = mix(sharp_c, soft_c, detail_flatten);

	vec3 avg = textureLod(albedo_tex, vec2(0.5), 12.0).rgb; // average colour of the whole texture
	c = (c - avg) * contrast + avg;
	c = max(c, vec3(0.0));

	float l = luma(c);
	c = mix(vec3(l), c, saturation);

	if (posterize_levels >= 2.0) {
		// Soft plateaus: flat areas of colour with gentle transitions, like a painted surface.
		float x = l * posterize_levels;
		float lq = (floor(x) + smoothstep(0.5 - posterize_softness, 0.5 + posterize_softness, fract(x))) / posterize_levels;
		c *= max(lq, 0.02) / max(l, 0.02);
		l = lq;
	}

	// Recolour: the average of the texture becomes exactly tint_color, detail stays as light/dark variation.
	float rel = clamp(l / max(luma(avg), 0.05), 0.35, 1.8);
	vec3 tinted = tint_color.rgb * rel;
	c = mix(c, tinted, tint_amount);
	c *= brightness;

	vec3 base = albedo_color.rgb * c;
	if (use_vertex_color) base *= COLOR.rgb;

	ALBEDO = base;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	SPECULAR = 0.0;

	// Cool shadow colour: a constant fill that the lit side adds light on top of.
	EMISSION += base * shadow_color.rgb * shadow_fill;

	EMISSION += emission_color.rgb * emission_energy;
}

void light() {
	float ndl = dot(NORMAL, LIGHT);
	float x = clamp((ndl + light_wrap) / (1.0 + light_wrap), 0.0, 1.0);

	float banded = 0.0;
	float bands = float(light_bands);
	for (int k = 0; k < 6; k++) {
		if (k >= light_bands) break;
		float t = float(k) / bands + 0.02;
		banded += smoothstep(t - band_softness, t + band_softness, x);
	}
	banded /= bands;

	float att = ATTENUATION;
	if (LIGHT_IS_DIRECTIONAL && hard_shadows) {
		att = smoothstep(shadow_threshold - 0.02, shadow_threshold + 0.02, ATTENUATION);
	}

	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * banded * att * light_strength / PI;

	if (enable_rim) {
		// Rim only where the light actually hits, so grazing floors don't glow.
		float fres = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
		float rim = smoothstep(0.5 - rim_softness * 0.5, 0.5 + rim_softness * 0.5 + 0.001, pow(fres, rim_power));
		float lit = smoothstep(0.1, 0.5, dot(NORMAL, LIGHT)) * att;
		DIFFUSE_LIGHT += rim_color.rgb * rim * lit * rim_strength * LIGHT_COLOR / PI;
	}

	if (metal_amount > 0.0) {
		vec3 h = normalize(VIEW + LIGHT);
		float s = pow(clamp(dot(NORMAL, h), 0.0, 1.0), spec_power);
		s = smoothstep(spec_threshold - 0.03, spec_threshold + 0.03, s);
		SPECULAR_LIGHT += LIGHT_COLOR * s * metal_amount * spec_strength * att / PI;
	}
}
