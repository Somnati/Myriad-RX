draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _dim = rgb(120, 130, 150);

// ---- the ground: the room shows through, blurred (ui_blur_tick) ----
// (no ground of its own: obj_menu2_bck paints the plate + gradients UNDER the blur - his "menu blur" ask)
// everything below rides one ease: it slides up into its seat and
// fades in (the settings recipe, one part - the pages are dense enough
// that dealing rows one by one read as a stutter here)
var _ea = ui_anim_in(oa, 1);
if (_ea < .001) exit;
var _eo = (1 - _ea) * UI_IN_DEAL;
if (_eo != 0) matrix_set(matrix_world, matrix_build(0, _eo, 0, 0, 0, 0, 1, 1, 1));
ui_fade_set(_ea);

// THE PAGE AND ITS HOVER, FIRST. The dials page fills the room with
// fourteen rows and has no footer band left, so its help line has to
// ride the title strip - which is drawn before the rows are. Building
// both up here is what lets either band show it.
var _rows = __page_rows();
var _hov  = -1;
if (input_free(ui_layer_overlay))   // the panel's own rung (it holds the room at 100)
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _hy = __row_y(_i);
	if (point_in_rectangle(mouse_x, mouse_y, cont_x, _hy,
		cont_x + cont_w, _hy + row_h)) _hov = _i;
}
var _help = (_hov >= 0 && variable_struct_exists(_rows[_hov], "help"))
	? _rows[_hov].help : "";

// ---- the title strip ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby + 15, room_width, 1, 0, sett_ink, .25);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 5, "automation");
if (tab == 0) {
	draw_set_halign(fa_right);
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(room_width - 8, bby + 5,
		(_help != "") ? _help
		: ((g.autom.lock_pct > 0)
			? ("reserve is holding " + ((profit_reserved() >= arb(1))
				? crunch_arb(profit_reserved()) : "0") + " out of spending")
			: "the % is a CAP: the most one buy may cost, out of spendable profit"));
	draw_set_halign(fa_left);
}

// (no back button - the burger is the X)

// ---- the rail ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, rail_w, room_height - list_y, 0,
	c_black, .55);
for (var _t = 0; _t < NTAB; _t++) {
	var _r  = __tab_rect(_t);
	var _on = (tab == _t);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0,
		_on ? merge_colour(tcol[_t], c_black, .6) : c_black, _on ? .95 : .35);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 2, _r.h, 0, tcol[_t],
		_on ? .95 : .3);
	draw_set_color(_on ? c_white : merge_colour(tcol[_t], c_white, .35));
	draw_set_alpha(_on ? .95 : .6);
	draw_text(_r.x + 7, _r.y + 5, tabs[_t]);
}

// ---- the page ----
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _rw = _rows[_i];
	var _ry = __row_y(_i);
	if (_ry + row_h > room_height - 4) break;

	// the row surface, statistics' language
	var _c = merge_colour(c_hsv(168, 160, 5), c_hsv(169, 186, 5), .2);
	draw_sprite_ext(spr_pixel_1x1, 0, cont_x, _ry, cont_w, row_h, 0, _c, 1);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, cont_x, _ry, cont_w, 1, 0,
		_c, c_black, c_black, _c, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, cont_x, _ry, 2, row_h, 0, _rw.col,
		_rw.on ? .9 : .25);

	draw_set_halign(fa_left);
	draw_set_color(_rw.on ? c_white : _dim);
	draw_set_alpha(_rw.on ? .95 : .6);
	draw_text(cont_x + 7, _ry + 3, _rw.name);

	// the rarity chips, in place of everything else on their row
	if (_rw.kind == 3) {
		for (var _k = 0; _k < UPG_RARITY_N; _k++) {
			var _ch = __chip_r(_k, _ry);
			var _ri = upgrade_rarity_info(_k);
			var _kp = g.autom.upg.rar[_k];
			draw_sprite_ext(spr_pixel_1x1, 0, _ch.x, _ch.y, _ch.w, _ch.h, 0,
				_kp ? merge_colour(_ri.col, c_black, .55) : c_black,
				_kp ? .95 : .6);
			draw_px_rect(_ch.x, _ch.y, _ch.w, _ch.h, _ri.col, _kp ? .9 : .25);
			draw_set_halign(fa_center);
			draw_set_color(_kp ? c_white : _dim);
			draw_set_alpha(_kp ? .95 : .5);
			// three letters: eight full rarity names do not fit a row,
			// and the colour is carrying most of the identity anyway
			draw_text(_ch.x + _ch.w / 2 + 1, _ch.y + 2,
				string_copy(_ri.name, 1, 3));
			draw_set_halign(fa_left);
		}
		continue;
	}

	// the toggle
	if (_rw.kind == 0 || _rw.kind == 2 || _rw.kind == 4) {
		var _tg = __tog_r(_i);
		draw_sprite_ext(spr_pixel_1x1, 0, _tg.x, _tg.y, _tg.w, _tg.h, 0,
			_rw.on ? merge_colour(_rw.col, c_black, .5) : c_black,
			_rw.on ? .95 : .5);
		draw_px_rect(_tg.x, _tg.y, _tg.w, _tg.h, _rw.col, _rw.on ? .9 : .3);
		draw_set_halign(fa_center);
		draw_set_color(_rw.on ? c_white : _dim);
		draw_set_alpha(_rw.on ? .95 : .6);
		draw_text(_tg.x + _tg.w / 2 + 1, _tg.y + 2,
			(_rw.kind == 4) ? (_rw.on ? "keep" : "sell") : (_rw.on ? "on" : "off"));
		draw_set_halign(fa_left);
	}

	// the slider - dim while its toggle is off, because a number that
	// is not being used should not read as one that is
	if (_rw.kind == 1 || _rw.kind == 2) {
		var _tk = __trk_r(_i);
		var _f  = clamp((_rw.val - _rw.lo) / max(1, _rw.hi - _rw.lo), 0, 1);
		var _a  = _rw.on ? 1 : .35;
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x, _tk.y, _tk.w, _tk.h, 0,
			c_black, .7 * _a);
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x, _tk.y, _tk.w * _f, _tk.h, 0,
			_rw.col, .8 * _a);
		draw_px_rect(_tk.x, _tk.y, _tk.w, _tk.h, _rw.col, .35 * _a);
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x + _tk.w * _f - 1, _tk.y - 2,
			3, _tk.h + 4, 0, c_white, .8 * _a);

		draw_set_halign(fa_right);
		draw_set_color(_rw.on ? c_white : _dim);
		draw_set_alpha(_rw.on ? .9 : .5);
		// clear of the verdict pill's column when there is one
		draw_text(cont_x + cont_w - ((_rw.st >= 0) ? 48 : 4), _ry + 3,
			string(_rw.val) + _rw.sfx);
		draw_set_halign(fa_left);
	}

	// the dial pages' verdict pill: what the automation did last pulse
	if (_rw.st >= 0) {
		var _px = cont_x + cont_w - 4;
		draw_set_halign(fa_right);
		// GML will not parse a ternary whose ELSE branch is itself a bare
		// ternary - the nested one has to be parenthesised
		draw_set_color((_rw.st == 2) ? c_sgreen
			: ((_rw.st == 1) ? c_horange : _dim));
		draw_set_alpha((_rw.st == 0) ? .35 : .8);
		draw_text(_px, _ry + 3,
			(_rw.st == 2) ? "buying" : ((_rw.st == 1) ? "waiting" : "off"));
		draw_set_halign(fa_left);
	}
}

