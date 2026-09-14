/// the tower: foot up, each slab as the board draws its tier, rising
/// into place on the drawer's ease
var _r = __rise();
// the debug column slides in over this edge (bottom-left chip): the tower yields to it
if (instance_exists(syst_tiles)) _r *= (1 - clamp(syst_tiles.dbg_open, 0, 1));
if (_r <= .001) exit;
var _t  = g.tiles;
var _hi = max(1, _t.highest);
var _slabs = __slabs();
var _n = array_length(_slabs);
var _dim = rgb(120, 130, 150);

// the tiles of each tier on the board right now (the pips)
var _cnt = {};
for (var _i = 0; _i < _t.slots; _i++) {
	var _tr = _t.tier[_i];
	if (_tr <= 0) continue;
	_cnt[$ string(_tr)] = (_cnt[$ string(_tr)] ?? 0) + 1;
}

draw_set_font(fnt_large);
draw_set_halign(fa_center);
draw_set_valign(fa_top);

// the foot first, each slab a beat behind the one under it: a tower
// being built. Each rises 40 px into its seat and fades in with it
for (var _k = 0; _k < _n; _k++) {
	var _sl = _slabs[_k];
	var _tt = clamp((_r - min(_k, 25) * .02) / .5, 0, 1);   // the last slab's delay + its rise = the whole ease
	var _e  = 1 - (1 - _tt) * (1 - _tt) * (1 - _tt);
	if (_e <= .001) continue;
	// depth: the far slabs fade like a tower into haze (DE's alpha ran to
	// nothing at the top; ours holds a trace so the count of rungs reads)
	var _da = clamp(power((_sl.s - .15) / .85, .8), .12, 1) * _sl.fade;
	var _a  = _e * _da;
	if (_a <= .01) continue;
	var _y  = _sl.y + (1 - _e) * 40;
	var _x  = _sl.x;
	var _known = (_sl.tier <= _hi);
	var _col = _known ? merge_colour(tile_color(_sl.tier), c_black, .7) : merge_colour(c_black, c_white, .06);

	// THE BEACON: your highest tier, lit
	if (_sl.tier == _hi) {
		var _gw = sprite_get_width(spr_vis_glow_soft);
		var _gs = (_sl.w * 2.2) / _gw;
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(spr_vis_glow_soft, 0, _x + _sl.w * .5, _y + _sl.h * .5, _gs, _gs * .7, 0,
			tile_color(_sl.tier), (.18 + .1 * abs(dsin(current_time * .2))) * _a);
		gpu_set_blendmode(bm_normal);
	}

	// DE'S SHELF (his: "the vertical depth mine had"): a line from the
	// room's edge to the slab at its middle, thicker for the near slabs -
	// every floor of the tower reaching into the wall
	var _sh_y = floor(_y + _sl.h * .5);
	var _sh_t = max(1, round(2 * _sl.s));
	draw_sprite_ext(spr_pixel_1x1, 0, 0, _sh_y, max(0, floor(_x) + 1), _sh_t, 0, _col, .55 * _a);
	// THE SLAB'S SIDE: its thickness under it, in the gap to the next rung
	// down - the rungs read as stacked blocks, not tiles on a line
	var _side = max(1, round(2 * _sl.s));
	draw_sprite_ext(spr_pixel_1x1, 0, floor(_x) + 1, floor(_y + _sl.h), max(1, round(_sl.w) - 2), _side, 0,
		merge_colour(_col, c_black, .55), .9 * _a);
	// the slab, as the board draws the tier: its colour, its material
	var _skin = _known ? tile_skin_roll(_sl.tier) : 0;
	tile_shape_draw(_known ? _sl.tier : 0, _x, _y, _sl.w, _sl.h, _col, _a, _skin, _sl.tier);

	// the number: DE's - fnt_large scaled WITH the slab (his report: the
	// text was doing something; it was swapping fonts at a threshold), the
	// board's text colour rule; none in the haze, none on an unknown
	if (_known && _sl.s >= .3) {
		var _tc = (_sl.tier <= 1) ? c_white : make_colour_hsv(colour_get_hue(tile_color(_sl.tier)),
			clamp(colour_get_saturation(tile_color(_sl.tier)), 100, 255), clamp(colour_get_value(tile_color(_sl.tier)), 190, 255));
		draw_set_color(_tc);
		draw_set_alpha(_a);
		draw_set_font(fnt_large);
		draw_text_transformed(floor(_x + _sl.w * .5), floor(_y + (_sl.h - 9 * _sl.s) * .5), string(_sl.tier), _sl.s, _sl.s, 0);
	}

	// the pips: how many of this tier sit on the board
	var _c = _cnt[$ string(_sl.tier)] ?? 0;
	if (_c > 0 && _sl.s >= .3) {
		var _px = floor(_x + _sl.w + 4), _py = floor(_y + _sl.h * .5 - 1);
		if (_c <= 5) {
			for (var _j = 0; _j < _c; _j++)
				draw_sprite_ext(spr_pixel_1x1, 0, _px + _j * 3, _py, 2, 2, 0, tile_color(_sl.tier), .8 * _a);
		} else {
			draw_set_font(fnt);
			draw_set_halign(fa_left);
			draw_set_color(tile_color(_sl.tier));
			draw_set_alpha(.8 * _a);
			draw_text(_px, _py - 2, "x" + string(_c));
			draw_set_halign(fa_center);
		}
	}
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_font(fnt);
