/// the whole table: fab/automerge bars, board, ghost, info box,
/// controls. house primitives only; spr_tile frame 2 is the fill
/// (the same subimage Myriad drew for everything). tile values render
/// in fnt_large - the Myriad tile font - everything else stays fnt

var _t = g.tiles;

draw_set_font(fnt);
draw_set_halign(fa_center);

// ---- THE TITLE STRIP, the same one every other screen wears ----
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y, room_width, strip_h, 0,
	c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y + strip_h - 1, room_width, 1, 0,
	sett_ink, .25);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, strip_y + 5, "tiles");

// the hopper's contents ride the strip, clear of the back button
if (_t.stored > 0) {
	draw_set_halign(fa_right);
	draw_set_color((_t.stored >= _t.stored_max) ? c_horange : c_seagreen);
	draw_set_alpha(.9);
	draw_text(room_width - 70, strip_y + 5,
		"hopper " + string(_t.stored) + "/" + string(_t.stored_max));
	draw_set_halign(fa_left);
}

// ---- THE FABRICATOR BARS, snug under the strip (his ask) ----
// Myriad DE's spr_progressbar, drawn DE's way: frame 0 sliced with
// draw_sprite_part_ext is the fill, frame 1 is the leading-edge cap
// riding its right end. The sprite is 70 wide and gets stretched to
// the room, which is what every Myriad meter does with it.
var _psw = sprite_get_width(spr_progressbar);
var _xs  = room_width / _psw;

var _fp = clamp(_t.fab / _t.fab_t, 0, 1);
draw_sprite_ext(spr_progressbar, 0, 0, bar_y, _xs, 1, 0, c_black, .8);
draw_sprite_part_ext(spr_progressbar, 0, 0, 0, _fp * (_psw - 1), bar_h,
	0, bar_y, _xs, 1, c_seagreen, .95);
if (_fp > .01 && _fp < 1)
	draw_sprite_ext(spr_progressbar, 1, _fp * (room_width - _xs), bar_y,
		_xs, 1, 0, merge_colour(c_seagreen, c_white, .5), .95);

