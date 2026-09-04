/// DE's overlay, portrait: the room dark under the header, the stat
/// lines, the verdict, the big fill-bar banner, the run footer.
/// Draw-only - every number comes from calc (Step).
if (!visible) exit;
if (alpha <= 0) exit;

var _hh = instance_exists(obj_ui_header) ? obj_ui_header.sprite_height : 16;
var _cx = room_width * .5;

// ---- the room goes dark below the header ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, _hh - 1, room_width, room_height,
	0, c_black, lerp(0, .8, balpha * alpha));

// ---- banner state: colour + label (DE's triage) ----
var _blend = c_aqua;
var _n = name;
if (!calc.can) { _blend = c_hred; _n = name_error; }
if (calc.can && calc.cool > 0) { _blend = c_lavender; _n = "COOLING DOWN"; }
if (!calc.can && calc.lack >= arb(1))
	_n = "NEED " + string_upper(crunch_arb(calc.lack));

// the fill: the hold, or the press timer counting down (DE's bar
// rides the clock until the press unlocks)
var _fill = hp / 100;
if (calc.cool > 0 && calc.can) _fill = clamp(1 - calc.cool / 600, 0, 1);

// ---- the stat lines under the header ----
var _sy = _hh + 12;
draw_set_font(fnt);
draw_set_halign(fa_center);
draw_set_alpha(alpha);
draw_set_color(c_white);
draw_text(_cx, _sy, "current units");
draw_set_color(c_hred);
draw_text(_cx, _sy + 9, (g.rebirth.units >= arb(1)) ? crunch_arb(g.rebirth.units) : "0");
draw_set_color(c_white);
draw_text(_cx, _sy + 22, "unit boost");
draw_set_color(c_gold);
draw_text(_cx, _sy + 31, "x" + crunch_arb(rebirth_boost()));

// ---- the verdict block above the banner (DE's lines) ----
if (calc.can) {
	draw_set_color(c_aqua);
	draw_text(_cx, by - 46, "you'll receive");
	draw_set_font(fnt_large_outline);
	draw_set_color(c_hred);
	draw_text(_cx, by - 36, "+" + crunch_arb(calc.units) + " units");
	draw_set_font(fnt);
	if (calc.tc < 1) {
		draw_set_color(c_lavender);
		draw_text(_cx, by - 22, "early: x" + string_format(calc.tc * calc.tc, 1, 2));
	}
} else {
	draw_set_color(c_aqua);
	draw_text(_cx, by - 58, "the more profit\nyou hold, the more\nunits you'll get");
	draw_set_font(fnt_large_outline);
	draw_set_color(c_white);
	draw_text(_cx, by - 28, "-come back later-");
	draw_set_font(fnt);
}
if (calc.cool > 0 && calc.can) {
	draw_set_color(c_hred);
	draw_text(_cx, by - 10, "cooling down " + crunch_time_long(calc.cool * 60));
}

// ---- the banner: DE's sprite popping in y, the fill centre-out ----
var _ba = balpha * alpha;
draw_sprite_ext(sprite_index, 0, bx, by + (8.5 * (1 - balpha)), image_xscale,
	scale, 0, merge_colour(_blend, c_black, .8), _ba);
draw_sprite_ext(spr_pixel_1x1, 0, bx + bw * (1 - _fill) * .5, by + 1,
	bw * _fill, 15, 0, merge_colour(_blend, c_black, .5), _ba);
draw_px_rect(bx, by, bw, 17, _blend, .8 * _ba);
draw_set_font(fnt_large);
draw_set_color(_blend);
draw_set_alpha(_ba);
draw_text_transformed(_cx, by + 5, _n, ts, ts, 0);
if (glow > 0)
	draw_sprite_ext(sprite_index, 0, bx, by + (8.5 * (1 - balpha)), image_xscale,
		scale, 0, c_white, glow * _ba);
draw_set_font(fnt);
draw_set_alpha(alpha);
if (calc.can && calc.cool <= 0) {
	draw_set_color(merge_colour(_blend, c_white, .5));
	draw_text(_cx, by + 21, "hold to rebirth");
}

// ---- the run footer (DE's lines) ----
var _fy = by + 34;
draw_set_color(c_gray);
draw_text(_cx, _fy, "total rebirths " + string(g.rebirth.total));
if (g.rebirth.total > 0) {
	draw_text(_cx, _fy + 9, "last run +" + ((g.rebirth.prev_units >= arb(1))
		? crunch_arb(g.rebirth.prev_units) : "0") + " units");
	draw_text(_cx, _fy + 18, "in " + crunch_time_long(g.rebirth.prev_secs * 60));
}
draw_set_color(merge_colour(c_gray, c_black, .3));
draw_text(_cx, room_height - 12, "tap outside to close");

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
