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

// ---- the backdrop and the drift are not here any more. They draw
// through proxies under the title_glow effect layer (field at 100, a
// faint twin of the wordmark at 90, the layer at 50, the gradient at
// 40 over it) so GameMaker's own glow pass lights them and nothing
// here. See the Create: __draw_field, __draw_name, __draw_grad.

// ---- the name ----
// The accent rule is the spine the whole column hangs off: title, menu
// and everything between share one x, and the eye gets one edge to
// follow instead of a centre line it has to keep finding.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_sprite_ext(spr_pixel_1x1, 0, rule_x, 44, 2, 46, 0, c_gold, .55);

// fnt_large at 2x (his call - sprite fonts take INTEGER scales, so 2 is
// the only size above 1 that is not a smear). Drawn HERE, over the glow
// pass, at full strength: its halo comes from the faint twin under the
// pass (__draw_name), so the type stays crisp and the glow stays soft.
draw_set_font(fnt_large);
draw_set_color(merge_colour(c_gold, c_white, .55));
draw_set_alpha(1);
// ONE literal, measured once (his ask: capitalise the first letter).
var _nm = "Myriad";
draw_text_transformed(lm, 46, _nm, 2, 2, 0);
var _nw = string_width(_nm) * 2;
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

	// ⚖️ EACH ROW HAS A GROUND NOW (his ask, 2026-09-10: "the title
	// screen buttons need a background or something for each of
	// them"). A low plate behind every row, from the accent column to
	// the row's far edge: black at half, a hairline of the row's own
	// colour along the top that wakes with the hover, a darker line
	// under. Plain text on a plate reads as a button; plain text on
	// the field read as a caption. (The fading gradient behind the
	// whole column was tried and scrapped; this is per row.)
	var _bx = rule_x - 3, _bw = (lm + row_w) - _bx + 4;
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _ry - 2, _bw, row_h + 4, 0, c_black, .42 + .18 * _h);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _ry - 2, _bw, 1, 0, _col, (_en ? .10 : .05) + .25 * _h);
	draw_sprite_ext(spr_pixel_1x1, 0, _bx, _ry + row_h + 1, _bw, 1, 0, c_black, .35);

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