if (_t.automerge) {
	// the merger cools from steelblue toward red as the pool starves
	// it (thr_am) - the fill crawls slower too, this says WHY
	var _amthr = _t[$ "thr_am"] ?? 1;
	var _ac = merge_colour(c_hred, c_steelblue, _amthr);
	var _ap = clamp(_t.am_tic / _t.am_tic_, 0, 1);
	draw_sprite_ext(spr_progressbar, 0, 0, bar_y + bar_h, _xs, 1, 0, c_black, .8);
	draw_sprite_part_ext(spr_progressbar, 0, 0, 0, _ap * (_psw - 1), bar_h,
		0, bar_y + bar_h, _xs, 1, _ac, .95);
	if (_ap > .01 && _ap < 1)
		draw_sprite_ext(spr_progressbar, 1, _ap * (room_width - _xs),
			bar_y + bar_h, _xs, 1, 0, merge_colour(_ac, c_white, .5), .95);
}
draw_set_halign(fa_center);

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
			// ⚖️ CENTRED ON THE TILE, both ways (his report). It was
			// TOP-aligned at a fixed +3, and every tile's value is
			// downscaled by a DIFFERENT amount to fit - so the taller
			// the string, the further from centre it sat. Middle
			// alignment against the tile's own centre is invariant to
			// the scale, which is the only way a grid of them lines up.
			draw_set_valign(fa_middle);
			draw_set_color(txtcol[_i]);
			draw_set_alpha(1);
			draw_text_transformed(_x + tw * .5, _y + th * .5, val_str[_i],
				val_sc[_i], val_sc[_i], 0);
			draw_set_valign(fa_top);
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
	draw_set_valign(fa_middle);
	draw_text_transformed(gx + tw * .5, gy + th * .5, val_str[grab_i],
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

// ================= THE UPGRADE DRAWER =================
// Out from the LEFT on a swipe right (his ask). Drawn LAST so it slides
// OVER the board rather than under it - a drawer that the thing it
// covers draws through is not a drawer.
if (dr_open > .001) {
	var _fx = __dr_face();
	var _tt = g.tiles;
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	// the body, to the bottom edge - the house drawer shape
	draw_sprite_ext(spr_pixel_1x1, 0, _fx, strip_y, dr_w, room_height - strip_y,
		0, c_black, .9 * min(1, dr_open * 2));
	draw_sprite_ext(spr_pixel_1x1, 0, _fx + dr_w - 1, strip_y, 1,
		room_height - strip_y, 0, c_aqua, .35);

	draw_set_color(c_aqua);
	draw_set_alpha(.6 * dr_open);
	draw_text(_fx + 6, strip_y + 5, "shards");
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_set_alpha(.95 * dr_open);
	draw_text(_fx + dr_w - 6, strip_y + 5,
		(_tt.shards >= arb(1)) ? crunch_arb(_tt.shards) : "0");
	draw_set_halign(fa_left);

	var _ucfg = tile_upg_config();
	for (var _k = 0; _k < array_length(_ucfg); _k++) {
		var _ur = __upg_r(_k);
		var _uq = (_k < array_length(uq)) ? uq[_k]
			: { ok : false, cost : arb(1), lv : 0, txt : "-" };
		var _uc = _ucfg[_k];
		var _ua = dr_open;

		var _ucol = merge_colour(c_hsv(168, 160, 5), c_hsv(169, 186, 5), .2);
		draw_sprite_ext(spr_pixel_1x1, 0, _ur.x, _ur.y, _ur.w, _ur.h, 0,
			_ucol, _ua);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _ur.x, _ur.y,
			_ur.w, 1, 0, _ucol, c_black, c_black, _ucol, .5 * _ua);
		draw_sprite_ext(spr_pixel_1x1, 0, _ur.x, _ur.y, 2, _ur.h, 0, c_aqua,
			(_uq.ok ? .9 : .3) * _ua);

		draw_set_color(_uq.ok ? c_white : rgb(120, 130, 150));
		draw_set_alpha(.95 * _ua);
		draw_text(_ur.x + 7, _ur.y + 3, _uc.name);
		draw_set_halign(fa_right);
		draw_set_color(rgb(120, 130, 150));
		draw_set_alpha(.6 * _ua);
		draw_text(_ur.x + _ur.w - 6, _ur.y + 3, "lv " + string(_uq.lv));
		draw_set_halign(fa_left);

		var _bx2 = _ur.x + 6;
		var _bw2 = _ur.w - 12;
		draw_sprite_ext(spr_pixel_1x1, 0, _bx2, _ur.y + 13, _bw2, 11, 0,
			_uq.ok ? merge_colour(c_black, c_aqua, .2) : c_black, .85 * _ua);
		draw_px_rect(_bx2, _ur.y + 13, _bw2, 11, _uq.ok ? c_aqua : c_gray,
			(_uq.ok ? .8 : .3) * _ua);
		draw_set_halign(fa_center);
		draw_set_color(_uq.ok ? c_white : rgb(120, 130, 150));
		draw_set_alpha((_uq.ok ? .95 : .5) * _ua);
		draw_text(_bx2 + _bw2 / 2 + 1, _ur.y + 15, _uq.txt);
		draw_set_halign(fa_left);
	}

	draw_set_color(c_aqua);
	draw_set_alpha(.55 * dr_open);
	draw_text(_fx + 6, upg_y + upg_n * (upg_h + 4) + 4,
		"+" + ((_tt.gps >= arb(1)) ? crunch_arb(_tt.gps) : "0") + " a second");
	if (!TILES_LIVE) {
		draw_set_color(c_horange);
		draw_set_alpha(.7 * dr_open);
		draw_text(_fx + 6, upg_y + upg_n * (upg_h + 4) + 15, "preview - the board");
		draw_text(_fx + 6, upg_y + upg_n * (upg_h + 4) + 24, "is not saved yet");
	}
}

// THE EDGE TAB, always. A drawer nobody can see is a drawer nobody
// opens, so the handle stays on screen and pulses gently while there is
// something affordable behind it.
var _tabx = __dr_face() + dr_w;
var _any = false;
for (var _k = 0; _k < array_length(uq); _k++) if (uq[_k].ok) _any = true;
draw_sprite_ext(spr_pixel_1x1, 0, _tabx - dr_tab, strip_y + strip_h + 24,
	dr_tab, 60, 0, c_black, .8);
draw_sprite_ext(spr_pixel_1x1, 0, _tabx - 2, strip_y + strip_h + 24,
	2, 60, 0, c_aqua, _any ? (.55 + .35 * dsin(current_time * .25)) : .35);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
