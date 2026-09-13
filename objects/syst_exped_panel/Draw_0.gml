/// the expeditions' face - hub / trip / haul by `view`. Everything is
/// stamps and text under the fade; the portraits are sh_planet_lite on
/// a square quad (a shader of its own, reset before the text).
var _e   = g.exped;
var _dim = dim;
var _ink = sett_ink;
var _ea  = ui_anim_in(oa, 0);
if (_ea < .001) exit;
ui_fade_set(_ea);
draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _br = abs(dsin(current_time * .3));

// the ground + the strip
draw_sprite_ext(spr_pixel_1x1, 0, 0, hh, room_width, room_height - hh, 0, c_black, .94);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y, room_width, 16, 0, c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, strip_y + 15, room_width, 1, 0, _ink, .25);
draw_set_color(c_steelblue);
draw_set_alpha(.95);
draw_text(6, strip_y + 5, "expeditions");
if (land) {
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(6 + string_width("expeditions") + 8, strip_y + 5,
		(array_length(_e.trips) == 0) ? "" : (string(array_length(_e.trips)) + " out"));
}
// the debug clock
for (var _k = 0; _k < 3; _k++) {
	var _r = __spd_r(_k);
	var _on = (_e.spd == [1, 10, 100][_k]);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, c_black, .8);
	draw_px_rect(_r.x, _r.y, _r.w, _r.h, _on ? c_lavender : rgb(170, 190, 230), _on ? .9 : .4);
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_lavender : _dim);
	draw_set_alpha(.9);
	draw_text(_r.x + _r.w * .5, _r.y + 3, "x" + string([1, 10, 100][_k]));
}
draw_set_halign(fa_left);

// [back], on a page
if (view != "hub") {
	var _bk = __back_r();
	draw_sprite_ext(spr_pixel_1x1, 0, _bk.x, _bk.y, _bk.w, _bk.h, 0, c_black, .8);
	draw_px_rect(_bk.x, _bk.y, _bk.w, _bk.h, rgb(170, 190, 230), .5);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.9);
	draw_text(_bk.x + _bk.w * .5, _bk.y + 3, "< back");
	draw_set_halign(fa_left);
}

