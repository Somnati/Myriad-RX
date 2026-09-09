/// the title: the number field as a backdrop, the name anchoring a
/// left column behind an accent rule, the menu as plain text with a
/// sliding bar, and the save card balancing from the right.
/// CONTINUE dims until a save exists.

draw_set_font(fnt);

// ---- backdrop ----
// black into the house teal, bottom-lit. A 270px-tall dark gradient
// bands hard in the 8-bit pipeline - sh_fog_dither's temporal IGN
// shimmers the steps flat (the house fix; its luminance gate leaves the
// black top untouched).
shader_set(sh_fog_dither);
shader_set_uniform_f(dith_u_time, (current_time mod 100000) / 1000);
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, 0, 0, room_width,
	room_height, 0, c_black, c_black, c_hsv(169, 190, 16), c_hsv(169, 190, 16), 1);
shader_reset();

// ---- THE FIELD ----
// The visualiser at rest. A lattice drifting down-right with cells
// breathing in the rarity ladder - the game's own picture, dimmed to a
// backdrop. The drift offsets wrap on the pitch, so it never has to
// know how long it has been running.
var _p  = fld_pitch;
var _ox = (tt * fld_dx) mod _p;
var _oy = (tt * fld_dy) mod _p;

// the lattice: 1px lines at the pitch, floored so they stay crisp while
// the drift underneath stays fractional
for (var _x = -_p; _x < room_width + _p; _x += _p)
	draw_sprite_ext(spr_pixel_1x1, 0, floor(_x + _ox), 0, 1, room_height, 0, c_white, .055);
for (var _y = -_p; _y < room_height + _p; _y += _p)
	draw_sprite_ext(spr_pixel_1x1, 0, 0, floor(_y + _oy), room_width, 1, 0, c_white, .055);

// the lit cells. Each has a hashed home on the lattice, a rung of the
// rarity ladder, and its own phase through a breath - fade up, hold,
// fade down - so the field is always mid-thought rather than pulsing
// in time with itself.
var _cols = ceil(room_width / _p) + 2;
var _rows = ceil(room_height / _p) + 2;
for (var _i = 0; _i < fld_n; _i++) {
	var _hx = frac(sin((_i + 1) * 127.1) * 43758.5453);
	var _hy = frac(sin((_i + 1) * 269.5) * 28001.83);
	var _hp = frac(sin((_i + 1) * 419.2) * 15731.71);
	// dsin over a wrapped phase: 0 at both ends, 1 in the middle, and
	// the wrap is where the cell is invisible - so it never pops
	var _ph = frac(tt * .0022 + _hp);
	var _a  = dsin(_ph * 180);
	if (_a <= .01) continue;

	var _cx = floor(_hx * _cols) * _p + _ox - _p;
	var _cy = floor(_hy * _rows) * _p + _oy - _p;
	var _c  = vis_tier_color(2 + (_i mod 7));

	// the cell body, then a brighter inner square on the ones nearer
	// their peak: a block finishing is the moment worth seeing, and it
	// is what the visualiser does all game
	draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx) + 1, floor(_cy) + 1,
		_p - 1, _p - 1, 0, _c, _a * .10);
	if (_a > .72)
		draw_sprite_ext(spr_pixel_1x1, 0, floor(_cx) + 7, floor(_cy) + 7,
			_p - 13, _p - 13, 0, _c, (_a - .72) * .55);
}
draw_set_alpha(1);

// a soft wash behind the name, so the type has somewhere to sit
var _gw = sprite_get_width(spr_vis_glow_soft);
draw_sprite_ext(spr_vis_glow_soft, 0, lm + 40, 68, 300 / _gw, 190 / _gw, 0,
	c_hsv(30, 180, 255), .07);

// ---- the name ----
// The accent rule is the spine the whole column hangs off: title, menu
// and everything between share one x, and the eye gets one edge to
// follow instead of a centre line it has to keep finding.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, rule_x, 44, 2, 46, 0, c_gold, .55);

