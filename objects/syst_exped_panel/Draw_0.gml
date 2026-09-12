/// the bench's face - board / trip / haul by state. Everything is
/// stamps and text under the fade; the portraits are sh_planet_lite on
/// a square quad (a shader of its own, reset before the text).
var _e   = g.exped;
var _dim = rgb(120, 130, 150);
var _ink = sett_ink;
var _ea  = ui_anim_in(oa, 0);
if (_ea < .001) exit;
ui_fade_set(_ea);
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// the ground + the strip
draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, room_height - hh, 0, c_black, .94);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y + 15, room_width, 1, 0, _ink, .25);
draw_set_color(c_steelblue);
draw_set_alpha(.95);
draw_text(6, strip_y + 5, "expeditions");
draw_set_color(_dim);
draw_set_alpha(.6);
draw_text(80, strip_y + 5, "depth " + string(_e.depth) + "   charms " + string(_e.charms)
	+ "   luck x" + string_format(luck_mod(), 1, 2) + "   (the mock - a bench, not the game)");
// the debug clock
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	var _on = (_e.spd == [1, 10, 100][_k]);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, _on ? merge_colour(c_gold, c_black, .5) : c_black, _on ? .95 : .5);
	draw_px_rect(_r.x, _r.y, _r.w, _r.h, c_gold, _on ? .9 : .3);
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_white : _dim);
	draw_set_alpha(.9);
	draw_text(_r.x + _r.w / 2 + 1, _r.y + 3, "x" + string([1, 10, 100][_k]));
}
draw_set_halign(fa_left);

// ======================= THE HAUL =======================
if (!is_undefined(_e.haul)) {
	ui_fade_set(1); shader_reset();
	var _h = _e.haul;
	var _cw = 260, _ch = 40 + array_length(_h.finds) * 12 + 40;
	var _cx = (room_width - _cw) * .5, _cy = max(list_y + 8, (room_height - _ch) * .5 - 6);
	ui_fade_set(_ea);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, _ch, 0, c_black, .9);
	draw_px_rect(_cx, _cy, _cw, _ch, _h.routed ? c_hred : c_gold, .6);
	draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy, _cw, 1, 0, _h.routed ? c_hred : c_gold, .9);
	ui_fade_set(1);
	__portrait(_h.dest, _cx + 22, _cy + 22, 12);
	ui_fade_set(_ea);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_cx + 42, _cy + 8, _h.sname + " is back from " + _h.dest.name);
	draw_set_color(_h.routed ? c_hred : c_sgreen);
	draw_set_alpha(.85);
	draw_text(_cx + 42, _cy + 19, _h.routed ? ("routed - " + string(_h.cleared) + " of " + string(EXPED_ROOMS) + " rooms")
		: (string(_h.cleared) + " of " + string(EXPED_ROOMS) + " rooms cleared"));
	draw_sprite_ext(spr_pixel_1x1, 0, _cx + 8, _cy + 34, _cw - 16, 1, 0, _ink, .25);
	for (var _i = 0; _i < array_length(_h.finds); _i++) {
		var _l = _h.finds[_i];
		var _ry = _cy + 40 + _i * 12;
		draw_set_halign(fa_left);
		draw_set_color(_ink);
		draw_set_alpha(.55);
		draw_text(_cx + 10, _ry, (_i == 0) ? "the floor" : ("room find " + string(_i)));
		draw_set_halign(fa_right);
		draw_set_color(_l.col);
		draw_set_alpha(.95);
		draw_text(_cx + _cw - 10, _ry, _l.txt);
	}
	draw_set_halign(fa_left);
	var _cb = __col_r();
	draw_ui_button(_cb.x, _cb.y, _cb.w, _cb.h, "collect", c_gold, true, true);
	ui_fade_set(1);
	exit;
}

