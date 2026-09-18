/// @description galaxy_sky_draw(sky, cam, cx, cy, w, h, [sun]) - the sky's stars, siblings and sun into the current target
/// obj_planet_sky's draw: everything projects through the orbit camera
/// (cam = view -> world; its transpose takes world to view), the
/// projection sx = cx + vx x 230 / -vz (the sky is BEHIND the planet: a
/// direction with view z < 0 is away from the viewer). w / h = the
/// target's size for the cull. sun = draw the system's star (false on a
/// page that has no room for it).
/// THE SKY PASS (his picks, 2026-09-16): the faint stars TWINKLE (two
/// sines at an irrational ratio on a per-star phase - never a beat); the
/// big neighbours wear a HALO (spr_star_glow, a frame by size); stars
/// inside the sun's GLARE dim; the near SIBLINGS are little discs with a
/// lit side (their phase, galaxy_sky_build) instead of dots; the sun
/// throws an anamorphic FLARE streak and two ghosts along the line through
/// the view's centre. The sun's glow breathes on smoothed noise, not a
/// sine (the pulse "too rhythmic", his report).
/// sibs = draw the sibling planets (false on the star system page: they are the planets); occ = { x, y, r } a disc on the
/// page (or a list of them; kind "moon" covers by overlap) that hides the sun; the world's disc: the sun's glow and flare fade as it goes behind it
/// page that hides the sun (the world in the orbit view): the sun's glow and flare fade as it goes behind it (his report,
/// 2026-09-16: the glow stayed whole until it snapped round the limb)
function galaxy_sky_draw(_sky, _cam, _cx, _cy, _w, _h, _sun = true, _sibs = true, _occ = undefined) {
	var _ct = mat3_transpose(_cam);
	var _cfg = starmap_config();
	draw_set_alpha(1);
	// the sun first: where it is on the page (the stars' glare, the siblings' lit side read it)
	var _lw = _sky.light_w;
	var _sv = mat3_apply(_ct, _lw[0], _lw[1], _lw[2]);
	var _ss = _sky.sun_size / 12;
	var _sun_on = (_sv[2] < -.1), _ssx = 0, _ssy = 0, _sfade = 0;
	if (_sun_on) { _sfade = clamp((-_sv[2] - .1) / .12, 0, 1); var _sf = 230 / -_sv[2]; _ssx = _cx + _sv[0] * _sf; _ssy = _cy + _sv[1] * _sf; }
	// behind the disc: the sun's light fades over the first third of the way in, gone at the centre; a MOON's disc over it
	// (occ as a list: the world first, then the moons - kind "moon") covers by the overlap - an eclipse from the camera's seat,
	// a ring of corona left round the black (2026-09-16)
	if (_sun_on && (is_struct(_occ) || is_array(_occ))) {
		var _ol = is_array(_occ) ? _occ : [_occ];
		for (var _oi = 0; _oi < array_length(_ol); _oi++) {
			var _o = _ol[_oi];
			var _od = point_distance(_ssx, _ssy, _o.x, _o.y);
			if ((_o[$ "kind"] ?? "world") == "moon") { var _rs = 5.5 * _ss; var _cov = clamp((_o.r + _rs - _od) / (2 * _rs), 0, 1); _sfade *= 1 - .92 * _cov; }
			else if (_od < _o.r) _sfade *= clamp((_od - _o.r * .55) / (_o.r * .45), 0, 1);
		}
	}
	var _glr = (_cfg[$ "sky_glare"] ?? 70) * _ss;
	var _glare = _sun_on && _sfade > 0 && !(_sky[$ "hole"] ?? false);   // (a black hole for a sun throws no glare - the stars round it stayed dimmed; bug hunt 2026-09-18)
	var _tt = current_time;
	// (the nebulae are painted on the sphere by the fog pass - galaxy_fog_draw / sh_sky_fog; 2026-09-16)
	var _stars = _sky.stars;
	// two passes (bug hunt 2026-09-16): the points, then every glyph under ONE additive blend - a blend switch per glyph star
	// (up to 1,270 of them, twice) broke the batch every time: a stall in a rich sky
	for (var _pass = 0; _pass < 2; _pass++) {
	if (_pass == 1) gpu_set_blendmode(bm_add);
	for (var _i = 0; _i < array_length(_stars); _i++) {
		var _sk = _stars[_i];
		if ((_sk[$ "near"] ?? false) != (_pass == 1)) continue;
		// (the projection inline - mat3_apply's array a star, twice a frame over two thousand of them, fed the collector; the
		// depth first, the rest only past the cull; bug hunt 2026-09-18)
		var _dz = _ct[6] * _sk.x + _ct[7] * _sk.y + _ct[8] * _sk.z;
		if (_dz > -.2) continue;
		var _f  = 230 / -_dz;
		var _sx = _cx + (_ct[0] * _sk.x + _ct[1] * _sk.y + _ct[2] * _sk.z) * _f, _sy = _cy + (_ct[3] * _sk.x + _ct[4] * _sk.y + _ct[5] * _sk.z) * _f;
		var _m = 12 + _sk.s * 4;
		if (_sx < -_m || _sx > _w + _m || _sy < -_m || _sy > _h + _m) continue;
		var _fade = clamp((min(_sx, _w - _sx) + _m) / _m, 0, 1) * clamp((min(_sy, _h - _sy) + _m) / _m, 0, 1) * clamp((-_dz - .2) / .1, 0, 1);
		var _a = ((_sk[$ "cl"] ?? false) ? (_sk.b * 1.3) : (.3 + .7 * _sk.b)) * _fade;   // (a cloud point is grain: its raw brightness, not the stars' floor - the band stayed as he liked it)
		// the twinkle: the small ones only, two sines that never line up, the star's own phase
		if (_sk.s <= 2) { var _ph = _sk[$ "ph"] ?? 0; _a *= 1 - .22 * (.5 + .5 * dsin(_tt * (.11 + .0004 * _ph) + _ph) * dsin(_tt * .073 + _ph * 2.618)); }
		// the glare: inside the sun's reach a star fades toward it
		if (_glare) { var _gd = point_distance(_sx, _sy, _ssx, _ssy); if (_gd < _glr) _a *= 1 - .85 * _sfade * (1 - _gd / _glr); }
		// a real neighbour is a GLYPH (his ask, 2026-09-16: spr_star_glyph - core, halo, spikes by its size, tinted, its core white,
		// additive, whole scale); the grain and the dust stay points
		if (_pass == 1) {
			var _gi = star_glyph_frame(_sk.s), _gx0 = floor(_sx), _gy0 = floor(_sy);
			// THE KIND FROM HERE (his ask, 2026-09-17: "visible from local star systems just like stars"): the same marks the map wears
			var _skn = _sk[$ "skind"] ?? "main";
			var _gw1 = max(1, sprite_get_width(spr_vis_glow_soft)), _gh1 = max(1, sprite_get_height(spr_vis_glow_soft));
			if (_skn == "hole") {
				// (a neighbour hole is galaxy_sky_holes' - drawn after the fog; 2026-09-17)
			} else if (_skn == "dwarf") {
				var _dc1 = merge_colour(_sk.col, c_white, .6);
				draw_sprite_ext(spr_vis_glow_soft, 0, _gx0 + .5, _gy0 + .5, (max(6, _sk.s * 5) + 2) / _gw1, 1 / _gh1, 0, _dc1, .30 * _a);   // (the map's width - his ask, q195)
				draw_sprite_ext(spr_star_glyph, min(_gi, 1), _gx0, _gy0, 1, 1, 0, _dc1, _a);
			} else {
				var _pk1 = 1;
				if (_skn == "pulsar") { var _pt1 = (current_time / 1000) * (_sk[$ "sspin"] ?? 1) + ((_sk[$ "sseed"] ?? 0) mod 1000) / 1000; _pk1 = .55 + .45 * power(.5 + .5 * dsin(_pt1 * 360), 4); }
				draw_sprite_ext(spr_star_glyph, _gi, _gx0, _gy0, 1, 1, 0, _sk.col, _a * _pk1);
				if (_gi >= 2 && (_skn != "pulsar" || _pk1 > .7)) draw_sprite_ext(spr_star_glyph, STAR_GLYPH_CORE + _gi, _gx0, _gy0, 1, 1, 0, c_white, _a * .8 * _pk1);   // (a dot stays its colour)
				if (_skn == "giant") draw_sprite_ext(spr_vis_glow_soft, 0, _gx0 + .5, _gy0 + .5, _sk.s * 2.2 / _gw1, _sk.s * 2.2 / _gh1, 0, merge_colour(_sk.col, c_red, .4), .40 * _a);
			}
		} else draw_sprite_ext(spr_pixel_1x1, 0, _sx - _sk.s * .5, _sy - _sk.s * .5, max(1, _sk.s), max(1, _sk.s), 0, _sk.col, _a);
	}
	}
	gpu_set_blendmode(bm_normal);
	for (var _i = 0; _i < (_sibs ? array_length(_sky.sibs) : 0); _i++) {
		var _sb = _sky.sibs[_i];
		var _dv = mat3_apply(_ct, _sb.x, _sb.y, _sb.z);
		if (_dv[2] > -.2) continue;
		var _f  = 230 / -_dv[2];
		var _sx = _cx + _dv[0] * _f, _sy = _cy + _dv[1] * _f;
		if (_sx < -20 || _sx > _w + 20 || _sy < -20 || _sy > _h + 20) continue;
		var _fade = clamp((-_dv[2] - .2) / .1, 0, 1);
		var _scol = merge_colour(_sb.col, c_white, .35);
		if (_sb.s < 3 || is_undefined(_sb[$ "lit"])) { draw_sprite_ext(spr_pixel_1x1, 0, _sx - _sb.s * .5, _sy - _sb.s * .5, max(1, _sb.s), max(1, _sb.s), 0, _scol, .95 * _fade); continue; }
		// A LIT DISC: rows of a circle, the dark side in the planet's colour at night, the lit part toward the sun's side
		var _rr = floor(_sb.s * .5), _lit = _sb.lit;
		var _ldx = 1, _ldy = 0;
		if (_sun_on) { _ldx = _sv[0] - _dv[0]; _ldy = _sv[1] - _dv[1]; } else { _ldx = _sv[0]; _ldy = _sv[1]; }
		var _ll = point_distance(0, 0, _ldx, _ldy); if (_ll > .0001) { _ldx /= _ll; _ldy /= _ll; }
		var _dark = merge_colour(_sb.col, c_black, .72);
		var _sx0 = floor(_sx), _sy0 = floor(_sy);
		for (var _dy = -_rr; _dy <= _rr; _dy++) {
			var _hw = floor(sqrt(max(0, _rr * _rr - _dy * _dy)));
			// the terminator across this row: lit from the sun's side to a cut that slides with the phase (an ellipse's chord, near enough at this size)
			var _cut = (1 - 2 * _lit) * _hw;   // +hw = new (nothing lit), -hw = full
			for (var _dx = -_hw; _dx <= _hw; _dx++) {
				var _along = _dx * _ldx + _dy * _ldy;   // (toward the sun is positive)
				var _isl = (_along > _cut);
				draw_sprite_ext(spr_pixel_1x1, 0, _sx0 + _dx, _sy0 + _dy, 1, 1, 0, _isl ? _scol : _dark, (_isl ? .95 : .8) * _fade);
			}
		}
	}
	if (_sun && _sun_on) {
		// the glow breathes on smoothed noise (a sine was a metronome - his report 2026-09-16)
		var _bt = _tt / 900, _bi = floor(_bt), _bf = frac(_bt); _bf = _bf * _bf * (3 - 2 * _bf);
		var _n0 = (hash_mix(_bi mod 100000, 5) mod 1000) / 1000, _n1 = (hash_mix((_bi + 1) mod 100000, 5) mod 1000) / 1000;
		var _pu = 1 + .07 * (lerp(_n0, _n1, _bf) - .5);
		var _gs = (60 * _ss * _pu) / max(1, sprite_get_width(spr_vis_glow_soft));
		// THE SUN ITSELF (2026-09-16): sh_star - the disc, its corona and prominences (star_draw); the flare rides on
		if (_sky[$ "hole"] ?? false) return;   // (a black hole for a sun is galaxy_sky_holes' - drawn AFTER the fog, so the fog never lies over its black and the lens bends the fog too; 2026-09-17)
		star_draw(_ssx, _ssy, 5.5 * _ss, _sky.sun_col, (_sky[$ "star"] ?? 0) * .37, _sfade, _cam);
		var _skd1 = _sky[$ "skind"] ?? "main";
		if (_skd1 == "pulsar") pulsar_draw(_ssx, _ssy, 5.5 * _ss, _sky.sun_col, (_sky[$ "star"] ?? 0) * .37, _sky.sspin, _sky.stilt, _sfade, _cam);   // (its beams sweep the sky, held to the world - 2026-09-17)
		else if (_skd1 == "dwarf") dwarf_draw(_ssx, _ssy, 5.5 * _ss, _sky.sun_col, _sfade);   // (a white dwarf's blaze - q195)
		gpu_set_blendmode(bm_add);
		// THE FLARE: an anamorphic streak (the soft glow stretched flat) and two ghosts along the line through the view's centre
		draw_sprite_ext(spr_vis_glow_soft, 0, _ssx, _ssy, _gs * 3.2, _gs * .10, 0, merge_colour(_sky.sun_col, c_white, .4), .22 * _sfade);
		var _gvx = _cx - _ssx, _gvy = _cy - _ssy;
		var _g1x = _ssx + _gvx * 1.55, _g1y = _ssy + _gvy * 1.55, _g2x = _ssx + _gvx * 2.15, _g2y = _ssy + _gvy * 2.15;
		var _gg = _gs * .28;
		draw_sprite_ext(spr_vis_glow_soft, 0, _g1x, _g1y, _gg, _gg, 0, merge_colour(_sky.sun_col, rgb(120, 200, 255), .5), .10 * _sfade);
		draw_sprite_ext(spr_vis_glow_soft, 0, _g2x, _g2y, _gg * .6, _gg * .6, 0, merge_colour(_sky.sun_col, rgb(255, 160, 200), .5), .08 * _sfade);
		gpu_set_blendmode(bm_normal);
	}
}
