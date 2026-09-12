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
/// ⚖️ PAIR EVERY BIND WITH scene_light_unbind() AFTER THE DRAW (his
/// report, 2026-09-11: "interpolation on random UI elements"). The
/// per-stage filter this switches on is GPU state, not shader state -
/// it outlives shader_reset, and left on it is the filter for every
/// draw on that stage after. The unbind puts both stages back exactly
/// as they were.
function scene_light_bind(_st, _sw, _uuv, _uamt) {
	var _ok = instance_exists(syst_scene_light) && syst_scene_light.ready
	       && surface_exists(syst_scene_light.tight) && surface_exists(syst_scene_light.wide);
	var _amt = _ok ? clamp(g.scene_light, 0, 100) / 100 : 0;
	shader_set_uniform_f(_uamt, _amt);
	g.scene_light_bound = undefined;
	if (_amt <= 0) return;
	g.scene_light_bound = {
		st : _st, sw : _sw,
		f1 : gpu_get_tex_filter_ext(_st), r1 : gpu_get_tex_repeat_ext(_st),
		f2 : gpu_get_tex_filter_ext(_sw), r2 : gpu_get_tex_repeat_ext(_sw),
	};
	texture_set_stage(_st, surface_get_texture(syst_scene_light.tight));
	gpu_set_tex_filter_ext(_st, true);
	gpu_set_tex_repeat_ext(_st, false);
	texture_set_stage(_sw, surface_get_texture(syst_scene_light.wide));
	gpu_set_tex_filter_ext(_sw, true);
	gpu_set_tex_repeat_ext(_sw, false);
	shader_set_uniform_f(_uuv, 1 / room_width, 1 / room_height);
}

/// @description scene_light_unbind() - after the draw: the two stages'
/// filter and repeat back to what they were before the bind.
function scene_light_unbind() {
	if (!variable_global_exists("scene_light_bound")) return;
	var _b = g.scene_light_bound;
	if (_b == undefined) return;
	gpu_set_tex_filter_ext(_b.st, _b.f1);
	gpu_set_tex_repeat_ext(_b.st, _b.r1);
	gpu_set_tex_filter_ext(_b.sw, _b.f2);
	gpu_set_tex_repeat_ext(_b.sw, _b.r2);
	g.scene_light_bound = undefined;
}