// ======================= THE HAUL =======================
if (view == "haul") {
	var _hi = __haul_i();
	if (_hi < 0) { ui_fade_set(1); exit; }
	var _h = _e.hauls[_hi];
	var _found = 0;
	for (var _i = 0; _i < array_length(_h.finds); _i++) if (_h.finds[_i].kind == "sprite") _found++;
	var _recruit = (_found > 0 && array_length(g.sprites) + _found > SPRITE_CAP);

	if (swap_pick) {
		// THE ROSTER: who makes room
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
		exit;
	}

	ui_fade_set(1); shader_reset();
	var _cw = land ? 260 : (room_width - 8), _ch = 40 + array_length(_h.finds) * 12 + (_recruit ? 52 : 40);
	var _cx = (room_width - _cw) * .5, _cy = max(list_y + 22, (room_height - _ch) * .5 - 6);
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
	draw_text(_cx + 42, _cy + 8, exped_crew_txt(_h.names) + ((array_length(_h.names) > 1) ? " are" : " is") + " back from " + _h.dest.name);
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
		draw_text(_cx + _cw - 10, _ry, (_l.kind == "sprite" && _recruit) ? "a sprite - wants to join" : _l.txt);
	}
	draw_set_halign(fa_left);
	if (_recruit) {
		draw_set_halign(fa_center);
		draw_set_color(c_gold);
		draw_set_alpha(.9);
		draw_text(room_width * .5, _cy + _ch - 34, "the roster is full (" + string(SPRITE_CAP) + ")");
		draw_set_halign(fa_left);
		var _sw = __swap_r(), _go = __go_r();
		draw_ui_button(_sw.x, _sw.y, _sw.w, _sw.h, "swap one out", c_gold, true, true);
		draw_ui_button(_go.x, _go.y, _go.w, _go.h, "let them go", c_gray, true, false);
	} else {
		var _cb = __col_r();
		draw_ui_button(_cb.x, _cb.y, _cb.w, _cb.h, "collect", c_gold, true, true);
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE TRIP =======================
if (view == "trip") {
	var _tr = __trip();
	if (is_undefined(_tr)) { ui_fade_set(1); exit; }
	var _d  = _tr.dest;
	var _b  = exped_biomes()[_d.biome];
	var _n  = array_length(_tr.sids);
	// THE WORLD: the full planet (planet_get / planet_draw - the tech
	// demo's raycast sphere with the mountains) over its own stars; the
	// lite portrait holds the spot while the world is still being built
	draw_sprite_ext(spr_pixel_1x1, 0, big_x, big_y, big_w, big_h, 0, c_black, .95);
	ui_fade_set(1);
	planet_sky_draw(_d.seed, big_x + 2, big_y + 2, big_w - 4, land ? 100 : 60);
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _pcx = big_x + big_w * .5, _pcy = big_y + (land ? 48 : 30), _ppr = land ? 34 : 20;
	if (_pn.row >= _pn.th) planet_draw(_pn, _pcx, _pcy, _ppr);
	else __portrait(_d, _pcx, _pcy, _ppr);
	draw_px_rect(big_x, big_y, big_w, big_h, merge_colour(_b.col2, c_white, .2), .5);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(big_x + big_w * .5, big_y + (land ? 88 : 54), _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.8);
	draw_text(big_x + big_w * .5, big_y + (land ? 98 : 64), _b.name + " world  -  tier " + string(_d.tier));
	draw_set_halign(fa_left);
	// the crew's hp, one bar each
	for (var _k = 0; _k < _n; _k++) {
		var _hy = big_y + (land ? 112 : 76) + _k * 11;
		if (_hy + 8 > big_y + big_h) break;
		__dot(big_x + 12, _hy + 3, 3, _tr.cols[_k], (_tr.hp[_k] > 0) ? .95 : .3);
		draw_set_color((_tr.hp[_k] > 0) ? _ink : _dim);
		draw_set_alpha(.8);
		draw_text(big_x + 19, _hy - 1, _tr.names[_k]);
		var _bw = big_w - 24 - 52;
		var _hf = clamp(_tr.hp[_k] / max(1, _tr.hpmax[_k]), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, big_x + big_w - 12 - _bw, _hy + 1, _bw, 4, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, big_x + big_w - 12 - _bw, _hy + 1, _bw * _hf, 4, 0, (_hf > .35) ? c_sgreen : c_hred, .9);
	}

	// the stage track: travel | delve | return
	var _sx = log_x, _sy = log_y, _sw = log_w;
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
	draw_text(_sx + _sw, _sy + 18, ((_tr.stage == 0) ? "travelling" : ((_tr.stage == 1) ? "delving" : "returning"))
		+ "  -  " + crunch_time_long(_left * 60) + ((_e.spd > 1) ? (" at x" + string(_e.spd)) : ""));
	draw_set_halign(fa_left);
	for (var _i = 0; _i < EXPED_ROOMS; _i++) {
		var _px = _m1 + (_m2 - _m1) * (_i + 1) / EXPED_ROOMS;
		var _done = (_i <= _tr.room_i);
		var _kc = c_white;
		switch (_tr.rooms[_i]) { case "find": _kc = c_gold; break; case "rest": _kc = c_sgreen; break; case "trap": _kc = c_horange; break; case "fight": _kc = c_hred; break; }
		draw_sprite_ext(spr_pixel_1x1, 0, _px - 2, _sy + 9, 4, 4, 0, _done ? _kc : c_black, _done ? .95 : .8);
		if (!_done) draw_px_rect(_px - 2, _sy + 9, 4, 4, _kc, .5);
	}

	// THE COMBAT WINDOW, while a fight is on - or while a fight that
	// ended off screen REPLAYS from its film (rp): a square at the
	// column's foot - the foe top right, the crew bottom left, hp bars,
	// a flash on whoever was just hit, the line beside it
	var _fighting = !is_undefined(_tr.fight) || !is_undefined(rp);
	var _fy = room_height - 8 - fight_s;
	if (_fighting) {
		var _f = _tr.fight;
		if (is_undefined(_f)) {
			// the film's frame as a fight: hp from the event, the flash on
			// its target, the party's shape from the record
			var _fr = rp.r.ev[rp.i];
			var _pp = [];
			for (var _q = 0; _q < array_length(rp.r.party); _q++) {
				var _pm = rp.r.party[_q];
				array_push(_pp, { name : _pm.name, col : _pm.col, hpmax : _pm.hpmax,
				                  hp : (_q < array_length(_fr.php)) ? _fr.php[_q] : _pm.hp });
			}
			_f = { party : _pp, b : { name : rp.r.foe.name, hp : _fr.fhp, hpmax : rp.r.foe.hpmax, hit : 0, dmg : 0 },
			       turn : rp.i + 1, over : (rp.i >= array_length(rp.r.ev) - 1), won : rp.r.won,
			       log : [ _fr.txt ], last : (_fr.dmg > 0) ? { side : _fr.side, i : _fr.i, dmg : _fr.dmg, at : current_time - rp.t * 1000 } : undefined,
			       replay : true };
		}
		var _fx = _sx;
		draw_sprite_ext(spr_pixel_1x1, 0, _fx, _fy, fight_s, fight_s, 0, c_black, .85);
		draw_px_rect(_fx, _fy, fight_s, fight_s, c_hred, .5 + .3 * _br);
		// a floor line
		draw_sprite_ext(spr_pixel_1x1, 0, _fx + 4, _fy + fight_s - 12, fight_s - 8, 1, 0, _ink, .2);
		var _flash_t = (!is_undefined(_f.last)) ? clamp(1 - (current_time - _f.last.at) / 350, 0, 1) : 0;
		// the foe
		var _bx = _fx + fight_s - 16, _by = _fy + 22;
		var _bhit = (_flash_t > 0 && _f.last.side == "b");
		var _shk = _bhit ? (irandom(2) - 1) : 0;
		if (_f.b.hp > 0) {
			draw_sprite_ext(spr_pixel_1x1, 0, _bx - 6 + _shk, _by - 6, 12, 12, 45, _bhit ? c_white : c_hred, .95);
		} else draw_sprite_ext(spr_pixel_1x1, 0, _bx - 6, _by + 2, 12, 3, 0, c_hred, .5);
		var _bf = clamp(_f.b.hp / max(1, _f.b.hpmax), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx - 10, _by - 14, 20, 3, 0, c_black, .8);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx - 10, _by - 14, 20 * _bf, 3, 0, c_hred, .9);
		// the crew
		for (var _k = 0; _k < array_length(_f.party); _k++) {
			var _m = _f.party[_k];
			var _mx = _fx + 12 + _k * 13, _my = _fy + fight_s - 20 - (_k mod 2) * 6;
			var _mhit = (_flash_t > 0 && _f.last.side == "a" && _f.last.i == _k);
			var _sk = _mhit ? (irandom(2) - 1) : 0;
			if (_m.hp > 0) __dot(_mx + _sk, _my, 5, _mhit ? c_white : _m.col, .95);
			else __dot(_mx, _my + 4, 5, _m.col, .25);
			var _mf = clamp(_m.hp / max(1, _m.hpmax), 0, 1);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 6, _my - 10, 12, 2, 0, c_black, .8);
			draw_sprite_ext(spr_pixel_1x1, 0, _mx - 6, _my - 10, 12 * _mf, 2, 0, (_mf > .35) ? c_sgreen : c_horange, .9);
		}
		// the damage number, floating off the one hit
		if (_flash_t > 0) {
			draw_set_halign(fa_center);
			draw_set_color(c_white);
			draw_set_alpha(_flash_t);
			var _dx = (_f.last.side == "b") ? _bx : (_fx + 12 + _f.last.i * 13);
			var _dy = ((_f.last.side == "b") ? _by : (_fy + fight_s - 20)) - 16 - (1 - _flash_t) * 8;
			draw_text(_dx, _dy, "-" + string(_f.last.dmg));
			draw_set_halign(fa_left);
		}
		// beside it: the foe, the turn, the last line
		var _tx = _fx + fight_s + 8;
		draw_set_color(c_hred);
		draw_set_alpha(.95);
		draw_text(_tx, _fy + 2, _f.b.name + "  " + string(_f.b.hp) + "/" + string(_f.b.hpmax));
		draw_set_color(_dim);
		draw_set_alpha(.7);
		if (_f[$ "replay"] ?? false)
			draw_text(_tx, _fy + 12, "replay  -  room " + string(rp.r.room + 1) + "  -  tap to skip");
		else
			draw_text(_tx, _fy + 12, "turn " + string(_f.turn) + "  -  hit " + string(round(_f.b.hit)) + "%  dmg " + string_format(_f.b.dmg, 1, 1));
		var _fl = array_length(_f.log);
		draw_set_color(c_white);
		draw_set_alpha(.9);
		draw_text_ext(_tx, _fy + 24, (_fl > 0) ? _f.log[_fl - 1] : "...", 9, _sw - fight_s - 8);
		if (!(_f[$ "replay"] ?? false)) {
			var _st = __step_r();
			draw_ui_button(_st.x, _st.y, _st.w, _st.h, _f.over ? "done" : "step turn", c_hred, !_f.over, !_f.over);
		} else if (_f.over) {
			draw_set_color(_f.won ? c_sgreen : c_hred);
			draw_set_alpha(.9);
			draw_text(_tx, _fy + fight_s - 12, _f.won ? "won" : "routed");
		}
	}

	// THE DIARY: truth lines plain, the "~ " lines (exped_say) as the
	// crew's own voice - dimmer, indented, wrapped to the column.
	// Newest at the bottom; as many whole entries as fit above it
	var _ly = _sy + 30;
	var _ly_end = _fighting ? (_fy - 6) : (room_height - 10);
	var _nl = array_length(_tr.log);
	var _hs = array_create(_nl, 0);
	var _room = _ly_end - _ly;
	var _from = _nl;
	for (var _i = _nl - 1; _i >= 0; _i--) {
		var _isv = (string_copy(_tr.log[_i], 1, 2) == "~ ");
		var _h = string_height_ext(_isv ? string_delete(_tr.log[_i], 1, 2) : _tr.log[_i], 9, _sw - (_isv ? 8 : 0)) + 2;
		if (_h > _room) break;
		_room -= _h;
		_hs[_i] = _h;
		_from = _i;
	}
	var _yy = _ly;
	for (var _i = _from; _i < _nl; _i++) {
		var _isv = (string_copy(_tr.log[_i], 1, 2) == "~ ");
		var _last = (_i == _nl - 1);
		if (_isv) {
			draw_set_color(_last ? merge_colour(_ink, c_white, .5) : merge_colour(_ink, _b.col2, .35));
			draw_set_alpha(_last ? .9 : .55);
			draw_text_ext(_sx + 8, _yy, string_delete(_tr.log[_i], 1, 2), 9, _sw - 8);
		} else {
			draw_set_color(_last ? c_white : _ink);
			draw_set_alpha(_last ? .95 : .7);
			draw_text_ext(_sx, _yy, _tr.log[_i], 9, _sw);
		}
		_yy += _hs[_i];
	}
	ui_fade_set(1);
	exit;
}

