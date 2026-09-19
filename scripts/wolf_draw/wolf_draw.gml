/// @description wolf_draw(x, y, r, col, seed, [fade], [cam]) - A WOLF-RAYET's SHELL over its star (star_draw goes first): the skin the star has thrown off - a wide luminous ring round it (three to five radii out), its inner edge sharper, its outer edge frayed into filaments turning slowly, in the star's blue-white; additive (q253)
function wolf_draw(_x, _y, _r, _col, _seed, _fade = 1, _cam = undefined) {
	if (_r < .5 || _fade <= 0) return;
	var _gw = max(1, sprite_get_width(spr_vis_glow_soft)), _gh = max(1, sprite_get_height(spr_vis_glow_soft));
	var _sc = merge_colour(_col, rgb(150, 200, 255), .5), _t = current_time / 1000;
	gpu_set_blendmode(bm_add);
	// the shell: a ring drawn as a fan of soft glows round the circle, the radius wobbling on the seed (a shell is never round)
	var _R = _r * 4.2, _n = 40;
	draw_set_circle_precision(48);
	for (var _k = 0; _k < _n; _k++) {
		var _a = _k * 360 / _n;
		var _w = 1 + .10 * dsin(_a * 3 + _seed * 37) + .05 * dsin(_a * 7 - _t * 4 + _seed * 91);
		var _rr = _R * _w, _px = _x + dcos(_a) * _rr, _py = _y - dsin(_a) * _rr;
		draw_sprite_ext(spr_vis_glow_soft, 0, _px, _py, _r * 1.6 / _gw, _r * 1.6 / _gh, 0, _sc, .16 * _fade);
	}
	// the inner edge: a crisp faint circle; the frayed outer filaments: short radial strokes turning
	draw_set_alpha(.22 * _fade); draw_circle_colour(_x, _y, _R * .86, _sc, _sc, true); draw_set_alpha(1);
	for (var _k = 0; _k < 14; _k++) {
		var _a2 = _k * 360 / 14 + _t * 2.5 + (_seed mod 360);
		var _l0 = _R * (1.05 + .05 * dsin(_a2 * 2)), _l1 = _l0 + _r * (.8 + .5 * dsin(_a2 * 5 + _seed));
		draw_line_width_colour(_x + dcos(_a2) * _l0, _y - dsin(_a2) * _l0, _x + dcos(_a2) * _l1, _y - dsin(_a2) * _l1, 1, _sc, merge_colour(_sc, c_black, 1));
	}
	// the star's own blaze: a wide bloom
	draw_sprite_ext(spr_vis_glow_soft, 0, _x, _y, _r * 5 / _gw, _r * 5 / _gh, 0, _sc, .35 * _fade);
	draw_set_circle_precision(24);
	gpu_set_blendmode(bm_normal);
}
