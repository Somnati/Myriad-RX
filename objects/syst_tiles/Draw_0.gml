/// the whole table: fab/automerge bars, board, ghost, info box,
/// controls. house primitives only.
///
/// ⚖️ TILES ARE SHAPES NOW, not one subimage (his ask, 2026-09-09): every
/// tile draw goes through tile_shape_draw, which picks a silhouette from
/// the TIER - rectangle, rounded, diamond, circle, hexagon, octagon, and
/// round again. spr_tile no longer paints anything; it survives as the
/// SIZE authority, since tw/th are still measured from it. Read
/// tile_shape_draw for why shape earns its place on a merge board.
///
/// tile values render in fnt_large - the Myriad tile font - everything
/// else stays fnt

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

// THE SHARD COUNT TOP RIGHT (his ask), clear of the back button at
// room_width-62, with the rate beside it. Both were inside the drawer,
// which is the wrong place for the two numbers you want while playing
// the board - you had to open a panel OVER the board to read how the
// board was doing.
// ⚖️ DRAWN AFTER THE DRAWER, not here (his ask): "you would need to see
// it to know how much you have while buying". Everything else in the
// strip goes behind the panel; the currency you are spending is the one
// thing that must not. __draw_shards is called from the end of
// __draw_drawer, which is the last thing this room draws.

// the hopper joins them while it has anything in it
if (_t.stored > 0) {
	draw_set_color((_t.stored >= _t.stored_max) ? c_horange : c_seagreen);
	draw_set_alpha(.85);
	// the strip's right end is the hopper's now - the count and the
	// rate moved to the spark above the board
	draw_set_halign(fa_right);
	draw_text(room_width - 6, strip_y + 5,
		"hopper " + string(_t.stored) + "/" + string(_t.stored_max));
}
draw_set_halign(fa_left);

// ---- THE FABRICATOR BARS, snug under the strip ----
// ⚖️ THIS IS DE'S MODULE METER, and it is NOT spr_progressbar - I used
// that sprite first and it does not match, because DE's module room
// (syst_rm_modules' Draw) builds its bars from spr_pixel_1x1 with a
// TWO-TONE TRICKLE:
//   a WHITE bar tracking the fill on a SLOW trickle, drawn first
//   the GREEN bar tracking it on a FAST trickle, drawn over
// While the bar climbs the green covers the white entirely. The moment
// a tile is fabricated the green snaps back to nothing and the white is
// left standing - a remnant that melts away over the next second. That
// remnant IS the effect: it is how you see that something just landed
// without looking away from the board.
var _fp = clamp(_t.fab / _t.fab_t, 0, 1);
// DE's own guard: a fill that has gone BACKWARDS means the bar reset,
// so the slow tone snaps down to meet it instead of sliding
if (_fp < bar_slow) { bar_slow = _fp; bar_fast -= 1; }
// trickle's fourth argument is a SNAP TOLERANCE, not a flag - DE passes
// `false` here, which is 0, meaning "never snap early". Written as 0 so
// nobody reads it as a boolean and helpfully turns it on.
bar_fast = trickle(bar_fast, _fp, 1,  0);
bar_slow = trickle(bar_slow, _fp, 12, 0);

draw_sprite_ext(spr_pixel_1x1, 0, 0, bar_y, room_width, 3, 0, c_black, .8);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bar_y,
	room_width * clamp(bar_slow, 0, 1), 3, 0, c_white, .9);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bar_y,
	room_width * clamp(bar_fast, 0, 1), 3, 0, c_seagreen, 1);

if (_t.automerge) {
	// the merger cools from steelblue toward red as the pool starves
	// it (thr_am) - the fill crawls slower too, this says WHY
	var _amthr = _t[$ "thr_am"] ?? 1;
	var _ac = merge_colour(c_hred, c_steelblue, _amthr);
	var _ap = clamp(_t.am_tic / _t.am_tic_, 0, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bar_y + 3, room_width, 3, 0, c_black, .8);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, bar_y + 3,
		room_width * _ap, 3, 0, _ac, .95);
}
draw_set_halign(fa_center);