// ======================= THE HUB =======================
// the destinations
draw_set_color(_ink);
draw_set_alpha(.6);
draw_text(card_x0, card_y - 10, "worlds on offer");
for (var _i = 0; _i < array_length(_e.board); _i++) {
	var _d = _e.board[_i];
	var _b = exped_biomes()[_d.biome];
	var _c = __card_r(_i);
	var _on = (sel_dest == _i);
	var _out = 0;
	for (var _t = 0; _t < array_length(_e.trips); _t++) if (_e.trips[_t].dest.seed == _d.seed) _out++;
	draw_sprite_ext(spr_pixel_1x1, 0, _c.x, _c.y, _c.w, _c.h, 0, c_black, .8);
	draw_px_rect(_c.x, _c.y, _c.w, _c.h, _on ? c_white : merge_colour(_b.col2, c_white, .2), _on ? .9 : .4);
	ui_fade_set(1);
	__portrait(_d, _c.x + _c.w * .5, _c.y + (land ? 22 : 16), land ? 15 : 11);
	ui_fade_set(_ea);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_c.x + _c.w * .5, _c.y + (land ? 42 : 32), _d.name);
	draw_set_color(merge_colour(_b.col2, c_white, .3));
	draw_set_alpha(.85);
	draw_text(_c.x + _c.w * .5, _c.y + (land ? 52 : 42), land ? (_b.name + "  -  tier " + string(_d.tier)) : ("t" + string(_d.tier)));
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_c.x + _c.w * .5, _c.y + (land ? 62 : 52), land ? (_b.hint + "  -  " + crunch_time_long(_d.dist * 60 / max(1, _e.spd))) : crunch_time_long(_d.dist * 60 / max(1, _e.spd)));
	if (_out > 0) {
		draw_set_color(c_steelblue);
		draw_set_alpha(.9);
		draw_text(_c.x + _c.w * .5, _c.y + _c.h - 9, string(_out) + " out");
	}
}
draw_set_halign(fa_left);

