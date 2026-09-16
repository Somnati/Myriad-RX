/// @description station_draw(pn, st, near, cx, cy, pr, cam, light_w) - a world's station and ITS ORBIT RING, the far half or the near half (moon_draw's split)
/// The ring (his ask, 2026-09-16: "its own orbit ring around the planet"):
/// the orbit as pixel dots on the plane it lies in (the world's tilt, the
/// station's lean), the half behind the world dim and drawn before it, the
/// half in front brighter and after. The station: sh_station on a quad
/// where it stands on that ring now (the universal clock), its own spin,
/// lit by the sun through the camera, the moons' weak perspective.
function station_draw(_pn, _st, _near, _cx, _cy, _pr, _cam, _light_w) {
	static _u = undefined;
	if (is_undefined(_u)) _u = {
		quad : shader_get_uniform(sh_station, "u_quad"), orr : shader_get_uniform(sh_station, "u_or"), light : shader_get_uniform(sh_station, "u_light"),
		col : shader_get_uniform(sh_station, "u_col"), glow : shader_get_uniform(sh_station, "u_glow"), pad : shader_get_uniform(sh_station, "u_pad"),
		style : shader_get_uniform(sh_station, "u_style"), prm : shader_get_uniform(sh_station, "u_prm"), seed : shader_get_uniform(sh_station, "u_seed"),
	};
	if (!is_struct(_st)) return;
	var _now = universal_now();
	var _om = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(1, 0, 0, _st.incl));
	var _cti = mat3_transpose(_cam);
	// THE RING: dots round the orbit, this half only
	var _nd = 96;
	for (var _i = 0; _i < _nd; _i++) {
		var _a = _i * 360 / _nd;
		var _pw = mat3_apply(_om, dcos(_a) * _st.dist, 0, dsin(_a) * _st.dist);
		var _pv = mat3_apply(_cti, _pw[0], _pw[1], _pw[2]);
		if ((_pv[2] >= 0) != _near) continue;
		var _k = 6 / max(6 - _pv[2], .5);
		draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx + _pv[0] * _pr * _k), floor(_cy + _pv[1] * _pr * _k), 1, 1, 0, c_steelblue, _near ? .55 : .22);
	}
	// THE STATION on it
	var _ang = (_st.ang + _st.spd * 60 * _now) mod 360;
	var _lw = mat3_apply(_om, dcos(_ang) * _st.dist, 0, dsin(_ang) * _st.dist);
	var _mv = mat3_apply(_cti, _lw[0], _lw[1], _lw[2]);
	if ((_mv[2] >= 0) != _near) return;
	var _k2 = 6 / max(6 - _mv[2], .5);
	var _sx = _cx + _mv[0] * _pr * _k2, _sy = _cy + _mv[1] * _pr * _k2;
	var _hq = max(3, _st.size * _pr * _k2 * 1.15);   // (the quad's half-extent: the station fits a unit sphere, a little room round it)
	if (!shader_is_compiled(sh_station)) { draw_sprite_ext(spr_pixel_1x1, 0, _sx - 2, _sy - 2, 4, 4, 0, _st.hull, 1); return; }
	// its orientation: the station's own spin about the world's axis, seen through the camera (moon_draw's frame)
	var _wm = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, (_now * 60 * _st.spin) mod 360));
	var _mm = mat3_mul(mat3_transpose(_wm), _cam);
	var _lv = is_array(_light_w) ? mat3_apply(_cti, _light_w[0], _light_w[1], _light_w[2]) : [-.55, -.5, .67];
	var _ll = max(.001, sqrt(_lv[0] * _lv[0] + _lv[1] * _lv[1] + _lv[2] * _lv[2]));
	shader_set(sh_station);
	shader_set_uniform_f(_u.quad, _sx - _hq, _sy - _hq, _hq * 2, _hq * 2);
	shader_set_uniform_f_array(_u.orr, _mm);
	shader_set_uniform_f(_u.light, _lv[0] / _ll, _lv[1] / _ll, _lv[2] / _ll);
	shader_set_uniform_f(_u.col, colour_get_red(_st.hull) / 255, colour_get_green(_st.hull) / 255, colour_get_blue(_st.hull) / 255);
	shader_set_uniform_f(_u.glow, colour_get_red(_st.glow) / 255, colour_get_green(_st.glow) / 255, colour_get_blue(_st.glow) / 255);
	shader_set_uniform_f(_u.pad, 1.15);
	shader_set_uniform_f(_u.style, _st.style);
	shader_set_uniform_f_array(_u.prm, _st.prm);
	shader_set_uniform_f(_u.seed, _st.sseed);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx - _hq, _sy - _hq, _hq * 2, _hq * 2, 0, c_white, 1);
	shader_reset();
}