// ---- the board ----
var _am0 = __aim(); // the drop's true target (mouse or tile center)
var _hov = __slot_at(_am0[0], _am0[1]);
// ⚖️ FLAT SHAPES, NO MATERIAL (his call, 2026-09-09, after seeing both).
// The tiles were raymarched solids for one commit - real bevels, real
// specular, iridescence on the rim - and before that they wore a 2D
// material pass. Neither earned its place on a 13px object that has to
// carry a number, and he chose the version that just draws the outline.
// The six-shape cycle stays: it is the channel that makes neighbouring
// tiers differ, and that is gameplay rather than decoration.
draw_set_font(fnt_large);
for (var _i = 0; _i < _t.slots; _i++) {
	var _x = __slot_x(_i);
	var _y = __slot_y(_i);
	var _tier = _t.tier[_i];

	if (_tier == 0) {
		// empty socket: Myriad's dark-theme surface tint. Flat on
		// purpose - a socket is the shape of the SPACE, not a solid.
		tile_shape_draw(0, _x, _y, tw, th, slot_col, .9);
	} else {
		var _held = (_i == grab_i);
		// the resident tile (a held one leaves a dim echo in its slot)
		tile_shape_draw(_tier, _x, _y, tw, th,
			merge_colour(col[_i], c_black, .7), _held ? .25 : 1);
		if (!_held && val_str[_i] != "") {
			// ⚖️ CENTRED BY ARITHMETIC, NOT BY valign. fnt_large is a
			// SPRITE font, and the house note is explicit that those
			// take integer scales - the tile values are drawn at
			// FRACTIONAL ones to fit, and fa_middle against a fractional
			// scale is where the vertical went wrong. Measuring the
			// string and halving the leftover works whatever the font
			// is, and it leaves the align state alone, so nothing that
			// draws afterwards inherits a setting from in here.
			draw_set_color(txtcol[_i]);
			draw_set_alpha(1);
			draw_text_transformed(_x + tw * .5, __val_y(_y, val_sc[_i]),
				val_str[_i], val_sc[_i], val_sc[_i], 0);
		}
		// hover feedback when nothing is held
		if (grab_i == -1 && _i == _hov)
			tile_shape_draw(_tier, _x, _y, tw, th, col[_i], .25);
	}

	// the auto-merger's candidate pair glows in as the timer fills
	// (Myriad drew ia/ib at alpha tic/tic_ - the tell for what folds next)
	if (_t.automerge && (_i == _t.am_ia || _i == _t.am_ib))
		tile_shape_draw(_tier, _x, _y, tw, th, col[_i],
			clamp(_t.am_tic / _t.am_tic_, 0, 1) * .85);

	// merge/spawn flash
	if (glow[_i] > 0)
		tile_shape_draw(_tier, _x, _y, tw, th,
			(_tier != 0) ? col[_i] : c_white, glow[_i]);
}

// drag assist: ONLY the slot the tile would land in pulses, faintly,
// and only when the drop is legal (empty or matching tier)
if (grab_i != -1 && _hov != -1 && _hov != grab_i)
if (_t.tier[_hov] == 0 || _t.tier[_hov] == _t.tier[grab_i])
	tile_shape_draw(g.tiles.tier[_hov], __slot_x(_hov), __slot_y(_hov), tw, th,
		c_gold, .12 + .08 * dsin(current_time * .35));

// ---- the ghost, drawn last so it rides above the board ----
if (grab_i != -1) {
	tile_shape_draw(_t.tier[grab_i], gx + 2, gy + 4 + z, tw, th, c_black, .4);
	tile_shape_draw(_t.tier[grab_i], gx, gy, tw, th,
		merge_colour(col[grab_i], c_black, .6), 1);
	draw_set_color(txtcol[grab_i]);
	draw_set_alpha(1);
	// the same arithmetic as the board's, so a held tile's number sits
	// exactly where it sat in its slot - it was setting fa_middle and
	// never putting it back, which shifted every piece of text drawn
	// after it while a tile was up (his report)
	draw_text_transformed(gx + tw * .5, __val_y(gy, val_sc[grab_i]),
		val_str[grab_i],
		val_sc[grab_i], val_sc[grab_i], 0);
}
draw_set_font(fnt);

