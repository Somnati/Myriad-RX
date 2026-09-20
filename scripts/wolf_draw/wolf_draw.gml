/// @description wolf_draw(x, y, r, col, seed, [fade], [cam]) - A WOLF-RAYET's SHELL over its star (star_draw goes first): the skin the star has thrown off, a THIN luminous ring round it (q265 - his report: the old fan of glows was "a lumpy grey torus with darts")
/// Two shells: the young one two radii out, crisp, its radius wobbling on
/// the seed (a shell is never round); the older one further and fainter.
/// A short fine fray off the young shell's outer edge, turning slowly. A
/// tight bloom on the star. All additive; the sky view and the system
/// view draw the same
function wolf_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined) {
	if (_r < .5 || _fade <= 0) return;
	var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
	var _sc = merge_colour(_col, rgb(150, 200, 255), .5), _t = current_time / 1000;
	gpu_set_blendmode(bm_add);
	// the young shell: a wobbling ring of short segments, two pixels wide, and a soft halo of the same ring under it
	var _R = _r * 2.2, _n = 72;
	var _lx = 0, _ly = 0;
	for (var _pass = 0; _pass < 2; _pass++) {
		var _RR = (_pass == 0) ? _R : _R * 1.45, _al = (_pass == 0) ? .55 : .22, _wd = (_pass == 0) ? 2 : 1;
		for (var _k = 0; _k <= _n; _k++) {
			var _a = _k * 360 / _n;
			var _w = 1 + .07 * dsin(_a * 3 + _seed * 37) + .04 * dsin(_a * 7 - _t * 3 + _seed * 91) + ((_pass == 1) ? .06 * dsin(_a * 5 + _seed * 13) : 0);
			var _rr = _RR * _w, _px = _x + dcos(_a) * _rr, _py = _y - dsin(_a) * _rr;
			if (_k > 0) draw_line_width_colour(_lx, _ly, _px, _py, _wd, merge_colour(_sc, c_black, 1 - _al * _fade), merge_colour(_sc, c_black, 1 - _al * _fade));
			_lx = _px; _ly = _py;
		}
	}
	// the fray: short fine strokes off the young shell, dim, turning
	for (var _k = 0; _k < 10; _k++) {
		var _a2 = _k * 36 + _t * 2 + (_seed mod 360);
		var _l0 = _R * 1.02, _l1 = _l0 + _r * (.25 + .2 * dsin(_a2 * 5 + _seed));
		draw_line_width_colour(_x + dcos(_a2) * _l0, _y - dsin(_a2) * _l0, _x + dcos(_a2) * _l1, _y - dsin(_a2) * _l1, 1, merge_colour(_sc, c_black, .6), c_black);
	}
	// the halo inside the shell (the wind's light), and the star's own bloom - tighter than before
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _R * 2.1 / _gw, _R * 2.1 / _gh, 0, merge_colour(_sc, c_black, .7), .18 * _fade);
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _r * 3 / _gw, _r * 3 / _gh, 0, _sc, .28 * _fade);
	gpu_set_blendmode(bm_normal);
}