// the crew: tap to pick a party
draw_set_color(_ink);
draw_set_alpha(.6);
var _np = array_length(sel_crew);
draw_text(card_x0, crew_y, (array_length(g.sprites) > 0)
	? ("the crew - tap up to " + string(EXPED_PARTY) + ((_np > 0) ? ("  -  " + string(_np) + " picked") : ""))
	: "no sprites yet - spawn one (the debug sprite) to send it");
for (var _k = 0; _k < array_length(g.sprites); _k++) {
	var _sp = g.sprites[_k];
	var _cr = __chip_r(_k);
	var _away = (_sp[$ "trip"] ?? false);
	var _ok = !_sp.asleep && !_away;
	var _at = array_get_index(sel_crew, _sp.id);
	draw_sprite_ext(spr_pixel_1x1, 0, _cr.x, _cr.y, _cr.w, _cr.h, 0, c_black, .7);
	draw_px_rect(_cr.x, _cr.y, _cr.w, _cr.h, (_at >= 0) ? c_white : _sp.col, (_at >= 0) ? .9 : (_ok ? .5 : .2));
	__dot(_cr.x + _cr.w * .5, _cr.y + _cr.h * .5 - 1, land ? 6 : 4, _sp.col, _ok ? .95 : .3);
	if (_at >= 0) {
		draw_set_halign(fa_center);
		draw_set_color(c_black);
		draw_set_alpha(.9);
		draw_text(_cr.x + _cr.w * .5 + 1, _cr.y + _cr.h * .5 - 4, string(_at + 1));
	}
	draw_set_halign(fa_center);
	draw_set_color(_ok ? _ink : _dim);
	draw_set_alpha(_ok ? .8 : .5);
	draw_text(_cr.x + _cr.w * .5, _cr.y + _cr.h + 1, _away ? "out" : (_sp.asleep ? "zz" : string_copy(_sp.name, 1, land ? 5 : 3)));
}
draw_set_halign(fa_left);
var _sr = __send_r();
var _can = (sel_dest >= 0 && _np > 0);
draw_ui_button(_sr.x, _sr.y, _sr.w, _sr.h,
	_can ? ("send " + string(_np) + " to " + _e.board[sel_dest].name) : ((sel_dest < 0) ? "pick a world" : "pick a crew"),
	_can ? c_sgreen : c_gray, true, _can);

