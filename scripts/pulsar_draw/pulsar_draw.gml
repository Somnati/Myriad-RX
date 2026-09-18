/// @description pulsar_draw(x, y, r, col, seed, spin, tilt, [fade]) - a PULSAR's beams over its star (star_draw goes first): two lighthouse cones sweeping round the spin axis, and the flash when one comes round to the eye
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
	gpu_set_blendmode(bm_add);
	for (var _b = 0; _b < 2; _b++) {
		var _a = _ph + _b * 180;
		// the beam's direction on the screen: round a circle foreshortened by the tilt (the axis leans toward the eye)
		var _dx = dcos(_a), _dy = dsin(_a) * _ct, _tow = dsin(_a) * _st;   // (tow: toward the eye, +)
		var _dl = max(.05, sqrt(_dx * _dx + _dy * _dy));
		var _ang = darctan2(-_dy, _dx);
		var _vis = .35 + .65 * clamp((_tow + 1) * .5, 0, 1);   // (a beam toward the eye is the brighter)
		var _L = _len * _dl;
		draw_sprite_ext(spr_vis_glow_soft, 0, _x + _dx / _dl * _L * .5, _y + _dy / _dl * _L * .5, _L / _gw * 1.2, _thin / _gh, _ang, _bc, .55 * _vis * _fade);
		draw_sprite_ext(spr_vis_glow_soft, 0, _x + _dx / _dl * _L * .3, _y + _dy / _dl * _L * .3, _L * .6 / _gw, _thin * 2.2 / _gh, _ang, _bc, .25 * _vis * _fade);
	}
	// THE FLASH: a beam through the line of sight - the star's whole light spikes
	var _fl = power(clamp(dsin(_ph) * _st, 0, 1), 18) + power(clamp(-dsin(_ph) * _st, 0, 1), 18);
	if (_fl > .02) { var _fs = _r * 5 / _gw; draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _fs, _fs, 0, _bc, .7 * _fl * _fade); }
	gpu_set_blendmode(bm_normal);
}
