/// @description pulsar_draw(x, y, r, col, seed, spin, tilt, [fade], [cam]) - a PULSAR's beams over its star (star_draw goes first): two lighthouse CONES sweeping round the spin axis, a magnetosphere ring in the sweep's plane, a pulse ring rolling out on every beat, and the flash when a beam comes round to the eye
/// THE AXIS IS THE WORLD'S (q195; his report: "it rotates with the
/// camera"): tilt degrees off the galactic up, its bearing hashed off the
/// seed; the beams sweep the plane square to it, and cam (the view's
/// camera, view -> world) takes the beam and the ring into the view -
/// turn the camera and the pulsar holds still. The flash comes when a
/// beam swings through the line of sight; the interval is the pulsar's
/// own (spin turns a second) and never quite even (a hash a turn nudges
/// it): the house's rule against metronomes, kept. Additive. 2026-09-17
function pulsar_draw(_x, _y, _r, _col, _seed, _spin, _tilt, _fade = 1, _cam = undefined) {
	if (_r < .5 || _fade <= 0) return;
	var _t = current_time / 1000;
	var _turn = _t * _spin + _seed * 7.7, _ti = floor(_turn), _tf = _turn - _ti;
	var _jit = ((hash_mix(_ti mod 100000, 91) mod 1000) / 1000 - .5) * .16;   // (a turn nudged: never quite even)
	var _ph = (_tf + _jit) * 360;
	// the axis and the sweep's frame, in the world
	var _az = hash_mix(floor(_seed * 1000) mod 100000, 93) mod 360;
	var _ax = [dsin(_tilt) * dcos(_az), dcos(_tilt), dsin(_tilt) * dsin(_az)];
	var _e1 = [dcos(_az + 90), 0, dsin(_az + 90)];
	var _e2 = [_ax[1] * _e1[2] - _ax[2] * _e1[1], _ax[2] * _e1[0] - _ax[0] * _e1[2], _ax[0] * _e1[1] - _ax[1] * _e1[0]];
	var _ct = is_array(_cam) ? mat3_transpose(_cam) : [1, 0, 0, 0, 1, 0, 0, 0, 1];
	// the beam now, into the view (x / y on the page, z toward the eye)
	var _cp = dcos(_ph), _sp = dsin(_ph);
	var _dv = mat3_apply(_ct, _e1[0] * _cp + _e2[0] * _sp, _e1[1] * _cp + _e2[1] * _sp, _e1[2] * _cp + _e2[2] * _sp);
	var _len = _r * 9, _thin = max(1, _r * .35);
	var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
	var _bc = merge_colour(_col, c_white, .5);
	var _da0 = draw_get_alpha();
	gpu_set_blendmode(bm_add);
	// THE MAGNETOSPHERE: a faint ring round the star in the sweep's plane (the circle the beams' ends trace), the
	// turning frame the eye reads the spin from - its points through the camera, as a line strip
	var _mr = _r * 2.6;
	draw_primitive_begin(pr_linestrip);
	for (var _k = 0; _k <= 36; _k++) {
		var _ka = _k * 10, _kc = dcos(_ka), _ks = dsin(_ka);
		var _kv = mat3_apply(_ct, _e1[0] * _kc + _e2[0] * _ks, _e1[1] * _kc + _e2[1] * _ks, _e1[2] * _kc + _e2[2] * _ks);
		draw_vertex_colour(_x + _kv[0] * _mr, _y + _kv[1] * _mr, _bc, .16 * _fade * (.6 + .4 * clamp(_kv[2] + .5, 0, 1)));   // (the near side a touch brighter)
	}
	draw_primitive_end();
	for (var _b = 0; _b < 2; _b++) {
		var _sg = (_b == 0) ? 1 : -1;
		var _dx = _dv[0] * _sg, _dy = _dv[1] * _sg, _tow = _dv[2] * _sg;   // (tow: toward the eye, +)
		var _dl = sqrt(_dx * _dx + _dy * _dy);
		if (_dl < .05) continue;   // (straight at the eye or away: the flash is all there is)
		var _ux = _dx / _dl, _uy = _dy / _dl, _px = -_uy, _py = _ux;
		var _ang = darctan2(-_uy, _ux);
		var _vis = .35 + .65 * clamp((_tow + 1) * .5, 0, 1);   // (a beam toward the eye is the brighter)
		var _L = _len * _dl, _hw = _L * .15;   // (foreshortened by its lean; the cone's half-width at its end)
		// THE CONE: two gradient triangles, bright and narrow at the star, wide and gone at the end - a wide faint one,
		// the searchlight's spill, and a narrow bright one inside it
		draw_primitive_begin(pr_trianglelist);
		draw_vertex_colour(_x, _y, _bc, .28 * _vis * _fade);
		draw_vertex_colour(_x + _ux * _L * .85 + _px * _hw * 2.2, _y + _uy * _L * .85 + _py * _hw * 2.2, _bc, 0);
		draw_vertex_colour(_x + _ux * _L * .85 - _px * _hw * 2.2, _y + _uy * _L * .85 - _py * _hw * 2.2, _bc, 0);
		draw_vertex_colour(_x, _y, c_white, .55 * _vis * _fade);
		draw_vertex_colour(_x + _ux * _L + _px * _hw, _y + _uy * _L + _py * _hw, _bc, 0);
		draw_vertex_colour(_x + _ux * _L - _px * _hw, _y + _uy * _L - _py * _hw, _bc, 0);
		draw_primitive_end();
		// its SPINE: a thin white line down the middle, brightest at the star
		draw_sprite_ext(spr_vis_glow_soft, 0, _x + _ux * _L * .42, _y + _uy * _L * .42, _L * .9 / _gw, _thin / _gh, _ang, c_white, .5 * _vis * _fade);
	}
	// THE PULSE RING: twice a turn a ring rolls out from the star and fades - the pulse itself, seen from the side; the
	// beat is the pulsar's own (spin turns a second, the hash's nudge)
	var _rf = frac((_tf + _jit - .25) * 2 + 10);
	var _rr = _r * (1.4 + 8 * _rf), _ra = .45 * power(1 - _rf, 2.2) * _fade;
	if (_ra > .015) {
		draw_set_circle_precision(48);
		draw_set_alpha(_ra);
		draw_circle_colour(_x, _y, _rr, _bc, _bc, true);
		draw_set_alpha(_ra * .5);
		draw_circle_colour(_x, _y, _rr - 1, _bc, _bc, true);
		draw_set_alpha(_da0);
		draw_set_circle_precision(24);
	}
	// THE FLASH: a beam through the line of sight - the star's whole light spikes
	var _fl = power(clamp(_dv[2], 0, 1), 18) + power(clamp(-_dv[2], 0, 1), 18);
	if (_fl > .02) { var _fs = _r * 5 / _gw; draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _fs, _fs, 0, _bc, .7 * _fl * _fade); }
	gpu_set_blendmode(bm_normal);
}
