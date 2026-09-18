/// @description pulsar_draw(x, y, r, col, seed, spin, tilt, [fade]) - a PULSAR's beams over its star (star_draw goes first): two lighthouse CONES sweeping round the spin axis, a magnetosphere ring in the sweep's plane, a pulse ring rolling out on every beat, and the flash when a beam comes round to the eye
/// The axis leans by tilt degrees off the view, so the sweep is a
/// foreshortened circle; each beam is the soft glow stretched thin along
/// its line, brightest at the star, and the whole thing FLASHES as a beam
/// swings through the line of sight - the interval is the pulsar's own
/// (spin turns a second) and never quite even (a hash a turn nudges it),
/// so it keeps the house's rule against metronomes while being what a
/// pulsar is. Additive. 2026-09-17
function pulsar_draw(_x, _y, _r, _col, _seed, _spin, _tilt, _fade = 1) {
	if (_r < .5 || _fade <= 0) return;
	var _t = current_time / 1000;
	var _turn = _t * _spin + _seed * 7.7, _ti = floor(_turn), _tf = _turn - _ti;
	var _jit = ((hash_mix(_ti mod 100000, 91) mod 1000) / 1000 - .5) * .16;   // (a turn nudged: never quite even)
	var _ph = (_tf + _jit) * 360;
	var _ct = dcos(_tilt), _st = dsin(_tilt);
	var _len = _r * 9, _thin = max(1, _r * .35);
	var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
	var _bc = merge_colour(_col, c_white, .5);
	var _da0 = draw_get_alpha();
	gpu_set_blendmode(bm_add);
	// THE MAGNETOSPHERE: a faint ring round the star in the sweep's plane (the ellipse the beams' ends trace), the
	// turning frame the eye reads the spin from
	var _mx = _r * 2.6, _my = _r * 2.6 * abs(_ct);
	draw_set_alpha(.16 * _fade);
	draw_ellipse_colour(_x - _mx, _y - _my, _x + _mx, _y + _my, _bc, _bc, true);
	draw_ellipse_colour(_x - _mx - 1, _y - _my - 1, _x + _mx + 1, _y + _my + 1, _bc, _bc, true);
	draw_set_alpha(_da0);
	for (var _b = 0; _b < 2; _b++) {
		var _a = _ph + _b * 180;
		// the beam's direction on the screen: round a circle foreshortened by the tilt (the axis leans toward the eye)
		var _dx = dcos(_a), _dy = dsin(_a) * _ct, _tow = dsin(_a) * _st;   // (tow: toward the eye, +)
		var _dl = max(.05, sqrt(_dx * _dx + _dy * _dy));
		var _ux = _dx / _dl, _uy = _dy / _dl, _px = -_uy, _py = _ux;
		var _ang = darctan2(-_uy, _ux);
		var _vis = .35 + .65 * clamp((_tow + 1) * .5, 0, 1);   // (a beam toward the eye is the brighter)
		var _L = _len * _dl, _hw = _L * .15;   // (the cone's half-width at its end)
		// THE CONE (his verdict on the first cut: "a generic spinning line"): two gradient triangles, bright and narrow at the
		// star, wide and gone at the end - a wide faint one, the searchlight's spill, and a narrow bright one inside it
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
	// THE PULSE RING: as a beam sweeps through the line of sight (the flash below) a ring rolls out from the star and
	// fades - the pulse itself, seen from the side; the beat is the pulsar's own (spin turns a second, the hash's nudge)
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
	var _fl = power(clamp(dsin(_ph) * _st, 0, 1), 18) + power(clamp(-dsin(_ph) * _st, 0, 1), 18);
	if (_fl > .02) { var _fs = _r * 5 / _gw; draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _fs, _fs, 0, _bc, .7 * _fl * _fade); }
	gpu_set_blendmode(bm_normal);
}