// ---- info box, LEFT column, width fitted to its longest line ----
// It swapped sides with the drawer (his ask): the upgrades own the right
// edge now, so the readout takes the left rather than sitting under
// whatever slides over it.
var _lines = __info_lines();
var _ix = 6;
// ⚖️ UNDER THE BANNERS (his report, 2026-09-10: "the banners get in the
// way of it"). syst_banner stacks its lines from y 37 down the left
// edge, 11px each - welcome, autosaved, progress saved - and the box
// at 60 sat under the third line. 100 clears a five-deep stack and
// still ends above the bottom row.
var _iy = 100;
var _ih = array_length(_lines) * 11 + 8;
draw_sprite_ext(spr_pixel_1x1, 0, _ix, _iy, info_w, _ih, 0, c_black, .8);
draw_px_rect(_ix, _iy, info_w, _ih, c_aqua, .9);
draw_set_halign(fa_left);
draw_set_alpha(.95);
for (var _i = 0; _i < array_length(_lines); _i++) {
	draw_set_color(_lines[_i][1]);
	draw_text(_ix + 5, _iy + 4 + _i * 11, _lines[_i][0]);
}

// ---- controls: toggles bottom-left ----
// (the BACK button is gone, his call. It was the only navigation this
// screen drew for itself, and every other room in the game leaves that
// to the header's burger - a per-room back button is a second way to do
// one thing, and it was the piece that kept colliding with the upgrades
// drawer as that grew.)
draw_set_alpha(1);

// ---- THE DEBUG DRAWER (left) and its chip (bottom-left) ----
// the chip: always out, an arrow that points the way the panel will go
var _dc = __dbg_chip();
draw_sprite_ext(spr_pixel_1x1, 0, _dc.x, _dc.y, _dc.w, _dc.h, 0, c_black, .6);
draw_px_rect(_dc.x, _dc.y, _dc.w, _dc.h, c_white, .3);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_set_alpha(.85);
draw_text(_dc.x + _dc.w * .5 + 1, _dc.y + 3, (dbg_want > 0) ? "<" : ">");
draw_set_halign(fa_left);

// the panel: slides in from the left edge, under the strip and the
// meter bars, over the info box - the mirror of the upgrade drawer's
// treatment, without its pixelated glass (this one is furniture)
if (dbg_open > .001) {
	var _dx = __dbg_x();
	var _da = dbg_open;
	draw_sprite_ext(spr_pixel_1x1, 0, _dx, dr_top, dbg_w, room_height - dr_top - 22, 0,
		c_black, .82 * _da);
	draw_sprite_ext(spr_pixel_1x1, 0, _dx + dbg_w - 1, dr_top, 1, room_height - dr_top - 22, 0,
		c_white, .2 * _da);
	draw_set_color(rgb(120, 130, 150));
	draw_set_alpha(.6 * _da);
	draw_text(_dx + 6, dr_top + 1, "board");

	for (var _k = 0; _k < array_length(dbg_rows); _k++) {
		var _r = __dbg_r(_k);
		var _lbl = dbg_rows[_k];
		var _col = c_white, _on = false, _fa = .3;
		switch (_k) {
			case 0: _on = _t.automerge; _lbl = _on ? "auto merge on" : "auto merge off";
			        _col = _on ? c_gold : c_white; _fa = _on ? .7 : .3; break;
			case 2: _on = g.tiles.aim_center; _lbl = _on ? "aim: tile center" : "aim: mouse";
			        _col = _on ? c_aqua : c_white; _fa = _on ? .7 : .3; break;
			case 3: _lbl = (arm_rs > 0) ? "sure?" : "reset"; _col = c_hred; _fa = .7; break;
			case 4: _lbl = (arm_ru > 0) ? "sure?" : "reset upgrades"; _col = c_hred; _fa = .7; break;
		}
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_black, .6 * _da);
		draw_px_rect(_r.x, _r.y, _r.w, _r.h, _col, _fa * _da);
		draw_set_halign(fa_center);
		draw_set_color(_col);
		draw_set_alpha(.85 * _da);
		draw_text(_r.x + _r.w * .5, _r.y + 2, _lbl);
		draw_set_halign(fa_left);
	}
}
draw_set_alpha(1);

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
