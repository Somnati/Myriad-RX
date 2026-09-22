// THE COLLIDER runs on the wall clock: the frame's real seconds through the exact closed form (a frame or a month, one call)
if (c != g.coll) c = coll_init();   // (a load / reset / crunch swapped the struct under us)
var _now = universal_now(), _el = _now - c.last;
if (_el > 0) coll_tick(c, min(_el, COLL_AWAY_MAX));
c.last = _now;
if (note_t > 0) note_t -= delta / 60;
if (tut && c.collisions > 0) tut = false;
// ---- a pillbox pick lands here (owner-side, the house pattern) ----
if (_pselid != -1) {
	if (pill_kind == "buyq") buy_q = _pselval;
	else if (pill_kind == "pct") { c.pct = _pselval; save_mark_dirty(); }
	pill_kind = ""; _pselid = -1;
	play_sound_ext(snd_matclick2, 1, 1.2, .5, 1);
}
// ---- input (region pattern, arbitrated) ----
if (!input_free()) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (__hit(__back_r())) { play_sound_ext(snd_matclick2, .8, .9, .5, 1); back_room(); exit; }
if (c.inf) {
	if (__hit(__crunch_r())) { coll_crunch(c); c = g.coll; play_sound_ext(snd_cointoss, .9, 1.1, .6, 0); note = "THE BIG CRUNCH - run " + string(c.crunches + 1) + ": tier costs step x" + string_format(coll_stepk(c), 1, 2) + " (the residue)"; note_t = 6; }
	exit;
}
if (__hit(__buyq_r())) {
	pillbox_init(); pill_kind = "buyq";
	var _modes = [[1, "buy x1"], [10, "buy x10"], [100, "buy x100"], ["max", "buy max"]];
	for (var _i = 0; _i < array_length(_modes); _i++) { var _on = (buy_q == _modes[_i][0]); set_pill(_modes[_i][1], { val : _modes[_i][0], col : _on ? c_gold : sett_ink, enabled : _on }); }
	do_pillbox(mouse_x, mouse_y);
	with (obj_pillbox) if (obj == other.id) depth = other.depth - 4;
	exit;
}
if (__hit(__pct_r())) {
	pillbox_init(); pill_kind = "pct";
	var _ps = [10, 25, 50, 100];
	for (var _i = 0; _i < array_length(_ps); _i++) { var _on = (c.pct == _ps[_i]); set_pill(string(_ps[_i]) + "%", { val : _ps[_i], col : _on ? c_gold : sett_ink, enabled : _on }); }
	do_pillbox(mouse_x, mouse_y);
	with (obj_pillbox) if (obj == other.id) depth = other.depth - 4;
	exit;
}
if (__hit(__coll_r())) {
	var _clean = coll_clean(c), _le = coll_collide(c);
	if (_le > COLL_LZ * .5) { play_sound_ext(snd_cointoss, 1.0 + .3 * (_clean - 1), 1.2 + .3 * (_clean - 1), .5, 0); note = "annihilation: +" + coll_fmt(_le) + " energy" + ((_clean > 1.5) ? "  -  a clean collision, x" + string_format(_clean, 1, 2) : ((_clean > 1.05) ? "  (x" + string_format(_clean, 1, 2) + " clean)" : "  -  unbalanced, no clean bonus")); note_t = 4; }
	else { play_sound_ext(snd_matclick, .7, .8, .3, 0); note = "nothing to annihilate: both stocks need at least a unit"; note_t = 3; }
	exit;
}
var _up = ["field", "auto", "magnet"];
for (var _k = 0; _k < 3; _k++) if (__hit(__upg_r(_k))) {
	if (coll_buy(c, _up[_k])) { play_sound_ext(snd_softclick, 1.05, 1.2, .5, 1); note = (_k == 0) ? ("the field: x" + string_format(power(COLL_FIELD_MULT, c.field), 1, 2) + " on every tier, both sides") : ((_k == 1) ? ("the auto-collider fires every " + string(coll_auto_every(c.auto_lv)) + " s at " + string(c.pct) + "%") : ("the magnet: a clean collision within a factor of " + string_format(power(2, power(COLL_MAGNET_MULT, c.magnet_lv)), 1, 1))); note_t = 4; }
	else { play_sound_ext(snd_matclick, .7, .8, .3, 0); note = (coll_cost(c, _up[_k]) < 0) ? "at the top" : "not enough energy"; note_t = 2; }
	exit;
}
for (var _s = 0; _s < 2; _s++) for (var _i = 0; _i < 8; _i++) if (__hit(__tbuy_r(_s, _i))) {
	var _did = coll_tier_buy(c, _s, _i, buy_q);
	play_sound_ext(_did > 0 ? snd_matclick2 : snd_matclick, _did > 0 ? 1.1 : .7, _did > 0 ? 1.3 : .8, .5, 1);
	if (_did <= 0) { var _lk = (_i > 0 && ((_s == 0) ? c.m : c.a).bought[_i - 1] <= 0); note = _lk ? ("buy a " + tier_name[_i - 1] + " " + side_name[_s] + " first") : ("a " + side_name[_s] + " tier is paid in " + side_name[1 - _s] + " - not enough"); note_t = 3; }
	exit;
}