// LARGE OUTLINE at 2x integer scale (sprite fonts take integer scales -
// the baked outline replaces the old hand-drawn drop shadow, one draw)
draw_set_font(fnt_large_outline);
draw_set_color(merge_colour(c_gold, c_white, .55));
draw_set_alpha(1);
draw_text_transformed(lm, 46, "myriad", 2, 2, 0);
var _nw = string_width("myriad") * 2;
draw_set_color(c_gold);
draw_text_transformed(lm + _nw + 8, 46, "rx", 2, 2, 0);

draw_set_font(fnt);
// a hairline under the name, fading out to the right - it stops the
// wordmark floating without drawing a box around it
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, lm, 78, 190, 1, 0,
	c_gold, c_black, c_black, c_gold, .3);
draw_set_color(sett_ink);
draw_set_alpha(.45);
draw_text(lm, 84, "remix edition");
draw_set_alpha(1);

// ---- the menu ----
// No chrome. The label brightens, slides right, and grows a bar beside
// it, all off the one hover ease - a row you are pointing at should
// look pointed at, not inflated.
for (var _i = 0; _i < array_length(items); _i++) {
	var _ry = row_y0 + _i * row_p;
	var _en = (items[_i] != "continue") || has_save;
	var _h  = _en ? hov[_i] : 0;

	var _col = c_white;
	if (_i == 0) _col = c_gold;              // the one you came here to press
	if (items[_i] == "quit") _col = c_gray;
	if (!_en) _col = c_gray;

	// the sliding bar: it grows from the row's middle so the motion
	// reads as the row waking rather than as a box arriving
	if (_h > .01) {
		var _bh = 3 + 10 * _h;
		draw_sprite_ext(spr_pixel_1x1, 0, rule_x, _ry + (row_h - _bh) * .5,
			2, _bh, 0, _col, .25 + .6 * _h);
	}

	// the label. x floors so glyphs never straddle a pixel while the
	// slide is mid-ease (the shimmer his old bounce taught us about)
	draw_set_color(_col);
	draw_set_alpha(_en ? (.55 + .45 * _h) : .28);
	draw_text(floor(lm + 4 * _h), _ry + 3, items[_i]);
}
draw_set_alpha(1);

// ---- the save card, right ----
// It balances the left column instead of hovering over the buttons, and
// it is the answer to "what am I continuing" - so it earns the width.
var _rx = room_width - 30;
draw_set_halign(fa_right);
if (has_save && cont.valid) {
	var _cn  = (cont.name != "") ? cont.name : g.profile_name[g.profile];
	var _cc  = (cont.color >= 0) ? cont.color : g.profile_color[g.profile];
	var _ago = crunch_time_ago(cont.datetime);

	draw_set_color(sett_ink);
	draw_set_alpha(.3);
	draw_text(_rx, 138, "last run");
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _rx - 110, 150, 110, 1, 0,
		c_black, _cc, _cc, c_black, .35);

	draw_set_color(_cc);
	draw_set_alpha(.9);
	draw_text(_rx, 156, _cn);
	draw_set_color(g.profit_color);
	draw_set_alpha(.75);
	draw_text(_rx, 168, crunch_arb(cont.profit));
	if (_ago != "") {
		draw_set_color(sett_ink);
		draw_set_alpha(.4);
		draw_text(_rx, 180, _ago);
	}
} else {
	draw_set_color(c_gray);
	draw_set_alpha(.3);
	draw_text(_rx, 156, "no save yet");
}
draw_set_alpha(1);

// version tag, bottom-left (game_version = THE string, main_macros - a
// release bump is one line there) + the footnote under it. The gear
// holds the opposite corner.
draw_set_halign(fa_left);
draw_set_color(sett_ink);
draw_set_alpha(.5);
draw_text(6, room_height - 22, game_version);
draw_set_alpha(.3);
draw_text(6, room_height - 12, "somnati - engine build");
draw_set_color(c_white);
draw_set_alpha(1);
