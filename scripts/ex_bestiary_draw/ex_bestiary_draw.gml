/// @description ex_bestiary_draw(_ink, _dim) -> true when the page is drawn: THE BESTIARY page (syst_exped_panel's Draw, q220; self = the panel; ink / dim the colours)
function ex_bestiary_draw(_ink, _dim) {
	var _ros = foe_roster(), _nk = array_length(_ros), _met = 0;
	for (var _i = 0; _i < _nk; _i++) { var _mb = __bs_met(_ros[_i].name); if (is_struct(_mb) && _mb.seen > 0) _met++; }
	draw_set_color(_ink); draw_set_alpha(.6);
	var _bls = g.exped[$ "blands"] ?? [];
	draw_text(land ? 14 : 4, list_y + 6, "the bestiary  -  " + string(_met) + " of " + string(_nk) + " met" + ((array_length(_bls) > 0) ? ("  -  lands complete " + string(array_length(_bls)) + " (*)") : ""));
	// THE GRID: a cell a kind, its creature (spr_foe, tinted) once met, a "?" until then, the slain in the corner
	for (var _i = 0; _i < _nk; _i++) {
		var _r = _ros[_i], _cr = __bs_cell_r(_i);
		var _bb = __bs_met(_r.name);
		var _known = is_struct(_bb) && _bb.seen > 0;
		var _on = (bs_sel == _i);
		draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, _known ? merge_colour(_r.col, c_black, .8) : c_black, _on ? .95 : .7);
		draw_px_rect(_cr.x, _cr.y, _cr.w, _cr.h, _on ? c_white : (_known ? _r.col : _dim), _on ? .9 : (_known ? .5 : .2));
		draw_set_halign(fa_center);
		if (_known) {
			var _ff = foe_sprite_frame(_r.name);
			if (_ff >= 0) draw_sprite_ext(spr_foe, _ff, _cr.x + 12, _cr.y + 11, 1, 1, 0, _r.col, .95);   // (the creature - his ask 2026-09-16; the letter before)
			else { draw_set_font(fnt_large); draw_set_color(_r.col); draw_set_alpha(.95); draw_text(_cr.x + 12, _cr.y + 3, string_upper(string_char_at(_r.name, 1))); draw_set_font(fnt); }
			if (_bb.slain > 0) { draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.85); draw_text(_cr.x + _cr.w - 2, _cr.y + _cr.h - 9, string(_bb.slain)); }
		} else { draw_set_color(_dim); draw_set_alpha(.4); draw_text(_cr.x + 12, _cr.y + 8, "?"); }
		draw_set_halign(fa_left);
	}
	// THE CARD: the one picked
	var _cd = __bs_card_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _cd.x, _cd.y, _cd.w, _cd.h, 0, c_black, .6);
	draw_px_rect(_cd.x, _cd.y, _cd.w, _cd.h, _ink, .15);
	var _tx = _cd.x + 8, _ty = _cd.y + 6, _tw = _cd.w - 16;
	if (bs_sel < 0 || bs_sel >= _nk) { draw_set_color(_dim); draw_set_alpha(.5); draw_text(_tx, _ty, "tap a cell"); }
	else {
		var _r = _ros[bs_sel], _bb = __bs_met(_r.name);
		var _known = is_struct(_bb) && _bb.seen > 0;
		if (!_known) {
			draw_set_font(fnt_large); draw_set_color(_dim); draw_set_alpha(.7); draw_text(_tx, _ty, "?"); draw_set_font(fnt); _ty += 16;
			draw_set_color(_dim); draw_set_alpha(.7); draw_text(_tx, _ty, "not yet met"); _ty += 12;
			var _lnd = "";
			for (var _li = 0; _li < array_length(_r.lands); _li++) if (_r.lands[_li] != "road") _lnd += ((_lnd != "") ? ", " : "") + _r.lands[_li];
			draw_set_alpha(.55); draw_text_ext(_tx, _ty, "something haunts the " + _lnd + "; a crew that fights it fills this page", 9, _tw);
		} else {
			draw_set_font(fnt_large); draw_set_color(_r.col); draw_set_alpha(.95); draw_text(_tx, _ty, str_cap(_r.name));
			draw_set_font(fnt); draw_set_color(_dim); draw_set_alpha(.7);
			draw_text(_tx + string_width(str_cap(_r.name)) * 2 + 6, _ty + 5, "(" + foe_plural(_r.name) + ")");
			var _ffc = foe_sprite_frame(_r.name);
			if (_ffc >= 0) { draw_set_alpha(.95); draw_sprite_ext(spr_foe, _ffc, _tx + _tw - 26, _ty + 26, 3, 3, 0, _r.col, .95); }   // (the creature, three times, top right of the card)
			_ty += 18;
			draw_set_color(_ink); draw_set_alpha(.85);
			// ...and THE HUNT's rung on the same line (2026-09-16): the measure at ten, bane at fifty, scourge at two hundred and fifty (the card is full)
			var _pd = _bb[$ "paid"] ?? 0;
			var _sl = "seen " + string(_bb.seen) + "  -  slain " + string(_bb.slain) + ((_bb.boss > 0) ? ("  -  bosses " + string(_bb.boss)) : "");
			draw_text(_tx, _ty, _sl);
			draw_set_color(c_gold); draw_set_alpha(.85);
			draw_text(_tx + string_width(_sl) + 8, _ty, (_pd >= 250) ? "scourge" : ((_pd >= 50) ? "bane - scourge at 250" : ((_pd >= 10) ? "measured - bane at 50" : "measure at 10")));
			_ty += 12;
			// the shape as bars (the roster's eight lines on the sprites' budget)
			var _keys = ["hp", "mp", "atk", "mag", "def", "mdef", "spd", "hit", "luck"], _bw = min(80, _tw - 60);
			for (var _k = 0; _k < 9; _k++) {
				var _v = (_k == 8) ? (_r[$ "luck"] ?? 1) : _r.shape[$ _keys[_k]];
				draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, _keys[_k]);
				draw_sprite_ext(spr_pixel_1x1, 0, _tx + 26, _ty + 2, _bw, 4, 0, c_black, .7);
				draw_sprite_ext(spr_pixel_1x1, 0, _tx + 26, _ty + 2, _bw * clamp(_v / 13, 0, 1), 4, 0, _r.col, .85);
				draw_set_color(_ink); draw_set_alpha(.85); draw_text(_tx + 30 + _bw, _ty, string(_v));
				_ty += 9;
			}
			_ty += 3;
			var _lnd2 = "";
			for (var _li = 0; _li < array_length(_r.lands); _li++) _lnd2 += ((_lnd2 != "") ? ", " : "") + _r.lands[_li] + (array_contains(_bls, _r.lands[_li]) ? "*" : "");   // (* = the land's set complete)
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, "lands");
			draw_set_color(_ink); draw_set_alpha(.85); draw_text_ext(_tx + 40, _ty, _lnd2, 9, _tw - 40); _ty += string_height_ext(_lnd2, 9, _tw - 40) + 2;
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, "skill");
			draw_set_color(_r.magic ? c_hpurple : c_horange); draw_set_alpha(.9); draw_text(_tx + 40, _ty, (_r.skill != "") ? _r.skill : "-"); _ty += 10;
			// THE ELEMENT (2026-09-17): its bite, what it is soft to and what it
			// shrugs - known once a sprite has a note on the kind (the
			// notepad's second job); a "?" until then
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, "element");
			if (__kind_studied(_r.name)) {
				var _kel = _r[$ "elem"] ?? "", _ksc = _r[$ "school"] ?? "", _kail = _r[$ "ail"] ?? "";
				var _kx = _tx + 40;
				if (_kel != "") {
					var _kei = cbt_elem_info(_kel);
					draw_set_color(_kei.col); draw_set_alpha(.95); draw_text(_kx, _ty, _kei.name); _kx += string_width(_kei.name) + 4;
					draw_set_color(_ink); draw_set_alpha(.85); draw_text(_kx, _ty, "-  soft to " + _kei.weak + ", shrugs " + _kei.beats);
				} else if (_ksc != "") {
					var _ksi = cbt_elem_info(_ksc);
					draw_set_color(_ksi.col); draw_set_alpha(.95); draw_text(_kx, _ty, _ksc); _kx += string_width(_ksc) + 4;
					draw_set_color(_ink); draw_set_alpha(.85); draw_text(_kx, _ty, (_ksc == "light") ? "-  it mends its own" : "-  it feeds and weakens");
				} else { draw_set_color(_ink); draw_set_alpha(.85); draw_text(_kx, _ty, "none  -  each one soft to something of its own"); }
				_ty += 10;
				if (_kail != "") { draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, "leaves"); draw_set_color(c_horange); draw_set_alpha(.9); draw_text(_tx + 40, _ty, (_kail == "poison") ? "venom" : ((_kail == "slow") ? "a chill - slowed" : "the mark - it feeds on you")); _ty += 10; }
			} else { draw_set_color(_dim); draw_set_alpha(.5); draw_text(_tx + 40, _ty, "?   (a note on one tells)"); _ty += 10; }
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, "crit");
			draw_set_color(_ink); draw_set_alpha(.85); draw_text(_tx + 40, _ty, string(_r.crit) + "% x" + string(_r.cmulti) + "  -  counter " + string(_r.cnt) + "%"); _ty += 10;
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, "met as");
			var _vs = "";
			for (var _vi = 0; _vi < array_length(_bb.vars); _vi++) _vs += ((_vs != "") ? ", " : "") + _bb.vars[_vi];
			draw_set_color(_ink); draw_set_alpha(.85); draw_text_ext(_tx + 40, _ty, (_vs != "") ? _vs : "the plain kind only", 9, _tw - 40); _ty += string_height_ext((_vs != "") ? _vs : "x", 9, _tw - 40) + 4;
			// the natural history
			var _lo = bestiary_lore(_r.name);
			draw_sprite_ext(spr_pixel_1x1, 0, _tx, _ty, _tw, 1, 0, _r.col, .25); _ty += 4;
			draw_set_color(merge_colour(c_lavender, _dim, .35)); draw_set_alpha(.8);
			draw_text_ext(_tx, _ty, "\"" + _lo + "\"", 9, _tw);
		}
	}
	draw_set_alpha(1);
	ui_fade_set(1);
	return true;
	return false;
}
