/// @description ex_crew_draw(_ink, _dim) -> true when the page is drawn: THE CREW page and the sheet (syst_exped_panel's Draw, q220; self = the panel; ink / dim the colours)
function ex_crew_draw(_ink, _dim) {
	var _cl = __crew_list();
	if (is_undefined(__sp_by_id(sheet_id)) && array_length(_cl) > 0) sheet_id = _cl[0].id;
	it_rects = [];
	// the tabs (a trip's crew only, when it came from a trip's page)
	draw_set_color(_ink); draw_set_alpha(.6);
	draw_text(land ? 14 : 4, list_y + 6, (crew_trip >= 0) ? "the crew on this trip" : ("the crew  -  " + string(array_length(g.sprites)) + " of " + string(SPRITE_CAP)));
	for (var _k = 0; _k < array_length(_cl); _k++) {
		var _sp = _cl[_k];
		var _tb = __tab_r(_k);
		if (_tb.y + _tb.h > room_height - 4) break;
		var _on = (_sp.id == sheet_id);
		var _away = (_sp[$ "trip"] ?? false);
		draw_sprite_ext(spr_pixel_1x1, 0, _tb.x, _tb.y, _tb.w, _tb.h, 0, _on ? merge_colour(_sp.col, c_black, .75) : c_black, _on ? .95 : .6);
		draw_px_rect(_tb.x, _tb.y, _tb.w, _tb.h, _sp.col, _on ? .9 : .3);
		if (_on) draw_sprite_ext(spr_pixel_1x1, 0, _tb.x + _tb.w, _tb.y, 10, _tb.h, 0, merge_colour(_sp.col, c_black, .75), .95);   // the tab bleeds into the sheet
		__dot(_tb.x + 7, _tb.y + 7, 3, _sp.col, _away ? .4 : .95);
		if (is_struct(_sp[$ "egg"])) draw_sprite_ext(spr_pixel_1x1, 0, _tb.x + 10, _tb.y + 9, 2, 3, 0, _sp.egg.col, .95);   // (the egg it keeps, 2026-09-16)
		draw_set_color(_on ? c_white : _ink); draw_set_alpha(_on ? .95 : .75);
		draw_text(_tb.x + 14, _tb.y + 3, string_copy(_sp.name, 1, land ? 8 : 6));
		draw_set_halign(fa_right);
		draw_set_color(_dim); draw_set_alpha(.7);
		var _tsh = sprite_sheet(_sp);
		draw_text(_tb.x + _tb.w - 3, _tb.y + 3, "lv" + string(_tsh.lv));
		if (_tsh[$ "abnew"] ?? false) { draw_set_color(c_gold); draw_set_alpha(.7 + .3 * dsin(current_time * .4)); draw_text(_tb.x + _tb.w - 3 - string_width("lv" + string(_tsh.lv)) - 4, _tb.y + 3, "new"); }   // (an ability to look at, 2026-09-17)
		draw_set_halign(fa_left);
	}
	// THE CLUTCH (2026-09-16): the eggs at home under the tabs - each its colour, and how long it has to go
	var _eggs = g.exped[$ "eggs"];
	if (crew_trip < 0 && is_array(_eggs) && array_length(_eggs) > 0) {
		var _etb = __tab_r(array_length(_cl)), _ey = _etb.y + 6;
		draw_set_color(_ink); draw_set_alpha(.5); draw_text(_etb.x, _ey, "the clutch"); _ey += 11;
		for (var _gi = 0; _gi < array_length(_eggs); _gi++) {
			if (_ey + 10 > room_height - 8) break;
			var _eg = _eggs[_gi], _left = _eg.hatch - universal_now();
			// the egg: five rows, an egg's outline, its colour
			var _ex = _etb.x + 3;
			draw_sprite_ext(spr_pixel_1x1, 0, _ex + 1, _ey, 3, 1, 0, _eg.col, .95); draw_sprite_ext(spr_pixel_1x1, 0, _ex, _ey + 1, 5, 4, 0, _eg.col, .95); draw_sprite_ext(spr_pixel_1x1, 0, _ex + 1, _ey + 5, 3, 1, 0, _eg.col, .95);
			draw_sprite_ext(spr_pixel_1x1, 0, _ex + 1, _ey + 1, 1, 1, 0, c_white, .5);
			var _etx = (array_length(g.sprites) >= SPRITE_CAP && _left <= 0) ? "needs room" : ((_left <= 0) ? "any moment" : ((_left < 3600) ? "under an hour" : (string(ceil(_left / 3600)) + "h")));
			draw_set_color(_dim); draw_set_alpha(.8); draw_text(_ex + 9, _ey - 1, __sheet_cut(_eg.word + " - " + _etx, _etb.w - 12));
			_ey += 10;
		}
	}
	// the sheet
	var _sp = __sp_by_id(sheet_id);
	if (is_undefined(_sp)) { draw_set_color(_dim); draw_set_alpha(.5); draw_text(__sheet_x0(), list_y + 24, "no sprites yet"); ui_fade_set(1); return true; }
	__draw_sheet(_sp, __sheet_x0(), list_y + 22, room_width - (land ? 14 : 4), (mode == "sprites") ? (room_height - 8 - 30) : undefined, false);   // (30, not 20: the foot's two lines sit UNDER the sheet, not across its border - his report, 2026-09-17; the popups come after the foot)
	// THE SPRITE MENU's foot (2026-09-16): the card's lines (what it is, what it does) and [dismiss] - armed, then sure
	if (mode == "sprites") {
		var _fy = room_height - 8 - 16, _fx = __sheet_x0() + 8;
		var _ri = upgrade_rarity_info(_sp[$ "rar"] ?? 0), _lk = sprite_looks(), _pl2 = sprite_personalities();
		var _pn = _pl2[clamp(_sp.pers, 0, array_length(_pl2) - 1)].name, _mn = _lk.mats[clamp(_sp[$ "mat"] ?? 0, 0, array_length(_lk.mats) - 1)].name;
		draw_set_halign(fa_left); draw_set_color(_ri.col); draw_set_alpha(.9); draw_text(_fx, _fy + 4, _ri.name + "  -  " + _pn + "  -  " + _mn);
		var _job = _sp[$ "job"] ?? "tap";
		draw_set_color(_dim); draw_set_alpha(.8); draw_text(_fx, _fy - 11, "task: " + ((_job == "tap") ? "autotapping" : _job) + "  -  taps " + string(_sp.taps) + (((_sp[$ "away"] ?? 0) > 0) ? ("  (" + string(_sp.away) + " while idle)") : ""));
		var _dr = __dismiss_r(), _away2 = (_sp[$ "trip"] ?? false);
		draw_ui_button(_dr.x, _dr.y, _dr.w, _dr.h, _away2 ? "away" : "dismiss", c_gray, !_away2, false);
	}
	__draw_sheet_pops();   // (over the foot - his report, 2026-09-17: the task line drew through the gear tooltip)
	// THE DISMISS QUESTIONS (his ask, 2026-09-17: "that one popup confirmation...
	// with an 'are you sure' second popup"): the confirm popup, twice
	if (conf_a > .01 && (conf_kind == "dismiss" || conf_kind == "dismiss2")) __draw_confirm(__dismiss_q(_sp), (conf_kind == "dismiss2") ? "yes, dismiss" : "dismiss", c_hred);   // (conf_kind: it fades out with its face on)
	ui_fade_set(1);
	return true;
	return false;
}
