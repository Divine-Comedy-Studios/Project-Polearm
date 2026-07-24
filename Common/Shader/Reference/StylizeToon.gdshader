shader_type spatial;
render_mode cull_back, diffuse_lambert, specular_disabled;
// ============================================================
//  STYLIZED 3D MATERIAL (all-in-one reference)
//  Assign as ShaderMaterial / Material Override on meshes.
//  Handles the LIGHTING side: banded toon shading, hard shadows,
//  rim light, shanshui atmospheric depth.
//  Color / dither / palette live in the post-process instead.
// ============================================================
group_uniforms Surface;
// These carry the object's OWN colour through the toon shading instead of
// replacing it. Tools/ConvertToToonMaterial.gd fills them in automatically
// from each mesh's existing StandardMaterial3D.
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_tex : source_color;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform bool use_vertex_color = false;
group_uniforms;

group_uniforms ToonLighting;
uniform int light_bands : hint_range(1, 6) = 2;
uniform bool hard_shadows = true;
uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.5;
group_uniforms;

group_uniforms RimLight;
uniform bool enable_rim = true;
uniform vec4 rim_color : source_color = vec4(1.0, 0.95, 0.80, 1.0);
uniform float rim_power : hint_range(0.5, 8.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 2.0) = 0.6;
group_uniforms;

group_uniforms AtmosphereShanshui;
uniform bool enable_atmosphere = false;
uniform vec4 fog_color : source_color = vec4(0.94, 0.92, 0.85, 1.0);
uniform float fog_start : hint_range(0.0, 200.0) = 10.0;
uniform float fog_end : hint_range(0.0, 400.0) = 80.0;
uniform float fog_max : hint_range(0.0, 1.0) = 0.9;
group_uniforms;

void fragment() {
	vec2 uv = UV * uv_scale + uv_offset;
	vec3 base = albedo_color.rgb * texture(albedo_tex, uv).rgb;
	if (use_vertex_color) base *= COLOR.rgb;
	if (enable_atmosphere) {
		float dist = length(VERTEX);
		float f = smoothstep(fog_start, fog_end, dist) * fog_max;
		base = mix(base, fog_color.rgb, f);
		EMISSION += fog_color.rgb * f * 0.3;
	}
	ALBEDO = base;
	if (enable_rim) {
		float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
		EMISSION += rim_color.rgb * fres * rim_strength;
	}
}

void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float bands = float(light_bands);
	float banded = ceil(ndl * bands) / bands;
	float shadow = hard_shadows ? step(shadow_threshold, ATTENUATION) : ATTENUATION;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * banded * shadow;
}
