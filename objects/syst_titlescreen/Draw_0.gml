/// the title: soft drifting blocks as a backdrop, the name anchoring a
/// left column behind an accent rule, the menu as plain text with a
/// sliding bar, and the save card balancing from the right.
/// CONTINUE dims until a save exists.
///
/// ⚖️ NOTHING HERE SNAPS TO A PIXEL (his call, 2026-09-08). The house
/// rule elsewhere is to floor text anchors so glyphs cannot shimmer
/// across a boundary mid-ease, and it earns that everywhere a widget
/// slides against a busy background. Here it was buying nothing and
/// costing the one thing this screen is for: motion so slow that a
/// whole-pixel step reads as a stutter rather than as drift. Positions
/// stay fractional; the GPU rasterises them.

draw_set_font(fnt);

// ---- backdrop ----
// black into the house teal, bottom-lit. A 270px-tall dark gradient
// bands hard in the 8-bit pipeline - sh_fog_dither's temporal IGN
// shimmers the steps flat (the house fix; its luminance gate leaves the
// black top untouched).
shader_set(sh_fog_dither);
shader_set_uniform_f(dith_u_time, (current_time mod 100000) / 1000);
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, 0, 0, room_width,
	room_height, 0, c_black, c_black, c_hsv(169, 190, 18), c_hsv(169, 190, 18), 1);
shader_reset();

// ---- THE DRIFT ----
// ⚖️ THE LATTICE IS GONE (his verdict on the first attempt: "the
// background sucks"). Drawing the visualiser's grid literally gave the
// screen graph paper - a regular 27px mesh reads as a debug overlay
// however dim it is, because regularity is the thing the eye locks onto
// first and there was nothing else for it to look at.
//
// The idea was right and the execution was too literal. What is left is
// the game's SHAPE without its ruler: a few large soft blocks, well out
// of focus, drifting up-right at different speeds and breathing through
// the rarity ladder. Each rides a glow so it reads as light rather than
// as a rectangle, and they overlap - depth comes from occlusion and
// speed, which is what the parallax starfield was reaching for and what
// a flat grid can never have.
var _n = array_length(blk_h);
for (var _i = 0; _i < _n; _i++) {
	var _b = blk_h[_i];

	// travel up-right forever, wrapping on a margin wider than the
	// block so nothing ever pops in at an edge
	var _sp = _b.spd;
	var _m  = _b.size + 60;
	var _bx = ((_b.x0 * (room_width + _m) + tt * _sp * 1.7) mod (room_width + _m)) - _m * .5;
	var _by = ((_b.y0 * (room_height + _m) - tt * _sp) mod (room_height + _m));
	if (_by < 0) _by += room_height + _m;
	_by -= _m * .5;

	// its own slow breath, so the field is always mid-thought rather
	// than pulsing in time with itself
	var _a = .5 + .5 * dsin(tt * _b.br + _b.ph);
	var _c = vis_tier_color(_b.tier);

	// light first, then the block: the glow is most of what you see and
	// the square is only its core
	var _gs = (_b.size * 2.6) / sprite_get_width(spr_vis_glow_soft);
	draw_sprite_ext(spr_vis_glow_soft, 0, _bx + _b.size * .5, _by + _b.size * .5,
		_gs, _gs, 0, _c, (.05 + .05 * _a) * _b.dim);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _by, _b.size, _b.size, 0,
		_c, (.05 + .06 * _a) * _b.dim);
}

// ---- the motes ----
// The profit bits, at rest. A handful of slow sparks rising through the
// blocks - the one moving thing small enough to read as detail rather
// than as another shape competing with the menu.
for (var _i = 0; _i < 22; _i++) {
	var _hx = frac(sin((_i + 1) * 91.3) * 41231.7);
	var _hs = .10 + frac(sin((_i + 1) * 53.7) * 22101.3) * .22;
	var _mx = _hx * room_width + dsin(tt * .35 + _i * 37) * 5;
	var _my = room_height + 8 - ((tt * _hs + _hx * 400) mod (room_height + 16));
	draw_sprite_ext(spr_pixel_1x1, 0, _mx, _my, 1, 1, 0,
		c_gold, .10 + .18 * abs(dsin(tt * .9 + _i * 61)));
}

// a soft wash behind the name, so the type has somewhere to sit
var _gw = sprite_get_width(spr_vis_glow_soft);
draw_sprite_ext(spr_vis_glow_soft, 0, lm + 40, 68, 300 / _gw, 190 / _gw, 0,
	c_hsv(30, 180, 255), .09);

// ---- the name ----
// The accent rule is the spine the whole column hangs off: title, menu
// and everything between share one x, and the eye gets one edge to
// follow instead of a centre line it has to keep finding.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, rule_x, 44, 2, 46, 0, c_gold, .55);

// fnt_large at 2x (his call - sprite fonts take INTEGER scales, so 2 is
// the only size above 1 that is not a smear). The outline variant is
// gone with it, which is why the wash above exists: the type needs
// separation from the drift, and a soft ground gives it that without
// baking a black rim into every glyph.
draw_set_font(fnt_large);
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

	draw_set_color(_col);
	draw_set_alpha(_en ? (.55 + .45 * _h) : .28);
	draw_text(lm + 4 * _h, _ry + 3, items[_i]);
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
