/// @description ex_haul_draw(_e, _ea, _ink, _dim) -> true when the page is drawn: THE HAUL page (syst_exped_panel's Draw, q220; self = the panel; e = g.exped, ea / ink / dim the event's ease and colours)
function ex_haul_draw(_e, _ea, _ink, _dim) {
	var _hi = __haul_i();
	// (the card stays through the page's fade-out after a collect - haul_last stands in; 2026-09-16)
	var _h = (_hi >= 0) ? _e.hauls[_hi] : ((pg_dir < 0) ? haul_last : undefined);
	if (is_undefined(_h)) { ui_fade_set(1); return true; }
	haul_last = _h;
	var _found = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) if (_h.finds[_i].kind == "sprite") _found++;
	var _recruit = (_found > 0 && array_length(g.sprites) + _found > SPRITE_CAP);


	ui_fade_set(1); shader_reset();
	// the card on the left, the trip's log on the right (his ask, 2026-09-15:
	// "i want to see the log on that screen so i can read what they did")
	var _nb = array_length(_h.sids);   // the banners' rows
	var _cw = land ? 224 : (room_width - 8);
	// THE FINDS (his ask, 2026-09-15: "remake the findings so it looks nicer
	// and makes sense"): a label a kind, the text wrapped to the card
	var _flw = _cw - 66, _fhs = [], _fsum = 0, _fcred = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		if (_h.finds[_i].kind == "credits") { _fcred += _h.finds[_i][$ "n"] ?? 0; array_push(_fhs, 0); continue; }   // (the credit rows are the stats' now - "vague", his report 2026-09-16)
		var _ftx = (_h.finds[_i].kind == "sprite" && _recruit) ? "a sprite - wants to join" : _h.finds[_i].txt;
		var _fh = string_height_ext(_ftx, 9, _flw) + 2;
		array_push(_fhs, _fh); _fsum += _fh;
	}
	var _ch = 40 + _nb * 12 + 4 + 36 + 11 + max(_fsum, 10) + (_recruit ? 52 : 40);   // (the stats on the card, 2026-09-16)
	var _cx = land ? 14 : 4, _cy = list_y + 22;
	_ch = max(_ch, room_height - 8 - _cy);   // (to the page's foot: the buttons and the "again:" line sit inside it - his report 2026-09-15)
	ui_fade_set(_ea);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, _ch, 0, c_black, .9);
	draw_px_rect(_cx, _cy, _cw, _ch, _h.routed ? c_hred : c_gold, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, 1, 0, _h.routed ? c_hred : c_gold, .9);
	ui_fade_set(1);
	__world_small(_h.dest, _cx + 22, _cy + 22, 12, region_get(_h.dest, _h[$ "rgi"] ?? 0));   // (facing the region it came from)
	ui_fade_set(_ea);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text_ext(_cx + 42, _cy + 6, exped_crew_txt(_h.names) + ((array_length(_h.names) > 1) ? " are" : " is") + " back from " + _h.dest.name, 9, _cw - 48);
	draw_set_color(_h.routed ? c_hred : c_sgreen);
	draw_set_alpha(.85);
	draw_text(_cx + 42, _cy + 24, (_h.routed ? "routed - " : "") + string(_h[$ "wins"] ?? 0) + " fights won, " + string(_h.cleared) + " things done");
	draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _cy + 34, _cw - 16, 1, 0, _ink, .25);
	// THE CREW'S BANNERS (his ask, 2026-09-15): the crew as they came home
	var _hhp = _h[$ "hp"] ?? [], _hhm = _h[$ "hpmax"] ?? [];
	for (var _k = 0; _k < _nb; _k++) {
		var _by = _cy + 38 + _k * 12;
		var _hpk = (_k < array_length(_hhp)) ? _hhp[_k] : 1, _hmk = max(1, (_k < array_length(_hhm)) ? _hhm[_k] : 1);
		var _up = (_hpk > 0);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _by, _cw - 16, 11, 0, c_black, .5);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _by, 2, 11, 0, _h.cols[_k], _up ? .9 : .3);
		__dot(_cx + 18, _by + 5, 3, _h.cols[_k], _up ? .95 : .3);
		var _rsp = __sp_by_id(_h.sids[_k]);
		draw_set_halign(fa_left); draw_set_color(_up ? _ink : _dim); draw_set_alpha(.85);
		draw_text(_cx + 25, _by + 1, _h.names[_k] + (is_undefined(_rsp) ? "" : ("  lv " + string(sprite_sheet(_rsp).lv))) + (_up ? "" : "  -  down"));
		var _bw = 50, _hf = clamp(_hpk / _hmk, 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + _cw - 14 - _bw, _by + 3, _bw, 5, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx + _cw - 14 - _bw, _by + 3, _bw * _hf, 5, 0, (_hf > .35) ? c_sgreen : c_hred, .9);
		draw_px_rect(_cx + _cw - 14 - _bw, _by + 3, _bw, 5, c_white, .12);
	}
	var _fy = _cy + 40 + _nb * 12 + 4;
	draw_set_halign(fa_left);
	// THE STATS of the trip on the card (his ask, 2026-09-16: the tally's rows, no label, no vague credit rows): the credits that
	// came home are the pay, the reward and the pocket - the one sum the collect pays; the pocket is the part of it nobody spent
	var _tl = _h[$ "tl"]; if (!is_struct(_tl)) _tl = { slain : 0, mist : 0, items : 0, xp : 0, earned : 0 };
	var _trows = [["enemies slain", string(_tl.slain)], ["mistakes made", string(_tl.mist)], ["items acquired", string(_tl.items)],
	              ["xp earned", (frac(_tl.xp) == 0) ? string(round(_tl.xp)) : string_format(_tl.xp, 1, 1)], ["credits home", string(_fcred)], ["pocket unspent", string(_h[$ "pocket"] ?? 0)]];
	var _tcw = floor((_cw - 20) / 2);
	for (var _ti = 0; _ti < 6; _ti++) {
		var _tx = _cx + 10 + (_ti mod 2) * _tcw, _ty = _fy + (_ti div 2) * 10;
		draw_set_color(_dim); draw_set_alpha(.8); draw_text(_tx, _ty, _trows[_ti][0]);
		draw_set_halign(fa_right); draw_set_color(c_white); draw_set_alpha(.95); draw_text(_tx + _tcw - 8, _ty, _trows[_ti][1]); draw_set_halign(fa_left);
	}
	_fy += 36;
	draw_set_color(_ink); draw_set_alpha(.5);
	draw_text(_cx + 10, _fy, "brought home");
	_fy += 11;
	if (_fsum == 0) { draw_set_color(_dim); draw_set_alpha(.6); draw_text(_cx + 10, _fy, "the credits, and nothing else"); }
	// the buttons' caption (the "again:" line) sets where the finds must stop: the rest fold into "+n more" (bug hunt 2026-09-16)
	var _pl = _recruit ? undefined : __again_plan(_h);
	var _at = _recruit ? "" : (_pl.ok ? ("again: " + _pl.txt + (_pl.short ? "  -  they go as they are" : "")) : _pl.why);
	var _ah = _recruit ? 12 : string_height_ext(_at, 9, _cw - 32);
	var _flim = room_height - 8 - 16 - 3 - _ah - 4;
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _l = _h.finds[_i];
		if (_l.kind == "credits") continue;
		if (_fy + _fhs[_i] > _flim) { var _fmore = 0; for (var _j = _i; _j < array_length(_h.finds); _j++) if (_h.finds[_j].kind != "credits") _fmore += 1; draw_set_color(_dim); draw_set_alpha(.7); draw_text(_cx + 10, _fy, "+ " + string(_fmore) + " more"); break; }
		var _flb = "";
		switch (_l.kind) {
			case "credits": _flb = "credits"; break;
			case "gear":    _flb = "gear"; break;
			case "sprite":  _flb = "a sprite"; break;
			case "egg":     _flb = "an egg"; break;
			case "offer":   _flb = "an offer"; break;
			case "charm":   _flb = "a charm"; break;
			case "chart":   _flb = "a chart"; break;
			case "mats":    _flb = "materials"; break;
			default:        _flb = _l.kind; break;
		}
		draw_set_color(merge_colour(_l.col, _ink, .5)); draw_set_alpha(.7);
		draw_text(_cx + 10, _fy, _flb);
		draw_set_color(_l.col); draw_set_alpha(.95);
		draw_text_ext(_cx + 56, _fy, (_l.kind == "sprite" && _recruit) ? "a sprite - wants to join" : _l.txt, 9, _flw);
		_fy += _fhs[_i];
	}
	// THE RIGHT COLUMN (wide): THE MOMENT, and the diary behind [read the diary] (his ask, 2026-09-16: the label and the lone "home" were out of place)
	if (land) {
		var _ttx = _cx + _cw + 12, _tty = _cy, _ttw = room_width - (_cx + _cw + 12) - 14;
		var _hbm = _h[$ "best"];
		if (!hl_open) {
			if (is_struct(_hbm)) {
				draw_set_halign(fa_left);
				draw_set_color(_ink); draw_set_alpha(.5); draw_text(_ttx, _tty, "the moment");
				draw_set_color(c_gold); draw_set_alpha(.95); draw_text(_ttx, _tty + 10, __sheet_cut(_hbm.title, _ttw));
				if (_hbm.line != "") { draw_set_color(_dim); draw_set_alpha(.8); draw_text_ext(_ttx, _tty + 20, _hbm.line, 9, _ttw); }
			}
		} else __draw_log_band(__log_lines(), { x : _ttx, y : _tty, w : _ttw, h : room_height - 8 - 22 - _tty }, exped_biomes()[_h.dest.biome].col2);
		var _hlr = __hlog_r();
		draw_ui_button(_hlr.x, _hlr.y, _hlr.w, _hlr.h, hl_open ? "close the diary" : "read the diary", c_steelblue, true, false);
	}
	draw_set_halign(fa_left);
	if (_recruit) {
		draw_set_halign(fa_center);
		draw_set_color(c_gold);
		draw_set_alpha(.9);
		draw_text(_cx + _cw * .5, _cy + _ch - 34, "the roster is full (" + string(SPRITE_CAP) + ")");
		draw_set_halign(fa_left);
		var _sw = __swap_r(), _go = __go_r();
		draw_ui_button(_sw.x, _sw.y, _sw.w, _sw.h, "swap one out", c_gold, true, true);
		draw_ui_button(_go.x, _go.y, _go.w, _go.h, "let them go", c_gray, true, false);
	} else {
		var _cb = __col_r(), _ag = __again_r();
		draw_ui_button(_cb.x, _cb.y, _cb.w, _cb.h, "collect", c_gold, true, true);
		// [SEND AGAIN] (2026-09-15): the same crew, the same region, the
		// easiest open card - what it would do, above the buttons (_pl / _at / _ah from the finds' limit above)
		draw_ui_button(_ag.x, _ag.y, _ag.w, _ag.h, "send again", _pl.ok ? c_sgreen : c_gray, true, false);
		draw_set_color(_pl.ok ? _dim : c_hred); draw_set_alpha(.75);
		draw_text_ext(_cx + 16, _cb.y - 3 - _ah, _at, 9, _cw - 32);
	}
	if (swap_pick || swap_a > .01) {
		// THE ROSTER: who makes room - over the card, under a veil, fading (swap_a - 2026-09-16)
		ui_fade_set(_ea * swap_a);
		draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y, room_width, room_height - list_y, 0, c_black, .88);
		draw_set_halign(fa_center);
		draw_set_color(c_white);
		draw_set_alpha(.95);
		draw_text(room_width * .5, list_y + 12, "the roster is full - who makes room for the new one?");
		for (var _k = 0; _k < array_length(g.sprites); _k++) {
			var _sp = g.sprites[_k];
			var _pr = __pick_r(_k);
			draw_sprite_ext(spr_pixel_1x1, 0, _pr.x, _pr.y, _pr.w, _pr.h, 0, c_black, .8);
			draw_px_rect(_pr.x, _pr.y, _pr.w, _pr.h, _sp.col, .4);
			__dot(_pr.x + 10, _pr.y + 8, 5, _sp.col, .95);
			draw_set_halign(fa_left);
			draw_set_color(c_white);
			draw_set_alpha(.95);
			draw_text(_pr.x + 20, _pr.y + 4, _sp.name);
			var _ri = upgrade_rarity_info(_sp[$ "rar"] ?? 0);
			draw_set_halign(fa_right);
			draw_set_color(_ri.col);
			draw_set_alpha(.8);
			var _mm = is_struct(_sp[$ "mem"]) ? _sp.mem : undefined;
			draw_text(_pr.x + _pr.w - 6, _pr.y + 4, _ri.name + ((_mm != undefined && _mm.trips > 0) ? ("  -  " + string(_mm.trips) + ((_mm.trips == 1) ? " trip" : " trips")) : ""));
		}
		draw_set_halign(fa_left);
		ui_fade_set(1);
	}
	ui_fade_set(1);
	return true;
	return false;
}