// ---- the footer, on the pages that have room for one ----
// The hover line wins the slot when there is one: what the pointer is
// on beats a standing note, because the standing note is the thing you
// have already read.
var _fy = room_height - 30;
draw_set_color(_dim);
draw_set_alpha(.55);

if (tab != 0 && _help != "") {
	draw_set_color(merge_colour(_rows[_hov].col, c_white, .5));
	draw_set_alpha(.75);
	draw_text(cont_x, _fy, _help);
	draw_set_color(_dim);
	draw_set_alpha(.55);
} else
if (tab == 1) {
	draw_text(cont_x, _fy,
		"EVERY enabled condition must pass - they are rails, not triggers");
	var _c = rebirth_calc();
	draw_set_color(_c.can ? c_sgreen : _dim);
	draw_set_alpha(.7);
	draw_text(cont_x, _fy + 10, "now: "
		+ (_c.can ? ("+" + crunch_arb(_c.units) + " units") : "nothing yet")
		+ "   run " + crunch_time_long(_c.run_s * 60)
		+ (_c.cool > 0 ? ("   cooldown " + string(ceil(_c.cool)) + "s") : ""));
} else
// ⚖️ `else if`, NOT a second `if` (his report: the text overlapped).
// The hover line and this note share one y, so a bare `if` here painted
// the standing note straight through whatever the pointer was
// explaining. Every band on this screen is one line deep; anything that
// wants the slot has to take it from something else.
if (tab == 2) {
	// SAY WHAT THE QUICK-SET WOULD DO. A percentage is only a useful
	// control if the screen also says which rung it lands on today - the
	// whole point of reading the live odds is that the answer moves, and
	// a moving answer you cannot see is a mystery.
	draw_text(cont_x, _fy, "quick-set lands on "
		+ upgrade_rarity_info(upgrade_keep_rarity()).name
		+ " and above - the filter page holds the flags it writes");
	draw_set_color(c_horange);
	draw_set_alpha(.6);
	draw_text(cont_x, _fy + 10,
		"it never sells a slot you have bought tiers into");
} else
if (tab == 3) {
	// WHAT THE FILTER WOULD DO RIGHT NOW, through the same call the
	// runner uses - a preview computed a second way is a preview that
	// will eventually be wrong.
	var _would = 0;
	if (variable_global_exists("upg"))
		for (var _i = 0; _i < upgrade_slots(); _i++)
			if (upgrade_autosell_wants(_i)) _would += 1;
	draw_text(cont_x, _fy,
		"a slot goes if EITHER its rarity or its kind is switched to sell");
	draw_set_color((_would > 0) ? c_horange : _dim);
	draw_set_alpha(.7);
	draw_text(cont_x, _fy + 10, (_would > 0)
		? (string(_would) + " slot" + ((_would == 1) ? "" : "s")
			+ " on the table would be sold"
			+ (g.autom.upg.sell ? "" : " - auto sell is off"))
		: "nothing on the table matches the filter");
}

draw_set_alpha(1);
draw_set_color(c_white);
ui_fade_set(1);
if (_eo != 0) matrix_set(matrix_world, matrix_build_identity());
