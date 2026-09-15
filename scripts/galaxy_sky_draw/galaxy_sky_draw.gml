/// @description galaxy_sky_draw(sky, cam, cx, cy, w, h, [sun]) - the sky's stars, siblings and sun into the current target
/// obj_planet_sky's draw: everything projects through the orbit camera
/// (cam = view -> world; its transpose takes world to view), the
/// projection sx = cx + vx x 230 / -vz (the sky is BEHIND the planet: a
/// direction with view z < 0 is away from the viewer). w / h = the
/// target's size for the cull. sun = draw the system's star (false on a
/// page that has no room for it).
function galaxy_sky_draw(_sky, _cam, _cx, _cy, _w, _h, _sun = true) {
	var _ct = mat3_transpose(_cam);
	draw_set_alpha(1);
	var _stars = _sky.stars;
	for (var _i = 0; _i < array_length(_stars); _i++) {
		var _sk = _stars[_i];
		var _dv = mat3_apply(_ct, _sk.x, _sk.y, _sk.z);
		if (_dv[2] > -.2) continue;
		var _f  = 230 / -_dv[2];
		var _sx = _cx + _dv[0] * _f, _sy = _cy + _dv[1] * _f;
		var _m = 12 + _sk.s * 4;
		if (_sx < -_m || _sx > _w + _m || _sy < -_m || _sy > _h + _m) continue;
		var _fade = clamp((min(_sx, _w - _sx) + _m) / _m, 0, 1) * clamp((min(_sy, _h - _sy) + _m) / _m, 0, 1) * clamp((-_dv[2] - .2) / .1, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _sx - _sk.s * .5, _sy - _sk.s * .5, max(1, _sk.s), max(1, _sk.s), 0, _sk.col, (.3 + .7 * _sk.b) * _fade);
	}
	for (var _i = 0; _i < array_length(_sky.sibs); _i++) {
		var _sb = _sky.sibs[_i];
		var _dv = mat3_apply(_ct, _sb.x, _sb.y, _sb.z);
		if (_dv[2] > -.2) continue;
		var _f  = 230 / -_dv[2];
		var _sx = _cx + _dv[0] * _f, _sy = _cy + _dv[1] * _f;
		if (_sx < -20 || _sx > _w + 20 || _sy < -20 || _sy > _h + 20) continue;
		var _fade = clamp((-_dv[2] - .2) / .1, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _sx - _sb.s * .5, _sy - _sb.s * .5, max(1, _sb.s), max(1, _sb.s), 0, merge_colour(_sb.col, c_white, .35), .95 * _fade);
	}
	if (_sun) {
		var _lw = _sky.light_w;
		var _sv = mat3_apply(_ct, _lw[0], _lw[1], _lw[2]);
		if (_sv[2] < -.1) {
			var _sfade = clamp((-_sv[2] - .1) / .12, 0, 1);
			var _sf  = 230 / -_sv[2];
			var _ssx = _cx + _sv[0] * _sf, _ssy = _cy + _sv[1] * _sf;
			var _ss = _sky.sun_size / 12;
			var _pu = 1 + .06 * dsin(current_time * .035);
			var _gs = (60 * _ss * _pu) / max(1, sprite_get_width(spr_vis_glow_soft));
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(spr_vis_glow_soft, 0, _ssx, _ssy, _gs, _gs, 0, _sky.sun_col, .3 * _sfade);
			gpu_set_blendmode(bm_normal);
			draw_sprite_ext(spr_star_glow, 5, _ssx, _ssy, 2.4 * _ss, 2.4 * _ss, 0, _sky.sun_col, .9 * _sfade);
			draw_sprite_ext(spr_star_glow, 5, _ssx, _ssy, 1.2 * _ss, 1.2 * _ss, 0, merge_colour(_sky.sun_col, c_white, .5), .9 * _sfade);
			draw_sprite_ext(spr_star_glow, 3, _ssx, _ssy, max(1, _ss * .9), max(1, _ss * .9), 0, c_white, _sfade);
		}
	}
}