// THE LIST: hauls waiting, then trips out
draw_set_color(_ink);
draw_set_alpha(.6);
var _ly0 = __list_y0();
draw_text(list_x, _ly0 + 2, "expeditions");
var _rows = array_length(_e.hauls) + array_length(_e.trips);
if (_rows == 0) {
	draw_set_color(_dim);
	draw_set_alpha(.5);
	draw_text_ext(list_x, _ly0 + 14, "none out. pick a world and a crew, and send them.", 9, list_w);
}
for (var _i = 0; _i < _rows; _i++) {
	var _rr = __row_r(_i);
	if (_rr.y + _rr.h > room_height - 4) break;
	var _ish = (_i < array_length(_e.hauls));
	var _r  = _ish ? _e.hauls[_i] : _e.trips[_i - array_length(_e.hauls)];
	var _rb = exped_biomes()[_r.dest.biome];
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, _rr.h, 0, c_hsv(169, 160, 7), .96);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, _rr.w, 1, 0, c_white, .07);
	draw_sprite_ext(spr_pixel_1x1, 0, _rr.x, _rr.y, 2, _rr.h, 0, _ish ? c_gold : c_steelblue, .85);
	ui_fade_set(1);
	__portrait(_r.dest, _rr.x + 16, _rr.y + _rr.h * .5, 9);
	ui_fade_set(_ea);
	// the crew's faces
	for (var _k = 0; _k < array_length(_r.sids); _k++) __dot(_rr.x + 34 + _k * 9, _rr.y + 9, 3, _r.cols[_k],
		(_ish || _r.hp[_k] > 0) ? .95 : .3);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_rr.x + 34 + array_length(_r.sids) * 9 + 3, _rr.y + 5, _r.dest.name);
	if (_ish) {
		draw_set_color(_r.routed ? c_horange : c_gold);
		draw_set_alpha(.9);
		draw_text(_rr.x + 34, _rr.y + 18, _r.routed ? "limped home  -  collect" : "back  -  collect the haul");
	} else {
		// the progress track with the room pips, and the state
		var _tw = _rr.w - 40;
		var _tf = clamp(_r.t / max(1, _r.dur), 0, 1);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x + 34, _rr.y + 21, _tw, 4, 0, c_black, .7);
		draw_sprite_ext(spr_pixel_1x1, 0, _rr.x + 34, _rr.y + 21, _tw * _tf, 4, 0, c_steelblue, .9);
		var _q1 = _rr.x + 34 + _tw * EXPED_TRAVEL, _q2 = _rr.x + 34 + _tw * (1 - EXPED_RETURN);
		for (var _p = 0; _p < EXPED_ROOMS; _p++) {
			var _px = _q1 + (_q2 - _q1) * (_p + 1) / EXPED_ROOMS;
			var _done = (_p <= _r.room_i);
			var _kc = c_white;
			switch (_r.rooms[_p]) { case "find": _kc = c_gold; break; case "rest": _kc = c_sgreen; break; case "trap": _kc = c_horange; break; case "fight": _kc = c_hred; break; }
			draw_sprite_ext(spr_pixel_1x1, 0, _px - 1, _rr.y + 21, 3, 4, 0, _done ? _kc : c_black, _done ? .95 : .6);
		}
		draw_set_halign(fa_right);
		draw_set_color(!is_undefined(_r.fight) ? c_hred : _dim);
		draw_set_alpha(.8);
		var _left = max(0, _r.dur - _r.t) / max(1, _e.spd);
		draw_text(_rr.x + _rr.w - 6, _rr.y + 5, !is_undefined(_r.fight) ? "fighting" : (_r.routed ? "routed - returning" : ((_r.stage == 0) ? "travelling" : ((_r.stage == 1) ? ("room " + string(max(0, _r.room_i + 1))) : "returning")) + "  " + crunch_time_long(_left * 60)));
		draw_set_halign(fa_left);
	}
}
ui_fade_set(1);
