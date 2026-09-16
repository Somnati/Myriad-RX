/// @description moon_draw(pn, mo, i, near, cx, cy, pr, cam, light_w) -> true when drawn: moon i of the world, one half at a time
/// THE MOONS IN THE ORBIT VIEW (the tech demo's __planet_moon, ported
/// 2026-09-15): each moon is a real mini world through sh_planet - a
/// shared cratered texture, no clouds, no relief, no ring, no atmosphere,
/// its own tidal-ish spin, the shared sun - so its phase, terminator and
/// pixel cells match the big one for free. near = true draws it only when
/// it is on the camera's side of the world (the world's quad occludes the
/// far ones: draw those first, the near ones after). The same weak
/// perspective as the ring (an eye six radii out): near moons swing wider
/// and draw bigger. It dims as it passes into the world's shadow. The
/// angle is advanced on the universal clock here.
function moon_draw(_pn, _mo, _i, _near, _cx, _cy, _pr, _cam, _light_w) {
	var _cfg = planet_config();
	var _tex = moon_tex();
	var _ang = (_mo.ang + _mo.spd * 60 * universal_now()) mod 360;
	var _om = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(1, 0, 0, _mo.incl));
	var _lw = mat3_apply(_om, dcos(_ang) * _mo.dist, 0, dsin(_ang) * _mo.dist);
	var _cti = mat3_transpose(_cam);
	var _mv = mat3_apply(_cti, _lw[0], _lw[1], _lw[2]);
	if ((_mv[2] >= 0) != _near) return false;
	var _k = 6 / max(6 - _mv[2], .5);
	var _mx = _cx + _mv[0] * _pr * _k;
	var _my = _cy + _mv[1] * _pr * _k;
	var _mq = max(1, _mo.size * _pr * 1.02 * _k);
	var _wm = mat3_rot(0, 1, 0, _ang * 2.5 + _i * 97);
	var _mm = mat3_mul(mat3_transpose(_wm), _cam);
	var _lv = is_array(_light_w) ? mat3_apply(_cti, _light_w[0], _light_w[1], _light_w[2]) : [-.55, -.5, .67];
	var _ll = max(.001, sqrt(_lv[0] * _lv[0] + _lv[1] * _lv[1] + _lv[2] * _lv[2]));
	_lv = [_lv[0] / _ll, _lv[1] / _ll, _lv[2] / _ll];
	// the world's shadow: dimmed as it passes behind the world, relative to the sun
	var _mcol = _mo.col;
	if (is_array(_light_w)) {
		var _alo = _lw[0] * _light_w[0] + _lw[1] * _light_w[1] + _lw[2] * _light_w[2];
		if (_alo < 0) {
			var _pp2 = (_lw[0] * _lw[0] + _lw[1] * _lw[1] + _lw[2] * _lw[2]) - _alo * _alo;
			var _ecl = clamp((1.08 - sqrt(max(0, _pp2))) / .18, 0, 1);
			if (_ecl > 0) _mcol = merge_colour(_mo.col, c_black, .8 * _ecl);
		}
	}
	static _u = undefined;
	if (is_undefined(_u)) _u = {
		rot : shader_get_uniform(sh_planet, "u_rot"), crot : shader_get_uniform(sh_planet, "u_crot"), light : shader_get_uniform(sh_planet, "u_light"),
		atmo : shader_get_uniform(sh_planet, "u_atmo"), tsize : shader_get_uniform(sh_planet, "u_tsize"), pad : shader_get_uniform(sh_planet, "u_pad"),
		time : shader_get_uniform(sh_planet, "u_time"), dither : shader_get_uniform(sh_planet, "u_dither"), cells : shader_get_uniform(sh_planet, "u_cells"),
		ring : shader_get_uniform(sh_planet, "u_ring"), raxis : shader_get_uniform(sh_planet, "u_raxis"), rcol : shader_get_uniform(sh_planet, "u_ringcol"),
		city : shader_get_uniform(sh_planet, "u_city"), cityn : shader_get_uniform(sh_planet, "u_cityn"), relief : shader_get_uniform(sh_planet, "u_relief"),
		cfade : shader_get_uniform(sh_planet, "u_cfade"), cloud : shader_get_sampler_index(sh_planet, "u_cloud"), height : shader_get_sampler_index(sh_planet, "u_height"),
	};
	// the quad on the pixel grid, like the world's
	var _q = _mq * 1.02, _qx = _mx - _q, _qy = _my - _q;
	if (_cfg.px_size > 0) { var _pxs = _cfg.px_size; _q = max(_pxs, round(_q / _pxs) * _pxs); _qx = round((_mx - _q) / _pxs) * _pxs; _qy = round((_my - _q) / _pxs) * _pxs; }
	shader_set(sh_planet);
	shader_set_uniform_f_array(_u.rot, _mm);
	shader_set_uniform_f_array(_u.crot, _mm);
	shader_set_uniform_f(_u.light, _lv[0], _lv[1], _lv[2]);
	shader_set_uniform_f(_u.atmo, 0, 0, 0);
	shader_set_uniform_f(_u.tsize, MOON_TEX_W, MOON_TEX_H);
	shader_set_uniform_f(_u.pad, 1.02);
	shader_set_uniform_f(_u.time, (current_time mod 100000) / 1000);
	shader_set_uniform_f(_u.cells, (_cfg.px_size > 0) ? (2 * _q) / _cfg.px_size : 0);
	shader_set_uniform_f(_u.ring, 0);
	shader_set_uniform_f(_u.raxis, 0, 1, 0);
	shader_set_uniform_f(_u.rcol, 0, 0, 0);
	shader_set_uniform_f(_u.relief, 0);
	shader_set_uniform_f(shader_get_uniform(sh_planet, "u_bump"), 0);
	shader_set_uniform_f(_u.cfade, 0);
	shader_set_uniform_f(_u.dither, (variable_global_exists("dither_off") && g.dither_off) ? 0 : 1);
	shader_set_uniform_f_array(_u.city, array_create(24, 0));
	shader_set_uniform_f(_u.cityn, 0);
	texture_set_stage(_u.cloud, surface_get_texture(_tex.c));
	texture_set_stage(_u.height, surface_get_texture(_tex.h));
	draw_surface_ext(_tex.t, _qx, _qy, (2 * _q) / MOON_TEX_W, (2 * _q) / MOON_TEX_H, 0, _mcol, 1);
	shader_reset();
	return true;
}
