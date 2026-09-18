/// @description galaxy_sky_holes(sky, cam, cx, cy, w, h, [sun], [occ]) - THE BLACK HOLES of a sky, drawn AFTER the fog: the neighbours' black dots and discs, and the system's own hole for a sun (hole_draw) - so the fog never lies over their black, and the lens bends the fog too
/// The same projection as galaxy_sky_draw's; the same marks (the near
/// hole a black disc with a soft halo and its disc's glow, the far one a
/// black dot); the sun's placement and its occluder fade are
/// galaxy_sky_draw's too. 2026-09-17, his ask: "make sure black holes
/// when viewed in the skybox draw in front of the galactic fog"
function galaxy_sky_holes(_sky, _cam, _cx, _cy, _w, _h, _sun = true, _occ = undefined) {
	var _ct = mat3_transpose(_cam);
	var _gw1 = max(1, sprite_get_width(spr_vis_glow_soft)), _gh1 = max(1, sprite_get_height(spr_vis_glow_soft));
	var _stars = _sky.stars;
	for (var _i = 0; _i < array_length(_stars); _i++) {
		var _sk = _stars[_i];
		if (!(_sk[$ "near"] ?? false) || (_sk[$ "skind"] ?? "main") != "hole") continue;
		var _dv = mat3_apply(_ct, _sk.x, _sk.y, _sk.z);
		if (_dv[2] > -.2) continue;
		var _f  = 230 / -_dv[2];
		var _sx = _cx + _dv[0] * _f, _sy = _cy + _dv[1] * _f;
		var _m = 12 + _sk.s * 4;
		if (_sx < -_m || _sx > _w + _m || _sy < -_m || _sy > _h + _m) continue;
		var _fade = clamp((min(_sx, _w - _sx) + _m) / _m, 0, 1) * clamp((min(_sy, _h - _sy) + _m) / _m, 0, 1) * clamp((-_dv[2] - .2) / .1, 0, 1);
		var _a = (.3 + .7 * _sk.b) * _fade;
		var _gx0 = floor(_sx), _gy0 = floor(_sy), _hr1 = _sk.s * .22;
		if (_hr1 < 1.6) { gpu_set_blendmode(bm_normal); draw_sprite_ext(spr_pixel_1x1, 0, _gx0, _gy0, 2, 2, 0, c_black, _a); }
		else {
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(spr_vis_glow_soft, 0, _gx0 + .5, _gy0 + .5, _hr1 * 6 / _gw1, _hr1 * 1.8 / _gh1, 18, _sk.col, .28 * _a);
			draw_sprite_ext(spr_vis_glow_soft, 0, _gx0 + .5, _gy0 + .5, _hr1 * 3.2 / _gw1, _hr1 * 3.2 / _gh1, 0, merge_colour(_sk.col, c_white, .4), .22 * _a);
			gpu_set_blendmode(bm_normal);
			draw_circle_colour(_gx0 + .5, _gy0 + .5, _hr1, c_black, c_black, false);
		}
	}
	gpu_set_blendmode(bm_normal);
	// the system's own hole for a sun: where the sun stands, faded as the sun is (behind the world, under a moon)
	if (_sun && (_sky[$ "hole"] ?? false)) {
		var _lw = _sky.light_w;
		var _sv = mat3_apply(_ct, _lw[0], _lw[1], _lw[2]);
		var _ss = _sky.sun_size / 12;
		if (_sv[2] < -.1) {
			var _sfade = clamp((-_sv[2] - .1) / .12, 0, 1), _sf = 230 / -_sv[2], _ssx = _cx + _sv[0] * _sf, _ssy = _cy + _sv[1] * _sf;
			if (is_struct(_occ) || is_array(_occ)) {
				var _ol = is_array(_occ) ? _occ : [_occ];
				for (var _oi = 0; _oi < array_length(_ol); _oi++) {
					var _o = _ol[_oi];
					var _od = point_distance(_ssx, _ssy, _o.x, _o.y);
					if ((_o[$ "kind"] ?? "world") == "moon") { var _rs = 5.5 * _ss; var _cov = clamp((_o.r + _rs - _od) / (2 * _rs), 0, 1); _sfade *= 1 - .92 * _cov; }
					else if (_od < _o.r) _sfade *= clamp((_od - _o.r * .55) / (_o.r * .45), 0, 1);
				}
			}
			if (_sfade > 0) hole_draw(_ssx, _ssy, 5.5 * _ss, _sky.sun_col, (_sky[$ "star"] ?? 0) * .37, _sfade, _cam);
		}
	}
}
