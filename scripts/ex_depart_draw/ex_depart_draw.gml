/// @description ex_depart_draw(_e, _ink, _dim) -> true when the page is drawn: THE PREPARATION page (syst_exped_panel's Draw, q220; self = the panel; e = g.exped, ink / dim the colours)
function ex_depart_draw(_e, _ink, _dim) {
	var _d = pl_dest;
	var _rg = region_get(_d, rg_sel);
	var _q  = (dp_mode == "quest") ? dp_quest : undefined;                          // the quest picked
	var _xc = (dp_mode == "explore" && is_struct(dp_quest)) ? dp_quest : undefined;  // ...or the explore card (2026-09-15)
	var _oL = -(1 - dp_in) * 200;   // the swing: the list from the left, the box from the right
	var _ns = exped_party_max();
	if (array_length(dp_slots) != _ns) { var _old2 = dp_slots; dp_slots = array_create(_ns, -1); for (var _k = 0; _k < min(array_length(_old2), _ns); _k++) dp_slots[_k] = _old2[_k]; }
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text((land ? 14 : 4) + _oL, list_y + 6, string_copy(_rg.name, 1, land ? 26 : 30));   // (the region alone - the strip says the rest; a long one ran under the box, 2026-09-16)
	// THE CREW as banners in a list: tap one for its sheet, [+] to seat it;
	// a seated one leaves a grey ghost here until it is home again
	var _dl = __dp_list_r();
	draw_set_color(_ink); draw_set_alpha(.6);
	draw_text(_dl.x, list_y + 22, "the crew  -  tap, or [+]" + ((__dp_off_max() > 0) ? "  -  scrolls" : ""));   // (short: the box sits to its right - 2026-09-15)
	var _crew = [];
	var _np = 0;
	for (var _j = 0; _j < _ns; _j++) if (dp_slots[_j] >= 0 && !is_undefined(__sp_by_id(dp_slots[_j]))) { array_push(_crew, __sp_by_id(dp_slots[_j])); _np++; }
	// (2026-09-16, his call: a banner stays in its row - seated, its [+] is a [-]; nothing flies, nothing ghosts)
	for (var _k = 0; _k < array_length(g.sprites); _k++) {
		if (!__dp_row_in(_k)) continue;
		var _sp = g.sprites[_k];
		var _rr = __dp_row_r(_k);
		var _seated = (__dp_seat_of(_sp.id) >= 0);
		var _away = (_sp[$ "trip"] ?? false);
		__dp_banner(_sp, _rr.x, _rr.y, _rr.w, _away ? .45 : 1, false);
		if (_seated) { draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_sgreen, .06); draw_px_rect(_rr.x, _rr.y, _rr.w, _rr.h, c_sgreen, .5); }   // (a seated banner wears a green edge)
		var _pr = __dp_plus_r(_k);
		var _can = _seated || (!_away && (_np < _ns));
		var _bc = _seated ? c_hred : c_sgreen;
		draw_sprite_ext(spr_pixel_1x1, 0, _pr.x, _pr.y, _pr.w, _pr.h, 0, c_black, .8);
		draw_px_rect(_pr.x, _pr.y, _pr.w, _pr.h, _can ? _bc : _dim, _can ? .7 : .25);
		draw_set_halign(fa_center); draw_set_color(_can ? _bc : _dim); draw_set_alpha(_can ? .95 : .35);
		draw_text(_pr.x + _pr.w * .5, _pr.y + _pr.h * .5 - 4, _seated ? "-" : "+");
		draw_set_halign(fa_left);
	}
	// THE MISSION BOX: the text, the numbers, then the seats inside it
	var _lay = __dp_layout();
	var _br2 = { x : _lay.x, y : _lay.y, w : _lay.w, h : _lay.h };
	draw_sprite_ext(spr_pixel_1x1, 0, _br2.x, _br2.y, _br2.w, _br2.h, 0, c_black, .7);
	draw_px_rect(_br2.x, _br2.y, _br2.w, _br2.h, (dp_mode == "explore") ? c_horange : c_gold, .5);
	var _tx = _br2.x + 8, _ty = _br2.y + 6, _tw = _lay.tw;
	var _dc = [c_sgreen, c_gold, c_horange, c_hred];
	draw_set_color(c_white); draw_set_alpha(.95);
	if (is_struct(_q)) {
		draw_text_ext(_tx, _ty, _q.txt, 9, _tw);
		_ty += string_height_ext(_q.txt, 9, _tw) + 4;
		if (_lay.para_on) {   // (the paragraph drops when the box would not fit - the layout decides)
			var _obj = exped_quest_obj(_q, _rg, true);   // (the one builder, 2026-09-15)
			draw_set_color(_dim); draw_set_alpha(.75);
			draw_text_ext(_tx, _ty, _obj, 9, _tw);
			_ty += string_height_ext(_obj, 9, _tw);
			// a personal card's note (the follow-ups, 2026-09-16), in gold
			if ((_q[$ "pnote"] ?? "") != "") { _ty += 4; draw_set_color(c_gold); draw_set_alpha(.85); draw_text_ext(_tx, _ty, _q.pnote, 9, _tw); _ty += string_height_ext(_q.pnote, 9, _tw); }
			_ty += 6;
		}
	} else {
		var _xt = is_struct(_xc) ? _xc.txt : ("wander " + _rg.name + " until recalled");
		draw_text_ext(_tx, _ty, _xt, 9, _tw);
		_ty += string_height_ext(_xt, 9, _tw) + 4;
		if (_lay.para_on) {
			draw_set_color(_dim); draw_set_alpha(.75);
			var _obj2 = is_struct(_xc) ? _xc.note : "they pick their own way: inns when hurt and there is coin, shops, taverns (drink, bar fights, bounties), dungeons, camps, the wild. [recall] on the trip's page brings them home";
			draw_text_ext(_tx, _ty, _obj2, 9, _tw);
			_ty += string_height_ext(_obj2, 9, _tw) + 6;
		}
	}
	// the numbers
	var _lvs = "";
	for (var _i = 0; _i < array_length(_crew); _i++) _lvs += ((_i > 0) ? ", " : "") + string(sprite_sheet(_crew[_i]).lv);
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "region strength");
	draw_set_halign(fa_right); draw_set_color(c_white); draw_text(_tx + _tw, _ty, "level " + string(_rg.lv) + ((_lvs != "") ? ("   (crew " + _lvs + ")") : "")); draw_set_halign(fa_left);
	_ty += 10;
	if (is_struct(_q)) {
		draw_set_color(_ink); draw_set_alpha(.8);
		draw_text(_tx, _ty, "difficulty");
		draw_set_halign(fa_right); draw_set_color(_dc[clamp(_q.diff, 0, 3)]); draw_text(_tx + _tw, _ty, _q.diff_txt + "  -  " + string(sprite_xp_quest(_q[$ "lv"] ?? _rg.lv, 1, _q.mult)) + " xp, " + string(_q.reward) + " credits"); draw_set_halign(fa_left);
		_ty += 10;
	}
	// THE HAZARD (2026-09-15): the place's, who in the seats holds it, who is
	// bare - and what would hold it, when someone is
	var _hzl = __dp_hazards();
	for (var _hi2 = 0; _hi2 < array_length(_hzl); _hi2++) {
		var _hzr = _hzl[_hi2], _hz = _hzr.hz;
		var _nh = array_length(_hzr.held), _nb = array_length(_hzr.bare);
		draw_set_color(_hz.col); draw_set_alpha(.9);
		draw_text(_tx, _ty, _hz.name);
		draw_set_halign(fa_right);
		if (_nh + _nb == 0)  { draw_set_color(_dim); draw_set_alpha(.75); draw_text(_tx + _tw, _ty, _hz.hold + " holds it"); }
		else if (_nb == 0)   { draw_set_color(c_sgreen); draw_set_alpha(.95); draw_text(_tx + _tw, _ty, (_nh > 1) ? "the crew holds it" : (_hzr.held[0] + " holds it")); }
		else if (_nh == 0)   { draw_set_color(c_hred); draw_set_alpha(.95); draw_text(_tx + _tw, _ty, (_nb > 1) ? "nobody holds it" : (_hzr.bare[0] + " is bare to it")); }
		else {
			var _sb = exped_crew_txt(_hzr.bare) + " bare", _sh = exped_crew_txt(_hzr.held) + ((_nh > 1) ? " hold it" : " holds it") + "  -  ";
			draw_set_color(c_hred); draw_set_alpha(.95); draw_text(_tx + _tw, _ty, _sb);
			draw_set_color(c_sgreen); draw_text(_tx + _tw - string_width(_sb), _ty, _sh);
		}
		draw_set_halign(fa_left);
		_ty += 10;
		if (_nb > 0) { draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.75); draw_text(_tx + _tw, _ty, _hz.hold + " holds it"); draw_set_halign(fa_left); _ty += 10; }
	}
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "time");
	var _eta = exped_eta(_d, is_struct(_xc) ? _xc : _q);
	draw_set_halign(fa_right); draw_set_color(c_white);
	draw_text(_tx + _tw, _ty, (_eta < 0) ? "until recalled" : ("about " + crunch_time_long(_eta * 60 / max(1, _e.spd)) + ((_e.spd > 1) ? ("  at x" + string(_e.spd)) : "")));
	draw_set_halign(fa_left);
	_ty += 10;
	var _cost = exped_cost(_d, max(1, _np));
	credits_init();
	var _have = unarb(g.credits);
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "the bill");
	draw_set_halign(fa_right); draw_set_color((_have >= _cost.total) ? c_lavender : c_hred);
	draw_text(_tx + _tw, _ty, "fuel " + string(_cost.fuel) + " + pocket " + string(_cost.pocket) + " = " + string(_cost.total) + "  (you have " + string(floor(_have)) + ")");
	draw_set_halign(fa_left);
	_ty += 10;
	var _od = exped_odds(_d, _q, _crew, rg_sel);
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "chance of success");
	draw_set_halign(fa_right);
	if (_od.p < 0) { draw_set_color(_dim); draw_text(_tx + _tw, _ty, "seat a crew"); }
	else {
		var _pc = round(_od.p * 100);
		draw_set_color((_pc >= 70) ? c_sgreen : ((_pc >= 40) ? c_gold : c_hred));
		draw_text(_tx + _tw, _ty, "about " + string(_pc) + "%  (" + string(round(_od.fights)) + ((_od.fights == 1) ? " fight" : " fights") + " expected)");
	}
	draw_set_halign(fa_left);
	// THE STANCE (2026-09-16): three pills on a row of the numbers, the blurb under them; the rects for the Step's taps
	_ty += 10;
	draw_set_color(_ink); draw_set_alpha(.8);
	draw_text(_tx, _ty, "stance");
	dp_stance_rects = [];
	var _sks = ["cautious", "steady", "greedy"], _sx = _tx + _tw;
	for (var _si = 2; _si >= 0; _si--) {
		var _sst = exped_stance(_sks[_si]), _sw = string_width(_sst.name) + 8;
		_sx -= _sw;
		var _son = (dp_stance == _sks[_si]);
		draw_sprite_ext(spr_pixel_1x1, 0, _sx, _ty - 1, _sw, 10, 0, _son ? merge_colour(_sst.col, c_black, .7) : c_black, .8);
		draw_px_rect(_sx, _ty - 1, _sw, 10, _son ? _sst.col : _dim, _son ? .9 : .35);
		draw_set_halign(fa_center); draw_set_color(_son ? c_white : _dim); draw_set_alpha(_son ? .95 : .6);
		draw_text(_sx + _sw * .5, _ty, _sst.name);
		draw_set_halign(fa_left);
		array_push(dp_stance_rects, { x : _sx, y : _ty - 1, w : _sw, h : 10, key : _sks[_si] });
		_sx -= 3;
	}
	_ty += 10;
	draw_set_halign(fa_right); draw_set_color(_dim); draw_set_alpha(.7);
	draw_text(_tx + _tw, _ty, exped_stance(dp_stance).blurb);
	draw_set_halign(fa_left);
	// THE SEATS, inside the box: a [+] while empty, the banner when taken, a [-] beside it
	draw_set_color(_dim); draw_set_alpha(.5);
	draw_text(_tx, _lay.seat_y0 - 12, "the party  -  " + string(_np) + " of " + string(_ns));
	// THE SEATS as single-line rows (his ask, 2026-09-16): "Temoo (ranger)      lv 1"; an empty one a dim "+"; a press on a filled one unseats it
	for (var _j = 0; _j < _ns; _j++) {
		var _sr = __dp_seat_r(_j);
		var _sid = dp_slots[_j];
		var _ssp = (_sid >= 0) ? __sp_by_id(_sid) : undefined;
		draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, _sr.w, _sr.h, 0, c_black, .6);
		draw_px_rect(_sr.x, _sr.y, _sr.w, _sr.h, is_undefined(_ssp) ? _dim : _ssp.col, is_undefined(_ssp) ? .3 : .55);
		if (is_undefined(_ssp)) {
			draw_set_halign(fa_center); draw_set_color(_dim); draw_set_alpha(.45);
			draw_text(_sr.x + _sr.w * .5, _sr.y + 2, "+");
			draw_set_halign(fa_left);
		} else {
			var _scl = sprite_classes()[sprite_sheet(_ssp).cls];
			draw_sprite_ext(spr_pixel_1x1, 0, _sr.x, _sr.y, 2, _sr.h, 0, _ssp.col, .9);
			__dot(_sr.x + 9, _sr.y + 6, 3, _ssp.col, .95);
			draw_set_color(c_white); draw_set_alpha(.95);
			draw_text(_sr.x + 16, _sr.y + 2, str_cap(_ssp.name));
			draw_set_color(_scl.col); draw_set_alpha(.85);
			draw_text(_sr.x + 16 + string_width(str_cap(_ssp.name)) + 4, _sr.y + 2, "(" + _scl.name + ")");
			draw_set_halign(fa_right); draw_set_color(_ink); draw_set_alpha(.75);
			draw_text(_sr.x + _sr.w - 4, _sr.y + 2, "lv " + string(sprite_sheet(_ssp).lv));
			draw_set_halign(fa_left);
		}
	}
	// [depart]
	var _dr = __depart_r();
	var _can = (_np > 0 && _have >= _cost.total);
	draw_ui_button(_dr.x, _dr.y, _dr.w, _dr.h, (_np == 0) ? "seat a crew" : ((_have < _cost.total) ? "short of credits" : "depart"), _can ? c_sgreen : c_gray, true, _can);
	// THE SHEET AS A MODAL (a tap on a banner): the crew page's own painter
	// under a dim veil; a press off it closes it
	var _msp = __sp_by_id(dp_sheet);
	if (!is_undefined(_msp)) {
		var _msr = __dp_sheet_r();
		it_rects = [];
		__draw_sheet(_msp, _msr.x, _msr.y, _msr.x + _msr.w, _msr.y + _msr.h);   // (on the mission box, no veil: the list stays live - his ask 2026-09-15)
	}
	ui_fade_set(1);
	return true;
	return false;
}
