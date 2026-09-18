
// ---- the wall-clock advance: real elapsed seconds, one exact call.
// 30-day sim bound, the offline doctrine's cap (the closed form could
// take a century, but floats couldn't) ----
var _now = date_current_datetime() * 86400;
var _el = _now - g.dims.last;
// a real absence earns the room its OWN welcome-back line (his call:
// per-room reports, not the global card): capture dark matter across the
// catch-up tick - log10 delta IS the growth factor
if (_el >= 120 && !g.dims.inf) {
	var _fr = g.dims.dark;
	dims_tick(min(_el, 86400 * 30));
	var _dl = g.dims.dark - _fr;
	if (_dl > 0.001)
		report = { away : _el, t : (_dl < 6)
			? "dark matter x" + string(round(power(10, _dl) * 10) / 10)
			: "dark matter x1e" + string(round(_dl)) };
	rep_t = 300; // frames the line stays up
} else if (_el > 0) dims_tick(min(_el, 86400 * 30));
g.dims.last = _now;
if (rep_t > 0) rep_t -= delta;

// ---- buy-quantity pick lands here (pillbox, owner-side) ----
if (_pselid != -1 && pill_kind == "buyq") {
	buy_q = _pselval;
	pill_kind = "";
	_pselid = -1;
	play_sound_ext(snd_matclick2, 1, 1.2, .5, 1);
}

// ---- input (region pattern, arbitrated) ----
if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left)) {

	// back, top right
	if (point_in_rectangle(mouse_x, mouse_y, room_width - 62, bby + 1,
		room_width - 6, bby + 14)) {
		play_sound_ext(snd_matclick2, .8, .9, .5, 1);
		back_room();
		exit;
	}

	// the buy-quantity dropdown, under the strip (the house pillbox's language)
	if (point_in_rectangle(mouse_x, mouse_y, 6, bby + 20, 96, bby + 34)) {
		pillbox_init();
		pill_kind = "buyq";
		var _modes = [[1, "buy x1"], [10, "buy x10"], [100, "buy x100"],
			["max", "buy max"]];
		for (var _i = 0; _i < array_length(_modes); _i++) {
			var _on = (buy_q == _modes[_i][0]);
			set_pill(_modes[_i][1], { val : _modes[_i][0],
				col : _on ? c_gold : sett_ink, enabled : _on });
		}
		do_pillbox(mouse_x, mouse_y);
		with (obj_pillbox) if (obj == other.id) depth = other.depth - 4;
	}

	// [big crunch] - infinity's only exit (banner button; best rides
	// across the reset inside dims_init)
	if (g.dims.inf)
	if (point_in_rectangle(mouse_x, mouse_y, crunch_x, crunch_y,
		crunch_x + crunch_w, crunch_y + crunch_h)) {
		dims_init(true);
		save_mark_dirty();
		play_sound_ext(snd_matclick2, 1, .8, .6, 1);
	}

	// [reset] - the bench starts over (debug: no confirm)
	if (point_in_rectangle(mouse_x, mouse_y, room_width - 66, bby + 20,
		room_width - 6, bby + 34)) {
		dims_init(true);
		save_mark_dirty();
		play_sound_ext(snd_matclick2, .8, .95, .5, 1);
	}

	// ---- the buy column: row 0 = tickspeed, rows 1..8 = the tiers ----
	if (mouse_x >= buy_x - 60 && mouse_y >= list_y
		&& mouse_y < list_y + 9 * row_h) {
		var _r = floor((mouse_y - list_y) / row_h);
		var _did = 0;
		if (_r == 0) _did = dims_buy("tick", buy_q);
		else _did = dims_buy(_r - 1, buy_q);
		play_sound_ext(_did > 0 ? snd_matclick2 : snd_matclick,
			_did > 0 ? 1.1 : .7, _did > 0 ? 1.3 : .8, .5, 1);
	}
}