// ======================= THE TRIP =======================
if (!is_undefined(_e.trip)) {
	var _tr = _e.trip;
	var _d  = _tr.dest;
	var _b  = exped_biomes()[_d.biome];
	// the world's card, big
	draw_sprite_ext(spr_pixel_1x1, 0, big_x, big_y, big_w, big_h, 0, c_black, .8);
	draw_px_rect(big_x, big_y, big_w, big_h, merge_colour(_b.col2, c_white, .2), .5);
	ui_fade_set(1);
	__portrait(_d, big_x + big_w * .5, big_y + 52, 36);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(big_x + big_w * .5, big_y + 96, _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.8);
	draw_text(big_x + big_w * .5, big_y + 108, _b.name + " world  -  tier " + string(_d.tier));
	// the crew's hp
	draw_set_color(_ink);
	draw_set_alpha(.6);
	draw_text(big_x + big_w * .5, big_y + 124, _tr.sname);
	var _hf = clamp(_tr.hp / max(1, _tr.hpmax), 0, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, big_x + 20, big_y + 136, big_w - 40, 5, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, big_x + 20, big_y + 136, (big_w - 40) * _hf, 5, 0, (_hf > .35) ? c_sgreen : c_hred, .9);
	draw_px_rect(big_x + 20, big_y + 136, big_w - 40, 5, c_sgreen, .3);
	draw_set_halign(fa_left);

	// the stage bar: travel | delve | return
	var _sx = log_x, _sy = big_y, _sw = log_w;
	var _tf = clamp(_tr.t / max(1, _tr.dur), 0, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy + 8, _sw, 6, 0, c_black, .7);
	draw_sprite_ext(spr_pixel_1x1, 0, _sx, _sy + 8, _sw * _tf, 6, 0, c_steelblue, .9);
	draw_px_rect(_sx, _sy + 8, _sw, 6, c_steelblue, .35);
	var _m1 = _sx + _sw * EXPED_TRAVEL, _m2 = _sx + _sw * (1 - EXPED_RETURN);
	draw_sprite_ext(spr_pixel_1x1, 0, _m1, _sy + 6, 1, 10, 0, c_white, .5);
	draw_sprite_ext(spr_pixel_1x1, 0, _m2, _sy + 6, 1, 10, 0, c_white, .5);
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_sx, _sy + 18, "travel");
	draw_text(_m1 + 4, _sy + 18, "delve");
	draw_text(_m2 + 4, _sy + 18, "return");
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_set_alpha(.85);
	var _left = max(0, _tr.dur - _tr.t) / max(1, _e.spd);
	draw_text(_sx + _sw, _sy + 18, (_tr.stage == 0) ? "travelling" : ((_tr.stage == 1) ? "delving" : "returning")
		+ "  -  " + crunch_time_long(_left * 60) + ((_e.spd > 1) ? (" at x" + string(_e.spd)) : ""));
	draw_set_halign(fa_left);
	// the rooms as pips
	for (var _i = 0; _i < EXPED_ROOMS; _i++) {
		var _px = _m1 + (_m2 - _m1) * (_i + 1) / EXPED_ROOMS;
		var _done = (_i <= _tr.room_i);
		var _kc = c_white;
		switch (_tr.rooms[_i]) { case "find": _kc = c_gold; break; case "rest": _kc = c_sgreen; break; case "trap": _kc = c_horange; break; case "fight": _kc = c_hred; break; }
		draw_sprite_ext(spr_pixel_1x1, 0, _px - 2, _sy + 9, 4, 4, 0, _done ? _kc : c_black, _done ? .95 : .8);
		if (!_done) draw_px_rect(_px - 2, _sy + 9, 4, 4, _kc, .5);
	}

	// the log
	var _ly = _sy + 34;
	var _n = array_length(_tr.log);
	var _from = max(0, _n - 9);
	for (var _i = _from; _i < _n; _i++) {
		draw_set_color((_i == _n - 1) ? c_white : _ink);
		draw_set_alpha((_i == _n - 1) ? .95 : .6);
		draw_text(_sx, _ly + (_i - _from) * 10, _tr.log[_i]);
	}

	// the fight
	if (!is_undefined(_tr.fight)) {
		var _f = _tr.fight;
		var _fy = _sy + 130;
		draw_sprite_ext(spr_pixel_1x1, 0, _sx, _fy, _sw, 70, 0, c_black, .6);
		draw_px_rect(_sx, _fy, _sw, 70, c_hred, .4);
		var _sides = [_f.a, _f.b];
		for (var _k = 0; _k < 2; _k++) {
			var _s = _sides[_k];
			var _bx = _sx + 8 + _k * (_sw * .5);
			draw_set_color((_k == 0) ? c_sgreen : c_hred);
			draw_set_alpha(.95);
			draw_text(_bx, _fy + 6, _s.name);
			draw_set_color(_dim);
			draw_set_alpha(.7);
			draw_text(_bx, _fy + 16, "hit " + string(round(_s.hit)) + "%  init " + string(_s.init) + "  dmg " + string(_s.dmg));
			var _hw = _sw * .5 - 16;
			var _hf2 = clamp(_s.hp / max(1, _s.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _bx, _fy + 27, _hw, 5, 0, c_black, .7);
			draw_sprite_ext(spr_pixel_1x1, 0, _bx, _fy + 27, _hw * _hf2, 5, 0, (_k == 0) ? c_sgreen : c_hred, .9);
			draw_set_color(c_white);
			draw_set_alpha(.85);
			draw_text(_bx, _fy + 34, string(_s.hp) + " / " + string(_s.hpmax));
		}
		var _fl = array_length(_f.log);
		draw_set_color(c_white);
		draw_set_alpha(.9);
		draw_text(_sx + 8, _fy + 50, (_fl > 0) ? _f.log[_fl - 1] : "turn " + string(_f.turn));
		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(_sx + 8, _fy + 60, "turn " + string(_f.turn) + "  -  a turn a second, or step it");
		var _st = __step_r();
		draw_ui_button(_st.x, _st.y, _st.w, _st.h, _f.over ? "done" : "step turn", c_hred, !_f.over, !_f.over);
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE BOARD =======================
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _d = _e.board[_i];
	var _b = exped_biomes()[_d.biome];
	var _c = __card_r(_i);
	var _on = (sel_dest == _i);
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, _c.w, _c.h, 0, c_black, .8);
	draw_px_rect(_c.x, _c.y, _c.w, _c.h, _on ? c_white : merge_colour(_b.col2, c_white, .2), _on ? .9 : .4);
	ui_fade_set(1);
	__portrait(_d, _c.x + _c.w * .5, _c.y + 34, 26);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_c.x + _c.w * .5, _c.y + 66, _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.85);
	draw_text(_c.x + _c.w * .5, _c.y + 77, _b.name + " world  -  tier " + string(_d.tier));
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_c.x + _c.w * .5, _c.y + 87, _b.hint + "  -  " + crunch_time_long(_d.dist * 60 / max(1, _e.spd)));
	draw_set_halign(fa_left);
	var _sr = __send_r(_i);
	var _can = _on && sel_crew >= 0;
	draw_ui_button(_sr.x, _sr.y, _sr.w, _sr.h, _can ? ("send " + g.sprites[sel_crew].name) : (_on ? "pick a sprite" : "choose"),
		_can ? c_sgreen : (_on ? c_gold : c_gray), true, _can);
}
// the crew row
draw_set_color(_ink);
draw_set_alpha(.6);
draw_text(card_x0, crew_y, (array_length(g.sprites) > 0) ? "the crew - tap one to send" : "no sprites yet - spawn one (the debug sprite) to send it");
for (var _k = 0; _k < array_length(g.sprites); _k++) {
	var _sp = g.sprites[_k];
	var _cr = __crew_r(_k);
	var _away = (_sp[$ "trip"] ?? false);
	var _ok = !_sp.asleep && !_away;
	draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, c_black, .7);
	draw_px_rect(_cr.x, _cr.y, _cr.w, _cr.h, (sel_crew == _k) ? c_white : _sp.col, (sel_crew == _k) ? .9 : (_ok ? .5 : .2));
	// the body: a dot in its colour, dim when it cannot go
	draw_sprite_ext(spr_pixel_1x1, 0, _cr.x + 8, _cr.y + 6, 10, 9, 0, _sp.col, _ok ? .95 : .35);
	draw_sprite_ext(spr_pixel_1x1, 0, _cr.x + 9, _cr.y + 5, 8, 11, 0, _sp.col, _ok ? .95 : .35);
	draw_set_halign(fa_center);
	draw_set_color(_ok ? c_white : _dim);
	draw_set_alpha(.8);
	draw_text(_cr.x + _cr.w * .5 + 1, _cr.y + 18, _away ? "away" : (_sp.asleep ? "zzz" : string_copy(_sp.name, 1, 4)));
}
draw_set_halign(fa_left);
if (sel_crew >= 0 && sel_crew < array_length(g.sprites)) {
	var _sp2 = g.sprites[sel_crew];
	draw_set_color(c_white);
	draw_set_alpha(.85);
	draw_text(card_x0, crew_y + 42, _sp2.name + "  -  " + upgrade_rarity_info(_sp2[$ "rar"] ?? 0).name
		+ "  -  hp " + string(8 + (_sp2[$ "rar"] ?? 0) * 2) + "  -  away, it does not tap");
}
// the materials pile, bottom
var _mk = variable_struct_get_names(_e.mats);
if (array_length(_mk) > 0) {
	var _mt = "materials:";
	for (var _i = 0; _i < array_length(_mk); _i++) _mt += "  " + _mk[_i] + " x" + string(_e.mats[$ _mk[_i]]);
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(card_x0, room_height - 18, _mt);
}
ui_fade_set(1);
draw_set_alpha(1);
draw_set_color(c_white);
