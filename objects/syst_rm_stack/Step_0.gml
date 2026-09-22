// THE STACK runs here a frame at a time (the room is its clock; the catch-up covers the rest)
if (s != g.stk) { s = stk_init(); rep_l = -1; }   // (a load / reset / turn swapped the struct under us)
stk_tick(s, delta / 60);
__layout();
pulse += delta / 60;
if (note_t > 0) note_t -= delta / 60;
if (flash > 0) flash -= delta / 20;
if (tut && s.life >= 1) tut = false;
var _l = s.tab;
// hold-to-repeat on the steppers (the house pattern)
if (rep_l >= 0) {
	if (!mouse_check_button(mb_left)) rep_l = -1;
	else { rep_t -= delta; if (rep_t <= 0) { stk_alloc(s, rep_l, rep_i, rep_dir); rep_t = 3; } }
}
// ---- input (region pattern, arbitrated) ----
if (!input_free()) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (__hit(__back_r())) { play_sound_ext(snd_matclick2, .8, .9, .5, 1); back_room(); exit; }
for (var _t = 0; _t < 4; _t++) if (__hit(__tab_r(_t))) { if (__open(_t)) { s.tab = _t; __layout(); play_sound_ext(snd_softclick, 1.0, 1.1, .4, 1); } else { play_sound_ext(snd_matclick2, .7, .8, .3, 0); note = (_t == 1) ? "aether opens when the well has a level" : "quintessence opens when the deep well has a level"; note_t = 3; } exit; }
// ---- the cinder tree ----
if (_l == 3) {
	var _pk = stk_perks();
	for (var _p = 0; _p < array_length(_pk); _p++) if (__hit(__perk_b(_p))) {
		var _c = stk_perk_cost(s, _pk[_p].key);
		if (_c < 0) { note = _pk[_p].name + " is at its top"; note_t = 2; play_sound_ext(snd_matclick2, .7, .8, .3, 0); }
		else if (stk_perk_buy(s, _pk[_p].key)) { play_sound_ext(snd_cointoss, 1.0, 1.2, .5, 0); note = _pk[_p].name + " rank " + string(stk_perk(s, _pk[_p].key)) + " - " + string(s.cinders) + " cinder" + ((s.cinders == 1) ? "" : "s") + " still held"; note_t = 4; __layout(); }
		else { note = "wants " + string(_c) + " cinders held (" + string(s.cinders) + " held)"; note_t = 3; play_sound_ext(snd_matclick2, .7, .8, .3, 0); }
		exit;
	}
	if (__hit(__turn_r())) {
		if (stk_turn(s)) { s = g.stk; __layout(); play_sound_ext(snd_cointoss, .9, 1.1, .6, 0); note = "THE TURN  -  " + string(s.cinders) + " cinder" + ((s.cinders == 1) ? "" : "s") + " held: every speed x" + string_format(1 + STK_CINDER_SPD * s.cinders, 1, 2); note_t = 6; }
		else { play_sound_ext(snd_matclick2, .7, .8, .3, 0); note = (stk_cap(s, 2) < 1) ? "the turn wants quintessence open" : "the turn wants a cinder to give - more levels"; note_t = 3; }
		exit;
	}
	exit;
}
// ---- a layer ----
if (_l == 0 && __hit(__buy_r())) {
	var _c = stk_cap_cost(s);
	if (s.spark >= _c) { s.spark -= _c; s.cap_lv += 1; flash = 1; save_mark_dirty(); play_sound_ext(snd_softclick, 1.05, 1.2, .5, 1); note = "energy cap " + string(stk_cap(s, 0)); note_t = 3; }
	else { play_sound_ext(snd_matclick2, .7, .8, .3, 0); note = "not enough spark"; note_t = 2; }
	exit;
}
if (__hit(__burn_r())) {
	var _ly = s.layers[_l];
	if (_ly.burn_t > 0) { note = "burning: " + __mmss(_ly.burn_t) + " left"; note_t = 2; play_sound_ext(snd_matclick2, .7, .8, .3, 0); }
	else if (stk_burn(s, _l)) { flash = 1; play_sound_ext(snd_cointoss, 1.1, 1.3, .5, 0); note = "BURN: +" + string(_ly.burn_add) + " " + stk_names()[_l].name + " for " + __mmss(_ly.burn_t) + " - the overflow drains back after"; note_t = 4; }
	else { note = (stk_cap(s, _l) < 1) ? "nothing to burn yet" : ("a burn wants " + stk_num(stk_burn_cost(s)) + " spark"); note_t = 2; play_sound_ext(snd_matclick2, .7, .8, .3, 0); }
	exit;
}
var _sk = s.layers[_l].sinks;
for (var _i = 0; _i < rows_n; _i++) {
	if (__hit(__name_r(_i))) { s.layers[_l].focus = (s.layers[_l].focus == _i) ? -1 : _i; save_mark_dirty(); play_sound_ext(snd_softclick, 1.1, 1.2, .4, 1); note = (s.layers[_l].focus == _i) ? ("focus: " + stk_config()[_l][_i].name + " at x" + string_format(stk_focus_on(s), 1, 2) + ", the rest at x" + string(STK_FOCUS_OFF)) : "the focus lifted"; note_t = 3; exit; }
	if (__hit(__btn(_i, bx_minus, 13))) { stk_alloc(s, _l, _i, -1); rep_l = _l; rep_i = _i; rep_dir = -1; rep_t = 22; exit; }
	if (__hit(__btn(_i, bx_plus, 13)))  { stk_alloc(s, _l, _i, 1);  rep_l = _l; rep_i = _i; rep_dir = 1;  rep_t = 22; exit; }
	if (__hit(__btn(_i, bx_max, 30)))   { stk_alloc(s, _l, _i, 1000000); play_sound_ext(snd_softclick, 1.0, 1.1, .3, 1); exit; }
	if (__hit(__btn(_i, bx_clear, 18))) { stk_alloc(s, _l, _i, -1000000); play_sound_ext(snd_softclick, .9, 1.0, .3, 1); exit; }
}
if (__hit(__even_r()))  { stk_preset(s, _l, "even");  play_sound_ext(snd_softclick, 1.0, 1.1, .4, 1); exit; }
if (__hit(__chase_r())) { stk_preset(s, _l, "chase"); play_sound_ext(snd_softclick, 1.0, 1.1, .4, 1); exit; }
if (__hit(__clear_r())) { stk_preset(s, _l, "clear"); play_sound_ext(snd_softclick, .9, 1.0, .4, 1); exit; }
if (__hit(__turn_r())) {
	if (stk_turn(s)) { s = g.stk; __layout(); play_sound_ext(snd_cointoss, .9, 1.1, .6, 0); note = "THE TURN  -  " + string(s.cinders) + " cinder" + ((s.cinders == 1) ? "" : "s") + " held: every speed x" + string_format(1 + STK_CINDER_SPD * s.cinders, 1, 2) + " - the veins moved"; note_t = 6; }
	else { play_sound_ext(snd_matclick2, .7, .8, .3, 0); note = (stk_cap(s, 2) < 1) ? "the turn wants quintessence open" : "the turn wants a cinder to give - more levels"; note_t = 3; }
	exit;
}
