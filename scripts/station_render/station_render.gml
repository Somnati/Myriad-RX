/// @description station_render(st, sx, sy, r, cam, light_w, [spin_deg]) - THE STATION on a quad: sh_station
/// raymarches its solid (the shape, its proportions) per pixel, orthographic
/// rays; u_or maps view space onto the station's object space (its lean,
/// its spin, the camera); the light comes in world space and is turned
/// through the camera. r = the station's radius on the page in px (it fits
/// a unit sphere; the quad is a little larger). Used by the system view
/// (small, on its ring) and the station page (large, in the middle).
function station_render(_st, _sx, _sy, _r, _cam, _light_w, _spin = undefined) {
	static _u = undefined;
	if (is_undefined(_u)) _u = {
		quad : shader_get_uniform(sh_station, "u_quad"), orr : shader_get_uniform(sh_station, "u_or"), light : shader_get_uniform(sh_station, "u_light"),
		col : shader_get_uniform(sh_station, "u_col"), glow : shader_get_uniform(sh_station, "u_glow"), pad : shader_get_uniform(sh_station, "u_pad"),
		style : shader_get_uniform(sh_station, "u_style"), prm : shader_get_uniform(sh_station, "u_prm"), seed : shader_get_uniform(sh_station, "u_seed"),
	};
	var _hq = max(3, _r * 1.15);
	if (!shader_is_compiled(sh_station)) { draw_sprite_ext(spr_pixel_1x1, 0, _sx - 2, _sy - 2, 4, 4, 0, _st.hull, 1); return; }
	if (is_undefined(_spin)) _spin = (universal_now() * 60 * _st.spin) mod 360;
	// its orientation: the lean of its axis, its spin about it, seen through the camera
	var _wm = mat3_mul(mat3_rot(0, 0, 1, _st.lean), mat3_rot(0, 1, 0, _spin));
	var _mm = mat3_mul(mat3_transpose(_wm), _cam);
	var _cti = mat3_transpose(_cam);
	var _lv = is_array(_light_w) ? mat3_apply(_cti, _light_w[0], _light_w[1], _light_w[2]) : [-.55, -.5, .67];
	var _ll = max(.001, sqrt(_lv[0] * _lv[0] + _lv[1] * _lv[1] + _lv[2] * _lv[2]));
	shader_set(sh_station);
	shader_set_uniform_f(_u.quad, _sx - _hq, _sy - _hq, _hq * 2, _hq * 2);
	shader_set_uniform_f_array(_u.orr, _mm);
	shader_set_uniform_f(_u.light, _lv[0] / _ll, _lv[1] / _ll, _lv[2] / _ll);
	shader_set_uniform_f(_u.col, colour_get_red(_st.hull) / 255, colour_get_green(_st.hull) / 255, colour_get_blue(_st.hull) / 255);
	shader_set_uniform_f(_u.glow, colour_get_red(_st.glow) / 255, colour_get_green(_st.glow) / 255, colour_get_blue(_st.glow) / 255);
	shader_set_uniform_f(_u.pad, 1.15);
	shader_set_uniform_f(_u.style, _st.shape);
	shader_set_uniform_f_array(_u.prm, _st.prm);
	shader_set_uniform_f(_u.seed, _st.sseed);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx - _hq, _sy - _hq, _hq * 2, _hq * 2, 0, c_white, 1);
	shader_reset();
}
