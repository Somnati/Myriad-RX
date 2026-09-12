/// @description scene_light_bind(s_tight, s_wide, u_uv, u_amt) - hand
/// syst_scene_light's two textures to a shader that is already SET
/// (sh_dice / sh_puck / sh_blob), with the room-px -> uv scale and the
/// strength. Off (no capture this frame, the setting at 0, another
/// room) it sets the strength to 0 and binds nothing - the shaders
/// multiply their reads by the strength, so an unbound sampler is
/// harmless.
/// @param s_tight   shader_get_sampler_index(sh, "u_scene")
/// @param s_wide    shader_get_sampler_index(sh, "u_scene2")
/// @param u_uv      shader_get_uniform(sh, "u_scene_uv")
/// @param u_amt     shader_get_uniform(sh, "u_scene_amt")
function scene_light_bind(_st, _sw, _uuv, _uamt) {
	var _ok = instance_exists(syst_scene_light) && syst_scene_light.ready
	       && surface_exists(syst_scene_light.tight) && surface_exists(syst_scene_light.wide);
	var _amt = _ok ? clamp(g.scene_light, 0, 100) / 100 : 0;
	shader_set_uniform_f(_uamt, _amt);
	if (_amt <= 0) return;
	texture_set_stage(_st, surface_get_texture(syst_scene_light.tight));
	gpu_set_tex_filter_ext(_st, true);
	gpu_set_tex_repeat_ext(_st, false);
	texture_set_stage(_sw, surface_get_texture(syst_scene_light.wide));
	gpu_set_tex_filter_ext(_sw, true);
	gpu_set_tex_repeat_ext(_sw, false);
	shader_set_uniform_f(_uuv, 1 / room_width, 1 / room_height);
}
