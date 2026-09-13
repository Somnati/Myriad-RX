objective_init();
var _ob = g.obj;

// ---- a completion: celebrate the objective the card is showing ----
if (_ob.just != "") {
	if (_ob.just == okey || okey == "") { okey = _ob.just; cel = 2; }
	_ob.just = "";
}
// (the celebration runs only while the card is up - a completion inside
// a panel is celebrated when the panel closes)
if (cel > 0 && a > .5) cel = max(0, cel - delta / 60);

// ---- where the card may be ----
// under the menu drawer it stays in landscape (the drawer is the right
// 148px, the card the left 172 - and "open the menu" is a step worth
// seeing tick); portrait's drawer is the whole room, so there it hides.
// The open dial drawer is the whole width in portrait too
var _land = (room_width > 300);
var _live = variable_global_exists("game_started") && g.game_started
	&& in_room(rm_clicker) && unfold_has("tap") && !instance_exists(syst_unfold)
	&& (_land || !instance_exists(syst_menu2)) && ui_overlay() == noone
	&& !(!_land && instance_exists(syst_dials) && syst_dials.stage > 0);
var _cur  = objective_cur();
var _gap  = (_ob.gap > 0);   // THE BREATH: after the celebration the card goes away until it ends
var _want = _live && ((cel > 0) || (!_gap && !is_undefined(_cur)));
a = move_to(a, _want ? 1 : 0, 6);
if (a < .004) a = 0;

// ---- the objective shown: swap once the celebration and the breath are over ----
var _k = is_undefined(_cur) ? "" : _cur.key;
if (cel <= 0 && !_gap && _k != okey) {
	okey = _k;
	slide = 0;                 // it arrives from the left, whether the card was up or not
	se = []; sf = []; sr = []; st = [];
}
slide = min(1, slide + delta / 16);

// THE ANNOUNCEMENT (his sound, 2026-09-13: "GUI notification 11 for when
// a new objective batch pops up") - once per objective, the moment the
// card starts to show it
if (okey != "" && heard != okey && a > .05 && _want) {
	heard = okey;
	play_sound_ext(snd_obj_new, 1, 1, .6, 1);
}

// ---- per-step eases: a tick fills its box (his "future sound") and
// flashes; a step that STOPS holding empties it and flashes red (his
// ask: "if an objective falls off i want it to flash red and fade") ----
var _o = objective_by_key(okey);
if (!is_undefined(_o)) {
	var _n = array_length(_o.steps);
	for (var _i = 0; _i < _n; _i++) {
		var _d = objective_step_done(_o, _i);
		// first sight of a step: seated as it is, no sound, no flash
		if (_i >= array_length(se)) { se[_i] = _d ? 1 : 0; sf[_i] = 0; sr[_i] = 0; st[_i] = _d; continue; }
		if (_d && !st[_i]) { sf[_i] = 1; play_sound_ext(snd_obj_step, 1, 1, .55, 1); }
		if (!_d && st[_i]) sr[_i] = 1;
		st[_i] = _d;
		se[_i] = _d ? min(1, se[_i] + delta / 8) : max(0, se[_i] - delta / 8);
		// the flashes fade only while the card can be seen
		if (a > .5) { sf[_i] = max(0, sf[_i] - delta / 30); sr[_i] = max(0, sr[_i] - delta / 50); }
	}
}

// ---- a tap on the card: the detailed list ----
if (a < .9 || okey == "") exit;
if (!input_free(ui_layer_overlay)) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (!__consumes(mouse_x, mouse_y)) exit;
play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
objectives_open();
