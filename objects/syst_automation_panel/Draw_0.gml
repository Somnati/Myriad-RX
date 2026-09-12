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

// THE PAGE AND ITS HOVER, FIRST. The help line rides the title strip
// (drawn before the rows are) and the RAM band reads the hovered row's
// cost, so both are found up here.
var _rows = __page_rows();
var _hov  = -1;
if (input_free(ui_layer_overlay))   // the panel's own rung (it holds the room at 100)
for (var _i = 0; _i < array_length(_rows); _i++) {
	if (!__row_vis(_i) || _rows[_i].kind == 8) continue;
	var _hy = __row_y(_i);
	if (point_in_rectangle(mouse_x, mouse_y, cont_x, _hy,
		cont_x + cont_w, _hy + row_h)) _hov = _i;
}
var _help = (_hov >= 0 && variable_struct_exists(_rows[_hov], "help"))
	? _rows[_hov].help : "";
hov     = _hov;
hov_ram = (_hov >= 0) ? _rows[_hov].ram : 0;
hov_on  = (_hov >= 0) ? _rows[_hov].on  : false;

// ---- the title strip: the title, and the hovered row's help ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 5, "automation");
draw_set_halign(fa_right);
if (_help != "" && tab == AT_DIALS) {
	// the dials page fills the room to the bottom edge, so its help
	// rides the strip; every other page has a footer for it
	draw_set_color(merge_colour(_rows[_hov].col, c_white, .5));
	draw_set_alpha(.8);
	draw_text(room_width - 8, bby + 5, _help);
} else if (tab == AT_DIALS) {
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(room_width - 8, bby + 5, (g.autom.lock_pct > 0)
		? ("reserve is holding " + ((profit_reserved() >= arb(1))
			? crunch_arb(profit_reserved()) : "0") + " out of spending")
		: "the % is a CAP: the most one buy may cost, out of spendable profit");
}
draw_set_halign(fa_left);

