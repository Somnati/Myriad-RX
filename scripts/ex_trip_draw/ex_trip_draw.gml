/// @description ex_trip_draw(_e, _ea, _br, _ink, _dim) -> true when the page is drawn: THE TRIP page - the world, the diary, the fight, the film (syst_exped_panel's Draw, q220; self = the panel; e = g.exped, ea the ease, br the breath, ink / dim the colours)
function ex_trip_draw(_e, _ea, _br, _ink, _dim) {
	var _tr = __trip();
	if (is_undefined(_tr)) { ui_fade_set(1); return true; }
	var _d  = _tr.dest;
	var _b  = exped_biomes()[_d.biome];
	var _n  = array_length(_tr.sids);
	var _rg = exped_region(_tr);
	var _wc = exped_world_col(_d);
	var _lf = _tr.fight;
	// ---- THE WORLD'S ISLAND: the render (its camera fixed on the trip's
	// region - tp_cam), the name, the region, the leg, the buttons ----
	var _isl = __trip_isle_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _isl.x, _isl.y, _isl.w, _isl.h, 0, c_black, .85);
	draw_px_rect(_isl.x, _isl.y, _isl.w, _isl.h, _wc, .35);
	draw_sprite_ext(spr_pixel_1x1, 0, _isl.x, _isl.y, 2, _isl.h, 0, _wc, .9);
	// THE REGION, CLOSE (q268): the face camera already sits on the crew's region - the world pulled in to the box's width
	// shows that patch of ground, clouds thinned, the 3x tier under it (__lod_step builds the trip's world's tier here)
	__draw_orbit(_d, big_x + 2, big_y + 1, big_w - 3, big_h - 2, (big_w - 3) * .5, (big_h - 2) * .5 + 2, (big_w - 3) * TP_ZOOM_RG, tp_cam, tp_spin, _tr[$ "rgi"] ?? 0, _tr[$ "rgi"] ?? 0, .15);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_font(fnt_large);
	draw_set_color(_wc); draw_set_alpha(.95);
	draw_text(big_x + big_w * .5, big_y + big_h + 2, str_cap(_d.name));
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	// the leg: a labelled bar (the hub's), then the day and the weather
	var _travel = _tr.dur * EXPED_TRAVEL;
	var _tf = 0, _leg = "";
	if (_tr.stage == 0) { _tf = clamp(_tr.t / max(1, _travel), 0, 1); _leg = "flying out"; }
	else if (_tr.stage == 2) { _tf = clamp((_tr.t - (_tr[$ "leave_t"] ?? _tr.t)) / max(1, _tr.dur * EXPED_RETURN), 0, 1); _leg = "flying home"; }
	else if (is_struct(_tr[$ "road"])) { _tf = clamp(_tr.road.t / max(1, _tr.road.d * EXPED_HOUR), 0, 1); _leg = "on the road"; }
	else if (is_struct(_tr[$ "act"])) { _tf = 1 - clamp(_tr.act.left / max(1, EXPED_ROOM_T), 0, 1); _leg = "at " + _rg.nodes[clamp(_tr.pos, 0, array_length(_rg.nodes) - 1)].name; }
	else { _tf = 0; _leg = "deciding"; }
	// the region and its level, then the sky, then the leg - a row each (2026-09-16: one row overlapped)
	var _sky = (_tr.stage == 1) ? (((_tr[$ "night"] ?? false) ? "night" : "day") + (((_tr[$ "weather"] ?? "clear") != "clear") ? (", " + _tr.weather) : "")) : "in space";
	var _rgl = big_y + big_h + (land ? 13 : 17);
	draw_set_color(merge_colour(_b.col2, c_white, .3)); draw_set_alpha(.8);
	draw_text(big_x + 6, _rgl, string_copy(_rg.name, 1, land ? 22 : 22) + "  lv " + string(exped_trip_lv(_tr)));
	draw_set_color(_dim); draw_set_alpha(.6);
	draw_text(big_x + 6, _rgl + 8, _sky + ((_e.spd > 1) ? ("  -  x" + string(_e.spd)) : ""));
	var _lgy = big_y + big_h + (land ? 30 : 30);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(big_x + 6, _lgy, string_copy(_leg, 1, 14));
	var _lbx = big_x + 6 + max(46, string_width(string_copy(_leg, 1, 14)) + 6), _lbw = big_x + big_w - 6 - _lbx;
	draw_sprite_ext(spr_pixel_1x1, 0, _lbx, _lgy + 2, _lbw, 4, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _lbx, _lgy + 2, _lbw * _tf, 4, 0, (_tr.stage == 1) ? c_sgreen : c_steelblue, .9);
	draw_px_rect(_lbx, _lgy + 2, _lbw, 4, c_white, .1);
	// [crew] [abort] - the island's foot (portrait), the right column's foot (wide); [map] is in the strip (2026-09-16)
	var _tcr = __trip_crew_r();
	draw_ui_button(_tcr.x, _tcr.y, _tcr.w, _tcr.h, "crew", c_steelblue, true, false);
	var _abr = __trip_abort_r();
	var _can_abort = !(_tr[$ "aborted"] ?? false) && _tr.stage != 2;
	draw_ui_button(_abr.x, _abr.y, _abr.w, _abr.h, (_tr[$ "aborted"] ?? false) ? "aborted" : "abort", c_hred, _can_abort, false);
	// ---- THE CREW as banners (the preparation page's), hp / mp LIVE in a
	// fight (the pawn's, or the replay frame's), the trip's between ----
	for (var _k = 0; _k < _n; _k++) {
		var _cr = __crew_row_r(_k);
		var _rsp = __sp_by_id(_tr.sids[_k]);
		var _hpk = _tr.hp[_k], _hmk = max(1, _tr.hpmax[_k]);
		var _mpf = (is_array(_tr[$ "mp"]) && _k < array_length(_tr.mp)) ? _tr.mp[_k] : 1;
		var _mpm = is_undefined(_rsp) ? 1 : max(1, round(sprite_stats(_rsp).pts.mp)), _mpk = round(_mpm * _mpf);
		if (!is_undefined(_lf)) { for (var _pi = 0; _pi < array_length(_lf.party); _pi++) if ((_lf.party[_pi][$ "mi"] ?? -1) == _k) { _hpk = _lf.party[_pi].hp; _mpk = _lf.party[_pi][$ "mp"] ?? _mpk; _mpm = max(1, _lf.party[_pi][$ "maxmp"] ?? _mpm); } }
		else if (!is_undefined(rp)) { var _rfr = rp.r.ev[rp.i]; for (var _pi = 0; _pi < array_length(rp.r.party); _pi++) if ((rp.r.party[_pi][$ "mi"] ?? _pi) == _k && _pi < array_length(_rfr.php)) _hpk = _rfr.php[_pi]; }
		var _up = (_hpk > 0);
		if (!is_undefined(_rsp)) __dp_banner(_rsp, _cr.x, _cr.y, _cr.w, _up ? 1 : .45, false, { hp : _hpk, hpmax : _hmk, mp : _mpk, mpmax : _mpm });
		else {
			draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, c_black, .6);
			draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, 2, _cr.h, 0, _tr.cols[_k], _up ? .9 : .3);
			draw_set_color(_up ? _ink : _dim); draw_set_alpha(.85); draw_text(_cr.x + 8, _cr.y + 3, _tr.names[_k]);
		}
		if (!_up) { draw_set_halign(fa_right); draw_set_color(c_hred); draw_set_alpha(.9); draw_text(_cr.x + _cr.w - 4, _cr.y + 3, "down"); draw_set_halign(fa_left); }
	}

	// ---- THE QUEST'S ISLAND, right: the ask and the tally, the pocket and
	// the wins; [recall] on an explore ----
	var _sx = log_x, _sy = log_y, _sw = log_w;
	var _q = _tr[$ "quest"];
	var _mode = _tr[$ "mode"] ?? "quest";
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy, _sw, 36, 0, c_black, .8);
	draw_px_rect(_sx, _sy, _sw, 36, is_struct(_q) ? c_gold : c_horange, .3);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy, 2, 36, 0, is_struct(_q) ? c_gold : c_horange, .9);
	var _qtw = _sw - 16 - ((_mode == "explore" && !(_tr[$ "recall"] ?? false) && _tr.stage == 1) ? 62 : 0);
	draw_set_color(is_struct(_q) ? c_gold : c_horange); draw_set_alpha(.95);
	if (is_struct(_q)) draw_text(_sx + 8, _sy + 4, string_copy(_q.txt, 1, land ? 52 : 26));
	else {
		var _tex = _tr[$ "ex"], _texw = "exploring " + _rg.name;
		if (is_struct(_tex) && _tex.kind == "ramble") _texw = "roaming " + _rg.name + " - " + string(_tex.n) + "h asked";
		else if (is_struct(_tex) && _tex.kind == "survey") _texw = "surveying " + _rg.name + " - " + string(max(0, array_length(_tr[$ "visited"] ?? []) - 1)) + " of " + string(_tex.n) + " places";
		draw_text(_sx + 8, _sy + 4, string_copy(_texw, 1, land ? 52 : 26));
	}
	// the tally line: done / n (or the hours), the pocket, the wins, where
	draw_set_color(_ink); draw_set_alpha(.8);
	var _tl = is_struct(_q) ? (string(_q.done) + " / " + string(_q.n) + ((_q.done >= _q.n) ? "  done" : "")) : (string_format((_tr[$ "planet_t"] ?? 0) / EXPED_HOUR, 1, 1) + "h on the world");
	draw_text(_sx + 8, _sy + 15, _tl);
	draw_set_color(c_lavender); draw_set_alpha(.85);
	draw_text(_sx + 8 + string_width(_tl) + 10, _sy + 15, string(_tr[$ "credits"] ?? 0) + " cr in the pocket");
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_sx + 8, _sy + 25, string_copy(exped_where(_tr) + ((_tr[$ "recall"] ?? false) ? "  -  heading home" : ""), 1, land ? 56 : 28));
	draw_set_halign(fa_right);
	draw_set_color((_tr[$ "wins"] ?? 0) > 0 ? c_sgreen : _dim); draw_set_alpha(.8);
	draw_text(_sx + _sw - 8, _sy + 25, string(_tr[$ "wins"] ?? 0) + ((_tr[$ "wins"] ?? 0) == 1 ? " fight won" : " fights won"));
	draw_set_halign(fa_left);
	if (_mode == "explore" && !(_tr[$ "recall"] ?? false) && _tr.stage == 1) {
		var _rr2 = __recall_r();
		draw_ui_button(_rr2.x, _rr2.y, _rr2.w, _rr2.h, "recall", c_horange, true, true);
	}

	// ---- THE COMBAT WINDOW (his ask: moved to the corner, a little bigger,
	// not a centrepiece), while a fight is on - or while a fight that ended
	// off screen REPLAYS from its film (rp): the crew as their own
	// portraits bottom left, the foes as diamonds top right, hp over each,
	// the flash and the shake on whoever was hit, the damage in the outline
	// font; the fight's lines to the window's LEFT ----
	var _fighting = !is_undefined(_tr.fight) || !is_undefined(rp);
	var _fr0 = __fight_r();
	var _fy = _fr0.y;
	if (_fighting) {
		var _f = _tr.fight;
		if (is_undefined(_f)) {
			// the film's frame as a fight: hp from the event, the flash on
			// its target, the party's shape from the record
			var _fr = rp.r.ev[rp.i];
			var _pp = [];
			for (var _pi = 0; _pi < array_length(rp.r.party); _pi++) {
				var _pm = rp.r.party[_pi];
				array_push(_pp, { name : _pm.name, col : _pm.col, hpmax : _pm.hpmax, sid : _pm[$ "sid"] ?? -1, mi : _pm[$ "mi"] ?? _pi,
				                  hp : (_pi < array_length(_fr.php)) ? _fr.php[_pi] : _pm.hp });
			}
			var _pf = [];
			var _rfs = rp.r[$ "foes"] ?? [ rp.r.foe ];
			for (var _fi = 0; _fi < array_length(_rfs); _fi++) {
				var _rf = _rfs[_fi];
				var _fhps = _fr[$ "fhps"] ?? [ _fr.fhp ];
				array_push(_pf, { name : _rf.name, hpmax : _rf.hpmax, lv : _rf[$ "lv"] ?? 1, kind : _rf[$ "kind"] ?? "", col : _rf[$ "col"] ?? c_hred,
				                  hp : (_fi < array_length(_fhps)) ? _fhps[_fi] : _fr.fhp });
			}
			_f = { party : _pp, foes : _pf, b : _pf[0],
			       turn : rp.i + 1, over : (rp.i >= array_length(rp.r.ev) - 1), won : rp.r.won,
			       log : [ _fr.txt ], last : (_fr.dmg > 0) ? { side : _fr.side, i : _fr.i, dmg : _fr.dmg, at : current_time - rp.t * 1000 } : undefined,
			       replay : true };
		}
		var _fx = _fr0.x, _fs = fight_s;
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy, _fs, _fs, 0, c_black, .88);
		// the ground: a dark band, a floor line
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 1, _fy + _fs - 18, _fs - 2, 17, 0, merge_colour(_b.col2, c_black, .82), .9);
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 4, _fy + _fs - 18, _fs - 8, 1, 0, _ink, .25);
		draw_px_rect(_fx, _fy, _fs, _fs, (_f[$ "replay"] ?? false) ? _dim : c_hred, ((_f[$ "replay"] ?? false) ? .4 : .5) + .3 * _br);
		var _flash_t = (!is_undefined(_f.last)) ? clamp(1 - (current_time - _f.last.at) / 350, 0, 1) : 0;
		// the foes, a row top right: each its creature (spr_foe, tinted), its hp above
		var _fos = _f[$ "foes"] ?? [ _f.b ];
		var _nfo = array_length(_fos);
		for (var _j = 0; _j < _nfo; _j++) {
			var _fo = _fos[_j];
			var _jx = _fx + _fs - 14 - _j * 18, _jy = _fy + 28 - (_j mod 2) * 7;
			var _jhit = (_flash_t > 0 && _f.last.side == "b" && (_f.last.i == _j || (_f.last.i < 0 && _j == 0)));
			var _shk = _jhit ? (irandom(2) - 1) : 0;
			var _jc = _fo[$ "col"] ?? c_hred;
			var _jff = foe_sprite_frame(_fo[$ "kind"] ?? "");
			if (_fo.hp > 0 && _jff >= 0) draw_sprite_ext(spr_foe, _jff, _jx + _shk, _jy, 1, 1, 0, _jhit ? c_white : _jc, .95);   // (the creature - spr_foe, tinted; the diamond before)
			else if (_fo.hp > 0) { draw_sprite_ext(spr_pixel_1x1, 0, _jx - 6 + _shk, _jy - 6, 12, 12, 45, merge_colour(_jc, c_black, .35), .95); draw_sprite_ext(spr_pixel_1x1, 0, _jx - 4 + _shk, _jy - 4, 8, 8, 45, _jhit ? c_white : _jc, .95); }
			else draw_sprite_ext(spr_pixel_1x1, 0, _jx - 6, _jy + 3, 12, 3, 0, _jc, .4);
			var _jf = clamp(_fo.hp / max(1, _fo.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _jx - 7, _jy - 14, 14, 2, 0, c_black, .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _jx - 7, _jy - 14, 14 * _jf, 2, 0, c_hred, .9);
			if (_fo.hp > 0) __pips(_fo, _jx - 7, _jy - 18);   // (the status pips, 2026-09-17)
		}
		// the crew, bottom left: their own portraits (the room's blobs), hp over each
		ui_fade_set(1);
		for (var _k = 0; _k < array_length(_f.party); _k++) {
			var _m = _f.party[_k];
			var _mx = _fx + 14 + _k * 18, _my = _fy + _fs - 24 - (_k mod 2) * 7;
			var _mhit = (_flash_t > 0 && _f.last.side == "a" && _f.last.i == _k);
			var _sk = _mhit ? (irandom(2) - 1) : 0;
			var _msp = __sp_by_id(_m[$ "sid"] ?? -1);
			if (is_undefined(_msp) && (_m[$ "mi"] ?? -1) >= 0 && _m.mi < _n) _msp = __sp_by_id(_tr.sids[_m.mi]);
			if (_m.hp > 0) {
				if (!is_undefined(_msp)) sprite_portrait(_msp, _mx + _sk, _my, 1); else __dot(_mx + _sk, _my, 5, _m.col, .95);
				if (_mhit) draw_sprite_ext(spr_pixel_1x1, 0, _mx - 6 + _sk, _my - 6, 12, 12, 0, c_white, .55);
			} else __dot(_mx, _my + 5, 5, _m.col, .25);
			var _mf = clamp(_m.hp / max(1, _m.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 7, _my - 12, 14, 2, 0, c_black, .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 7, _my - 12, 14 * _mf, 2, 0, (_mf > .35) ? c_sgreen : c_horange, .9);
			if (_m.hp > 0) __pips(_m, _mx - 7, _my - 16);   // (the status pips, 2026-09-17)
		}
		ui_fade_set(_ea);
		// the damage number, floating off the one hit (the outline font)
		if (_flash_t > 0) {
			draw_set_font(fnt_outline); draw_set_halign(fa_center);
			draw_set_color(c_white); draw_set_alpha(_flash_t);
			var _dx = (_f.last.side == "b") ? (_fx + _fs - 14 - max(0, _f.last.i) * 18) : (_fx + 14 + _f.last.i * 18);
			var _dy = ((_f.last.side == "b") ? (_fy + 28) : (_fy + _fs - 24)) - 20 - (1 - _flash_t) * 8;
			draw_text(_dx, _dy, "-" + string(_f.last.dmg));
			draw_set_halign(fa_left); draw_set_font(fnt);
		}
		// the fight's lines, to the window's left: the pack, the action, the last line
		var _tx = _sx, _ltw = _fx - 8 - _sx;
		draw_set_color(c_hred); draw_set_alpha(.95);
		var _pk = "";
		for (var _j = 0; _j < _nfo; _j++) _pk += ((_j > 0) ? ", " : "") + ((_fos[_j].hp > 0) ? _fos[_j].name : ("[" + _fos[_j].name + "]"));
		draw_text_ext(_tx, _fy + 2, _pk, 9, _ltw);
		var _pkh = string_height_ext(_pk, 9, _ltw);
		draw_set_color(_dim); draw_set_alpha(.7);
		if (_f[$ "replay"] ?? false) draw_text(_tx, _fy + 4 + _pkh, "replay  -  fight " + string(rp.r.room) + "  -  tap to skip");
		else draw_text(_tx, _fy + 4 + _pkh, "action " + string(_f.turn) + "  -  lv " + string(_f.b[$ "lv"] ?? 1) + "  -  " + string(_nfo) + ((_nfo == 1) ? " foe" : " foes"));
		var _fl = array_length(_f.log);
		draw_set_color(c_white); draw_set_alpha(.9);
		draw_text_ext(_tx, _fy + 16 + _pkh, (_fl > 0) ? _f.log[_fl - 1] : "...", 9, _ltw);
		if (!(_f[$ "replay"] ?? false)) {
			var _st = __step_r();
			draw_ui_button(_st.x, _st.y, _st.w, _st.h, _f.over ? "done" : "step turn", c_hred, !_f.over, !_f.over);
		} else if (_f.over) {
			var _rdr = (rp.r[$ "drawn"] ?? false);
			draw_set_color(_f.won ? c_sgreen : (_rdr ? _dim : c_hred));
			draw_set_alpha(.9);
			draw_text(_tx, _fy + _fs - 12, _f.won ? "won" : (_rdr ? "withdrew" : "routed"));
		}
	}

	// ---- THE DIARY, under the quest's island: truth lines plain, the "~ "
	// lines the crew's own voice, "+ " the rewards in gold; newest at the
	// bottom, on the scrollbar (it follows the newest line while you sit there) ----
	var _ly = _sy + 42;
	var _ly_end = _fighting ? (_fy - 6) : (room_height - 10);
	// THE FORK'S CARD (q258): while the crew stands at a fork and the window is open, the choice is yours - the prompt,
	// the two ways (the crew's own lean lit), the window running out along the bottom; a tap = exped_fork_choose by you.
	// It sits ABOVE the diary - the log band starts under it (q270; its lines drew through the card)
	var _fkc = _tr[$ "fork"];
	var _fk_on = is_struct(_fkc) && current_time - _fkc.born < EXPED_FORK_WINDOW * 1000, _fh = 64;
	__draw_log_band(__log_lines(), { x : _sx, y : _fk_on ? (_ly + _fh + 4) : _ly, w : _sw, h : _ly_end - _ly - (_fk_on ? (_fh + 4) : 0) }, _b.col2);   // (the gist when toggled, 2026-09-16)
	if (_fk_on) {
		draw_sprite_ext(spr_pixel_1x1, 0, _sx, _ly, _sw, _fh, 0, c_black, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _sx + 1, _ly + 1, _sw - 2, _fh - 2, 0, c_hsv(169, 186, 10), 1);
		draw_px_rect(_sx, _ly, _sw, _fh, c_gold, .8);
		draw_set_color(c_gold); draw_set_alpha(.95); draw_text_ext(_sx + 4, _ly + 3, _fkc.prompt, 9, _sw - 8);
		var _lean = exped_fork_lean(_tr);
		for (var _k = 0; _k < 2; _k++) { var _br2 = __fork_r(_k); draw_ui_button(_br2.x, _br2.y, _br2.w, _br2.h, _fkc.choices[_k].txt, (_k == 1) ? c_horange : c_sgreen, true, _lean == _k); }
		draw_set_color(sett_ink); draw_set_alpha(.6); draw_text(_sx + 4, _ly + _fh - 12, "the crew leans " + _fkc.choices[_lean].txt + "  -  dc " + string(_fkc.dc));
		var _left = clamp(1 - (current_time - _fkc.born) / (EXPED_FORK_WINDOW * 1000), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _sx + 1, _ly + _fh - 2, (_sw - 2) * _left, 1, 0, c_gold, .85);
	}
	// THE SHEET AS A MODAL (a tap on a banner - his ask, 2026-09-16): the crew page's painter over the log column
	var _tsp = __sp_by_id(tp_sheet);
	if (!is_undefined(_tsp)) {
		var _tsr = __tp_sheet_r();
		it_rects = [];
		__draw_sheet(_tsp, _tsr.x, _tsr.y, _tsr.x + _tsr.w, _tsr.y + _tsr.h);
	} else if (tp_sheet >= 0) tp_sheet = -1;   // (the sprite went - retired, or the trip came home)
	// THE CONFIRM POPUP (abort): the save menu's box, over everything (__draw_confirm since 2026-09-17 - the crew page asks too)
	if (conf_a > .01 && conf_kind == "abort") {
		var _cq = (_tr.stage == 0) ? "turn the ship around?\n" + exped_crew_txt(_tr.names) + " will fly home without landing."
		                          : "abort the mission?\n" + exped_crew_txt(_tr.names) + " will head for the landing zone" + (is_struct(_tr[$ "quest"]) ? " and the quest is dropped." : ".");
		__draw_confirm(_cq, "abort", c_hred);
	}
	ui_fade_set(1);
	return true;
}
