/// the whole table: fab/automerge bars, board, ghost, info box,
/// controls. house primitives only; spr_tile frame 2 is the fill
/// (the same subimage Myriad drew for everything). tile values render
/// in fnt_large - the Myriad tile font - everything else stays fnt

var _t = g.tiles;

draw_set_font(fnt);
draw_set_halign(fa_center);

// ---- fabricator + automerge bars: slivers right under the 29px
// header (they used to sit AT y24, i.e. behind it). green = progress
// to the next fabricated tile, steelblue = the auto-merge cadence ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, 29, room_width, 3, 0, c_black, .8);
draw_sprite_ext(spr_pixel_1x1, 0, 0, 29,
	room_width * clamp(_t.fab / _t.fab_t, 0, 1), 3, 0, c_seagreen, .9);
if (_t.automerge) {
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 32, room_width, 2, 0, c_black, .8);
	// the merger is a powered machine: its bar cools from steelblue
	// toward red as the battery pool starves it (thr_am, power_tick) -
	// the fill also crawls slower, this makes the WHY readable
	var _amthr = _t[$ "thr_am"] ?? 1;
	draw_sprite_ext(spr_pixel_1x1, 0, 0, 32,
		room_width * clamp(_t.am_tic / _t.am_tic_, 0, 1), 2, 0,
		merge_colour(c_hred, c_steelblue, _amthr), .9);
}
if (_t.stored > 0) {
	// left of the back button (room_width-86..-6, y30-54) - it drew
	// underneath it at the right edge
	draw_set_halign(fa_right);
	draw_set_color((_t.stored >= _t.stored_max) ? c_horange : c_seagreen);
	draw_set_alpha(.9);
	draw_text(room_width - 92, 36,
		"stored x" + string(_t.stored) + "/" + string(_t.stored_max));
	draw_set_halign(fa_center);
}

// title
draw_set_color(c_aqua);
draw_set_alpha(.85);
draw_text(240, 40, "tiles");

// ---- the board ----
var _am0 = __aim(); // the drop's true target (mouse or tile center)
var _hov = __slot_at(_am0[0], _am0[1]);
draw_set_font(fnt_large);
for (var _i = 0; _i < _t.slots; _i++) {
	var _x = __slot_x(_i);
	var _y = __slot_y(_i);
	var _tier = _t.tier[_i];

	if (_tier == 0) {
		// empty socket: Myriad's dark-theme surface tint
		draw_sprite_ext(spr_tile, 2, _x, _y, tsc, tsc, 0, slot_col, .9);
	} else {
		var _held = (_i == grab_i);
		// the resident tile (a held one leaves a dim echo in its slot)
		draw_sprite_ext(spr_tile, 2, _x, _y, tsc, tsc, 0,
			merge_colour(col[_i], c_black, .7), _held ? .25 : 1);
		if (!_held && val_str[_i] != "") {
			// Myriad's value placement: centered, TOP-aligned at +3,
			// fractionally downscaled to fit the tile
			draw_set_color(txtcol[_i]);
			draw_set_alpha(1);
			draw_text_transformed(_x + tw * .5, _y + 3, val_str[_i],
				val_sc[_i], val_sc[_i], 0);
		}
		// hover feedback when nothing is held
		if (grab_i == -1 && _i == _hov)
			draw_sprite_ext(spr_tile, 2, _x, _y, tsc, tsc, 0, col[_i], .25);
	}

	// the auto-merger's candidate pair glows in as the timer fills
	// (Myriad drew ia/ib at alpha tic/tic_ - the tell for what folds next)
	if (_t.automerge && (_i == _t.am_ia || _i == _t.am_ib))
		draw_sprite_ext(spr_tile, 2, _x, _y, tsc, tsc, 0, col[_i],
			clamp(_t.am_tic / _t.am_tic_, 0, 1) * .85);

	// merge/spawn flash
	if (glow[_i] > 0)
		draw_sprite_ext(spr_tile, 2, _x, _y, tsc, tsc, 0,
			(_tier != 0) ? col[_i] : c_white, glow[_i]);
}

// drag assist: ONLY the slot the tile would land in pulses, faintly,
// and only when the drop is legal (empty or matching tier)
if (grab_i != -1 && _hov != -1 && _hov != grab_i)
if (_t.tier[_hov] == 0 || _t.tier[_hov] == _t.tier[grab_i])
	draw_sprite_ext(spr_tile, 2, __slot_x(_hov), __slot_y(_hov), tsc, tsc, 0,
		c_gold, .12 + .08 * dsin(current_time * .35));

