/// @description galaxy_sky_holes(sky, cam, cx, cy, w, h, [sun], [occ]) - THE BLACK HOLES of a sky, drawn AFTER the fog: the neighbours (frozen renders, each along its own line of sight, sized by distance) and the system's own hole for a sun (hole_draw, live) - so the fog never lies over their black, and the lens bends the fog too
/// The same projection as galaxy_sky_draw's; the same marks (the near
/// hole a black disc with a soft halo and its disc's glow, the far one a
/// black dot); the sun's placement and its occluder fade are
/// galaxy_sky_draw's too. 2026-09-17, his ask: "make sure black holes
/// when viewed in the skybox draw in front of the galactic fog"
function galaxy_sky_holes(_sky, _cam, _cx, _cy, _w, _h, _sun = true, _occ = undefined) {
	var _ct = mat3_transpose(_cam);
	var _stars = _sky.stars;
	if (!variable_struct_exists(_sky, "hbake")) _sky.hbake = {};   // THE FROZEN RENDERS (q196), by neighbour index: { surf, qw, up }
	if (!variable_struct_exists(_sky, "hidx")) {   // (the holes' indices, found once - the pass walked two thousand stars a frame for a handful; bug hunt 2026-09-18)
		_sky.hidx = [];
		for (var _j = 0; _j < array_length(_stars); _j++) { var _sj = _stars[_j]; if ((_sj[$ "near"] ?? false) && (_sj[$ "skind"] ?? "main") == "hole") array_push(_sky.hidx, _j); }
	}
	var _pg = surface_get_target(), _pg_ok = (_pg >= 0 && surface_exists(_pg));
	var _pw = _pg_ok ? surface_get_width(_pg) : _w, _ph = _pg_ok ? surface_get_height(_pg) : _h;
	var _hidx = _sky.hidx;
	for (var _hi = 0; _hi < array_length(_hidx); _hi++) {
		var _i = _hidx[_hi], _sk = _stars[_i];
		var _dv = mat3_apply(_ct, _sk.x, _sk.y, _sk.z);
		if (_dv[2] > -.2) continue;
		var _f  = 230 / -_dv[2];
		var _sx = _cx + _dv[0] * _f, _sy = _cy + _dv[1] * _f;
		// THE SIZE by its distance plainly (the glyph law saturated at both ends - "either large or small", his report): the
		// shadow's radius, from a speck to four pixels
		var _rs = clamp((_sk[$ "psz"] ?? 2) * 1.2 * 60 / max(20, _sk[$ "d"] ?? 200), .6, 4);
		var _r = _rs * 2, _hq = max(4, ceil(_r * 2.2)), _qw = _hq * 2;
		var _m = _hq + 2;
		if (_sx < -_m || _sx > _w + _m || _sy < -_m || _sy > _h + _m) continue;
		var _fade = clamp((min(_sx, _w - _sx) + _m) / _m, 0, 1) * clamp((min(_sy, _h - _sy) + _m) / _m, 0, 1) * clamp((-_dv[2] - .2) / .1, 0, 1);
		var _a = (.3 + .7 * _sk.b) * _fade;
		if (_a <= .01) continue;
		// ITS OWN FRAME (his report: "rotating themselves as if they are the centre piece"): the disc as the galactic plane
		// lies along the line of sight to THIS hole, not the view's middle
		var _fr = hole_frame(_dv, _cam);
		var _hc = [0, 0, 0, _fr[0], _fr[1], _fr[2], 0, 0, 0];   // (sh_hole reads row 1 alone: the disc's normal in the quad's frame)
		var _seed = ((_sk[$ "sseed"] ?? 0) mod 1000) * .37;
		// THE FROZEN RENDER (his ask: "make their render frozen so it doesn't cost as much"): baked once, the first time the
		// whole quad stands on the page - the hole over the sky behind it, premultiplied, its corners clear - and blitted
		// after that, turned by the roll the camera has put on the sky since (its screen-up at the bake, a world vector,
		// projected again); the disc holds its phase. The line of sight to a neighbour never changes, so the render is
		// right for good; only a lost surface bakes it again
		var _key = string(_i), _bk = _sky.hbake[$ _key];
		var _ok = is_struct(_bk) && surface_exists(_bk.surf) && _bk.qw == _qw;
		var _x0 = floor(_sx - _hq), _y0 = floor(_sy - _hq);
		// (not while the sun's glare lies over the patch - the glare would freeze into the bake; bug hunt 2026-09-18)
		var _sun_clear = true;
		if (_sun && !(_sky[$ "hole"] ?? false)) { var _lw0 = _sky.light_w; var _sv0 = mat3_apply(_ct, _lw0[0], _lw0[1], _lw0[2]); if (_sv0[2] < -.1) { var _sf0 = 230 / -_sv0[2]; if (point_distance(_sx, _sy, _cx + _sv0[0] * _sf0, _cy + _sv0[1] * _sf0) < 90 * (_sky.sun_size / 12) + _hq) _sun_clear = false; } }
		if (!_ok && _pg_ok && _sun_clear && _x0 >= 0 && _y0 >= 0 && _x0 + _qw <= _pw && _y0 + _qw <= _ph) {
			var _bs = surface_create(_qw, _qw, surface_get_format(_pg));
			surface_reset_target();
			surface_set_target(_bs);
			draw_clear_alpha(c_black, 0);
			hole_draw(_hq, _hq, _r, _sk.col, _seed, 1, _hc, _pg, _sx, _sy, true);
			surface_reset_target();
			surface_set_target(_pg);
			_bk = { surf : _bs, qw : _qw, up : [_fr[3], _fr[4], _fr[5]] };
			_sky.hbake[$ _key] = _bk; _ok = true;
		}
		if (_ok) {
			// the roll: where the baked screen-up points on the page now (its world vector through the camera, and the
			// perspective's share of its depth at the hole's place)
			var _uv = mat3_apply(_ct, _bk.up[0], _bk.up[1], _bk.up[2]);
			var _sux = _uv[0] + _dv[0] * _uv[2] / -_dv[2], _suy = _uv[1] + _dv[1] * _uv[2] / -_dv[2];
			var _rot = darctan2(-_suy, _sux) - 90;
			var _rc = dcos(_rot), _rsn = dsin(_rot);
			var _ac = make_colour_rgb(round(255 * _a), round(255 * _a), round(255 * _a));   // (premultiplied: the fade scales the colour AND the alpha)
			gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_alpha, bm_zero, bm_one);   // (premultiplied over; the page's alpha untouched)
			draw_surface_ext(_bk.surf, _sx - _hq * (_rc + _rsn), _sy - _hq * (_rc - _rsn), 1, 1, _rot, _ac, _a);
			gpu_set_blendmode(bm_normal);
		} else hole_draw(_sx, _sy, _r, _sk.col, _seed, _a, _hc);   // (live until the whole quad is on the page)
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
			if (_sfade > 0) { var _fs = hole_frame(_sv, _cam); hole_draw(_ssx, _ssy, 5.5 * _ss, _sky.sun_col, (_sky[$ "star"] ?? 0) * .37, _sfade, [0, 0, 0, _fs[0], _fs[1], _fs[2], 0, 0, 0]); }   // (along its own line of sight - q196)
		}
	}
}