// ---- THE RAM BAND, on every tab (his ask) ----
// one stick per unit: lit for what is used, an outline for what is
// free, RED past the cap (the over-budget sticks). The hovered row's
// cost pulses red on the meter - over its own sticks if it is on (the
// last ones of the used run), after the used run if it is off (what
// switching it on would take, and whether that crosses the cap).
{
	var _u = ram_used(), _c = ram_cap(), _th = ram_throttle();
	var _n = max(_c, _u);
	var _hot = ram_oc_any();   // something runs on a notch: the band leans orange
	__stick_seat(_n);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, band_y, room_width, band_h, 0, c_black, .45);
	draw_sprite_ext(spr_pixel_1x1, 0, 0, band_y + band_h - 1, room_width, 1, 0, sett_ink, .25);
	draw_set_color(_hot ? c_horange : c_gold);
	draw_set_alpha(.85);
	draw_text(6, band_y + 2, "ram " + string(_u) + "/" + string(_c));

	var _pulse = .35 + .65 * (.5 + .5 * sin(current_time / 170));
	// which sticks the hover paints: [h0, h0 + hov_ram)
	var _h0 = -1;
	if (hov_ram > 0) _h0 = hov_on ? max(0, _u - hov_ram) : _u;
	for (var _k = 0; _k < _n; _k++) {
		var _sr = __stick_r(_k);
		var _used = (_k < _u);
		var _over = (_k >= _c);
		var _col  = _over ? c_hred : (_hot ? merge_colour(c_seagreen, c_horange, .55) : c_seagreen);
		if (_used) draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, _sr.w, _sr.h, 0, _col, .85);
		else       draw_px_rect(_sr.x, _sr.y, _sr.w, _sr.h, _over ? c_hred : c_seagreen, .25);
		if (_h0 >= 0 && _k >= _h0 && _k < _h0 + hov_ram) {
			draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, _sr.w, _sr.h, 0, c_hred, .9 * _pulse);
			draw_px_rect(_sr.x - 1, _sr.y - 1, _sr.w + 2, _sr.h + 2, c_hred, .6 * _pulse);
		}
	}
	// a hover that would run past every drawn stick: the extra sticks,
	// outlined red past the meter's end
	if (_h0 >= 0 && _h0 + hov_ram > _n) {
		for (var _k = _n; _k < _h0 + hov_ram; _k++) {
			var _sr = __stick_r(_k);
			draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, _sr.w, _sr.h, 0, c_hred, .9 * _pulse);
		}
	}
	// THE [overclock] CHIP (read ram_oc): orange while the notches are
	// open, breathing while something runs on one
	{
		var _oc = __oc_rect();
		var _on = g.autom.oc;
		var _hv = point_in_rectangle(mouse_x, mouse_y, _oc.x, _oc.y, _oc.x + _oc.w, _oc.y + _oc.h);
		draw_set_alpha(1);
		draw_sprite_ext(spr_pixel_1x1, 0, _oc.x, _oc.y, _oc.w, _oc.h, 0,
			_on ? merge_colour(c_horange, c_black, _hot ? (.45 + .15 * _pulse) : .6) : c_black, _on ? .95 : .5);
		draw_px_rect(_oc.x, _oc.y, _oc.w, _oc.h, c_horange, _on ? .9 : (_hv ? .6 : .3));
		draw_set_halign(fa_center);
		draw_set_color(_on ? c_white : merge_colour(c_horange, c_white, _hv ? .6 : .25));
		draw_set_alpha(_on ? .95 : .7);
		draw_text(_oc.x + _oc.w / 2 + 1, _oc.y + 2, "overclock");
	}
	// the verdict, right
	draw_set_halign(fa_right);
	if (_th < 1) {
		draw_set_color(c_hred);
		draw_set_alpha(.9);
		draw_text(room_width - 8, band_y + 2, "over budget  x" + string_format(_th, 1, 2));
	} else {
		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(room_width - 8, band_y + 2, string(_c - _u) + " free");
	}
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
var _nrows = array_length(_rows);
for (var _i = 0; _i < _nrows; _i++) {
	if (!__row_vis(_i)) continue;
	var _rw = _rows[_i];
	var _ry = __row_y(_i);

	// a section band: a label and a rule - and a button, if it has one
	if (_rw.kind == 8) {
		draw_set_color(merge_colour(_rw.col, c_white, .4));
		draw_set_alpha(.75);
		draw_text(cont_x + 2, _ry + 2, _rw.name);
		draw_sprite_ext(spr_pixel_1x1, 0, cont_x, _ry + row_h - 1, cont_w, 1, 0, _rw.col, .35);
		if (_rw.btn != "") {
			// the drawer's view button, in the drawer's colours
			var _bb = __btn_r(_i, 0, 1);
			var _vc = (_rw.btn == "p/c") ? c_rarity_common : ((_rw.btn == "p/s") ? c_steelblue : c_gold);
			draw_sprite_ext(spr_pixel_1x1, 0, _bb.x, _bb.y, _bb.w, _bb.h, 0, merge_colour(_vc, c_black, .55), .95);
			draw_px_rect(_bb.x, _bb.y, _bb.w, _bb.h, _vc, .9);
			draw_set_halign(fa_center);
			draw_set_color(c_white);
			draw_set_alpha(.95);
			draw_text(_bb.x + _bb.w / 2 + 1, _bb.y + 1, _rw.btn);
			draw_set_halign(fa_left);
		}
		continue;
	}

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
	draw_text(cont_x + 7, _ry + 2, _rw.name);
	// (the dial's p/s sits at the row's end and the verdict pill beside
	// the name - swapped, his ask 2026-09-11)

	// an info line: the value after the label, and a figure at the end
	if (_rw.kind == 6) {
		draw_set_color(merge_colour(_rw.col, c_white, .6));
		draw_set_alpha(.8);
		draw_text(cont_x + 72, _ry + 2, _rw.val);
		if (variable_struct_exists(_rw, "right")) {
			draw_set_halign(fa_right);
			draw_set_color(_rw.col);
			draw_set_alpha(.9);
			draw_text(cont_x + cont_w - 4, _ry + 2, _rw.right);
			draw_set_halign(fa_left);
		}
		continue;
	}

	// an action row: a note, then its buttons from the right
	if (_rw.kind == 7) {
		draw_set_color(_dim);
		draw_set_alpha(.7);
		draw_text(cont_x + 72, _ry + 2, _rw.val);
		var _nb = array_length(_rw.btns);
		for (var _b = 0; _b < _nb; _b++) {
			var _br = __btn_r(_i, _b, _nb);
			var _en = _rw.on || (_rw.btns[_b] == "save");
			draw_sprite_ext(spr_pixel_1x1, 0, _br.x, _br.y, _br.w, _br.h, 0,
				_en ? merge_colour(_rw.col, c_black, .55) : c_black, _en ? .95 : .5);
			draw_px_rect(_br.x, _br.y, _br.w, _br.h, _rw.col, _en ? .9 : .3);
			draw_set_halign(fa_center);
			draw_set_color(_en ? c_white : _dim);
			draw_set_alpha(_en ? .95 : .6);
			draw_text(_br.x + _br.w / 2 + 1, _br.y + 1, _rw.btns[_b]);
			draw_set_halign(fa_left);
		}
		continue;
	}

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
			draw_text(_ch.x + _ch.w / 2 + 1, _ch.y + 1,
				string_copy(_ri.name, 1, 3));
			draw_set_halign(fa_left);
		}
		continue;
	}

	// the toggle
	if (_rw.kind == 0 || _rw.kind == 2 || _rw.kind == 4 || _rw.kind == 5) {
		var _tg = __tog_r(_i);
		draw_sprite_ext(spr_pixel_1x1, 0, _tg.x, _tg.y, _tg.w, _tg.h, 0,
			_rw.on ? merge_colour(_rw.col, c_black, .5) : c_black,
			_rw.on ? .95 : .5);
		draw_px_rect(_tg.x, _tg.y, _tg.w, _tg.h, _rw.col, _rw.on ? .9 : .3);
		draw_set_halign(fa_center);
		draw_set_color(_rw.on ? c_white : _dim);
		draw_set_alpha(_rw.on ? .95 : .6);
		draw_text(_tg.x + _tg.w / 2 + 1, _tg.y + 1,
			(_rw.kind == 4) ? (_rw.on ? "keep" : "sell") : (_rw.on ? "on" : "off"));
		draw_set_halign(fa_left);
	}

	// the sliders - dim while their toggle is off, because a number
	// that is not being used should not read as one that is
	var _sa = _rw.on ? 1 : .35;
	if (_rw.kind == 1 || _rw.kind == 2) {   // the wide track
		var _tk  = __trk_r(_i);
		var _snp = variable_struct_exists(_rw, "snap");
		var _nf  = __nf(_rw);
		var _ock = (variable_struct_exists(_rw, "ock") && ram_oc_k(_rw.ock, _rw.val) >= 0);
		var _f   = _snp ? __stop_f(_rw, _rw.val)
		         : clamp((_rw.val - _rw.lo) / max(1, _rw.hi - _rw.lo), 0, 1);
		var _fc  = _ock ? c_horange : _rw.col;
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x, _tk.y, _tk.w, _tk.h, 0, c_black, .7 * _sa);
		// the notches' stretch of the track wears orange under everything
		if (_nf < 1)
			draw_sprite_ext(spr_pixel_1x1, 0, _tk.x + _tk.w * _nf, _tk.y, _tk.w * (1 - _nf), _tk.h, 0,
				merge_colour(c_horange, c_black, .6), .8 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x, _tk.y, _tk.w * _f, _tk.h, 0, _fc, .8 * _sa);
		draw_px_rect(_tk.x, _tk.y, _tk.w, _tk.h, _fc, .35 * _sa);
		// a snapping track shows its stops - one notch per ram point,
		// the overclock ones orange
		if (_snp) {
			var _st = __stops(_rw);
			for (var _q = 0; _q < array_length(_st); _q++) {
				var _sx = _tk.x + _tk.w * _st[_q].f;
				draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx), _tk.y - 1, 1, _tk.h + 2, 0,
					(_st[_q].k >= 0) ? c_horange : c_white, ((_st[_q].k >= 0) ? .7 : .35) * _sa);
			}
		}
		draw_sprite_ext(spr_pixel_1x1, 0, _tk.x + _tk.w * _f - 1, _tk.y - 2, 3, _tk.h + 4, 0, c_white, .8 * _sa);
		draw_set_halign(fa_right);
		draw_set_color(_rw.on ? (_ock ? c_horange : c_white) : _dim);
		draw_set_alpha(_rw.on ? .9 : .5);
		// clear of the verdict pill's column when there is one
		draw_text(cont_x + cont_w - ((_rw.st >= 0) ? 48 : 4), _ry + 2, string(_rw.val) + _rw.sfx);
		draw_set_halign(fa_left);
	}
	if (_rw.kind == 5) {   // the cap track, then the timer track
		var _ck = __cap_r(_i);
		var _f  = clamp((_rw.val - _rw.lo) / max(1, _rw.hi - _rw.lo), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _ck.x, _ck.y, _ck.w, _ck.h, 0, c_black, .7 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _ck.x, _ck.y, _ck.w * _f, _ck.h, 0, _rw.col, .8 * _sa);
		draw_px_rect(_ck.x, _ck.y, _ck.w, _ck.h, _rw.col, .35 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _ck.x + _ck.w * _f - 1, _ck.y - 2, 3, _ck.h + 4, 0, c_white, .8 * _sa);
		draw_set_color(_rw.on ? c_white : _dim);
		draw_set_alpha(_rw.on ? .9 : .5);
		draw_text(_ck.x + _ck.w + 4, _ry + 2, string(_rw.val) + _rw.sfx);

		var _tm  = __tm_r(_i);
		var _tnf = __nf(_rw);
		var _tf  = __tm_f(_rw, _rw.t);   // right = fastest (his call)
		var _tok = (ram_oc_k("timer", _rw.t) >= 0);
		// the timer's colour is its price: the faster, the redder; an
		// overclocked one is orange
		var _tc = _tok ? c_horange
		        : merge_colour(c_seagreen, c_hred, clamp((ram_cost("timer", _rw.t) - 1) / 3, 0, 1));
		draw_sprite_ext(spr_pixel_1x1, 0, _tm.x, _tm.y, _tm.w, _tm.h, 0, c_black, .7 * _sa);
		if (_tnf < 1) {
			draw_sprite_ext(spr_pixel_1x1, 0, _tm.x + _tm.w * _tnf, _tm.y, _tm.w * (1 - _tnf), _tm.h, 0,
				merge_colour(c_horange, c_black, .6), .8 * _sa);
			for (var _q = 0; _q < RAM_OC_N; _q++) {
				var _sx = _tm.x + _tm.w * (_tnf + (1 - _tnf) * (_q + 1) / RAM_OC_N);
				draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx), _tm.y - 1, 1, _tm.h + 2, 0, c_horange, .7 * _sa);
			}
		}
		draw_sprite_ext(spr_pixel_1x1, 0, _tm.x, _tm.y, _tm.w * _tf, _tm.h, 0, _tc, .8 * _sa);
		draw_px_rect(_tm.x, _tm.y, _tm.w, _tm.h, _tc, .35 * _sa);
		draw_sprite_ext(spr_pixel_1x1, 0, _tm.x + _tm.w * _tf - 1, _tm.y - 2, 3, _tm.h + 4, 0, c_white, .8 * _sa);
		draw_set_color(_rw.on ? (_tok ? c_horange : c_white) : _dim);
		draw_set_alpha(_rw.on ? .9 : .5);
		draw_text(_tm.x + _tm.w + 4, _ry + 2, __tm_str(_rw.t));
	}

	// the autobuy rows' verdict pill: what the automation did last
	// attempt - beside the name; the dial's own p/s takes the row's end
	// (the strongest in gold)
	if (_rw.st >= 0) {
		draw_set_halign(fa_left);
		// GML will not parse a ternary whose ELSE branch is itself a bare
		// ternary - the nested one has to be parenthesised
		draw_set_color((_rw.st == 2) ? c_sgreen
			: ((_rw.st == 1) ? c_horange : _dim));
		draw_set_alpha((_rw.st == 0) ? .35 : .8);
		draw_text(cont_x + 42, _ry + 2,
			(_rw.st == 2) ? "buying" : ((_rw.st == 1) ? "waiting" : "off"));
	}
	if (variable_struct_exists(_rw, "sub")) {
		draw_set_halign(fa_right);
		draw_set_color(_rw.top ? c_gold : merge_colour(_rw.col, c_white, .5));
		draw_set_alpha(_rw.top ? .95 : .6);
		draw_text(cont_x + cont_w - 4, _ry + 2, _rw.sub);
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

if (_nrows > __rows_fit()) {
	// the scroll hint takes the second line; the notes keep the first
	draw_set_halign(fa_right);
	draw_text(room_width - 8, _fy + 10, "wheel: "
		+ string(scroll[tab] + 1) + "-" + string(min(_nrows, scroll[tab] + __rows_fit()))
		+ " of " + string(_nrows));
	draw_set_halign(fa_left);
}
if (tab != AT_DIALS && _help != "") {
	draw_set_color(merge_colour(_rows[_hov].col, c_white, .5));
	draw_set_alpha(.75);
	draw_text(cont_x, _fy, _help);
} else
if (tab == AT_REB) {
	draw_text(cont_x, _fy,
		"the switch never fires while this page is open");
	var _c = rebirth_calc();
	draw_set_color(_c.can ? c_sgreen : _dim);
	draw_set_alpha(.7);
	draw_text(cont_x, _fy + 10, "now: "
		+ (_c.can ? ("+" + crunch_arb(_c.units) + " units") : "nothing yet")
		+ "   run " + crunch_time_long(_c.run_s * 60)
		+ (_c.cool > 0 ? ("   cooldown " + string(ceil(_c.cool)) + "s") : ""));
} else
if (tab == AT_UPG) {
	// WHAT THE FILTER WOULD DO RIGHT NOW, through the same call the
	// runner uses - a preview computed a second way is a preview that
	// will eventually be wrong. (The quick-set lands on a rung the live
	// odds pick; the chips show it.)
	var _would = 0;
	if (variable_global_exists("upg"))
		for (var _i = 0; _i < upgrade_slots(); _i++)
			if (upgrade_autosell_wants(_i)) _would += 1;
	draw_set_color((_would > 0) ? c_horange : _dim);
	draw_set_alpha(.7);
	draw_text(cont_x, _fy, (_would > 0)
		? (string(_would) + " slot" + ((_would == 1) ? "" : "s")
			+ " on the table would be sold"
			+ (g.autom.upg.sell ? "" : " - auto sell is off"))
		: "nothing on the table matches the filter - a slot with tiers bought is never sold");
} else
if (tab == AT_TILES) {
	draw_text(cont_x, _fy,
		"a stick per 20% of speed on the machines; an autobuy 1 to 4 sticks by its timer");
} else
if (tab == AT_OVER) {
	draw_text(cont_x, _fy,
		"a stick per 20% of speed on a machine; an autobuy 4 at 1s down to 1 at 6s and slower");
}

draw_set_alpha(1);
draw_set_color(c_white);
ui_fade_set(1);
if (_eo != 0) matrix_set(matrix_world, matrix_build_identity());