// ---- the ghost, drawn last so it rides above the board ----
if (grab_i != -1) {
	draw_sprite_ext(spr_tile, 2, gx + 2, gy + 4 + z, tsc, tsc, 0, c_black, .4);
	draw_sprite_ext(spr_tile, 2, gx, gy, tsc, tsc, 0,
		merge_colour(col[grab_i], c_black, .6), 1);
	draw_set_color(txtcol[grab_i]);
	draw_set_alpha(1);
	draw_text_transformed(gx + tw * .5, gy + 3, val_str[grab_i],
		val_sc[grab_i], val_sc[grab_i], 0);
}
draw_set_font(fnt);

// ---- info box, right column, width fitted to its longest line ----
var _lines = __info_lines();
var _ix = room_width - 6 - info_w;
var _iy = 60;
var _ih = array_length(_lines) * 11 + 8;
draw_sprite_ext(spr_pixel_1x1, 0, _ix, _iy, info_w, _ih, 0, c_black, .8);
draw_px_rect(_ix, _iy, info_w, _ih, c_aqua, .9);
draw_set_halign(fa_left);
draw_set_alpha(.95);
for (var _i = 0; _i < array_length(_lines); _i++) {
	draw_set_color(_lines[_i][1]);
	draw_text(_ix + 5, _iy + 4 + _i * 11, _lines[_i][0]);
}

// ---- controls: back top-right, toggles bottom-left ----
var _bbx = room_width - 62;
draw_set_halign(fa_center);
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, _bbx, 30, 56, 16, 0, c_black, .8);
draw_px_rect(_bbx, 30, 56, 16, rgb(170, 190, 230), .9);
draw_set_color(c_white);
draw_set_alpha(.9);
draw_text(_bbx + 28, 34, "back");

draw_sprite_ext(spr_pixel_1x1, 0, 6, 246, 100, 14, 0, c_black, .6);
draw_px_rect(6, 246, 100, 14, _t.automerge ? c_gold : c_white, _t.automerge ? .7 : .3);
draw_set_color(_t.automerge ? c_gold : c_white);
draw_set_alpha(.85);
draw_text(56, 248, _t.automerge ? "auto merge on" : "auto merge off");

draw_sprite_ext(spr_pixel_1x1, 0, 112, 246, 60, 14, 0, c_black, .6);
draw_px_rect(112, 246, 60, 14, c_white, .3);
draw_set_color(c_white);
draw_text(142, 248, "sort");

// the destructive one wears red
draw_sprite_ext(spr_pixel_1x1, 0, 178, 246, 60, 14, 0, c_black, .6);
draw_px_rect(178, 246, 60, 14, c_hred, .7);
draw_set_color(c_hred);
draw_text(208, 248, "reset");

// drop-aim anchor (round 2 toggle)
var _amc = g.tiles.aim_center;
draw_sprite_ext(spr_pixel_1x1, 0, 244, 246, 90, 14, 0, c_black, .6);
draw_px_rect(244, 246, 90, 14, _amc ? c_aqua : c_white, _amc ? .7 : .3);
draw_set_color(_amc ? c_aqua : c_white);
draw_text(289, 248, _amc ? "aim: tile center" : "aim: mouse");

// ---- welcome-back report: what the fabricator and automerger did
// while the game was closed (tiles_fastforward). any tap dismisses ----
if (!is_undefined(_t.report)) {
	var _r = _t.report;
	var _rl = [
		["while you were away " + crunch_time_long(_r.away * 60), c_aqua],
		["fabricated " + string(_r.fabbed) + " tiles", c_seagreen],
		["auto merges " + string(_r.merges), c_steelblue],
		["highest tier " + string(_r.hi_from) + " > " + string(_r.hi_to),
			(_r.hi_to > _r.hi_from) ? c_gold : c_white],
		["- tap anywhere -", c_gray],
	];
	draw_set_font(fnt);
	var _rw = 0;
	for (var _i = 0; _i < array_length(_rl); _i++)
		_rw = max(_rw, string_width(_rl[_i][0]));
	_rw += 12;
	var _rh = array_length(_rl) * 11 + 10;
	var _rx = 240 - _rw * .5;
	var _ry = 135 - _rh * .5;
	draw_set_halign(fa_left);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _rx, _ry, _rw, _rh, 0, c_black, .92);
	draw_px_rect(_rx, _ry, _rw, _rh, c_aqua, .9);
	draw_set_alpha(.95);
	for (var _i = 0; _i < array_length(_rl); _i++) {
		draw_set_color(_rl[_i][1]);
		draw_text(_rx + 6, _ry + 5 + _i * 11, _rl[_i][0]);
	}
}

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
