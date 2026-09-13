objective_init();
var _ob = g.obj;

// ---- a completion: celebrate the objective the card is showing ----
if (_ob.just != "") {
	if (_ob.just == okey || okey == "") { okey = _ob.just; cel = 1.7; }
	_ob.just = "";
}
if (cel > 0 && a > .5) cel = max(0, cel - delta / 60);   // it runs only while the card is up - a completion inside a panel is celebrated when the panel closes

// ---- where the card may be ----
var _live = variable_global_exists("game_started") && g.game_started
	&& in_room(rm_clicker) && unfold_has("tap") && !instance_exists(syst_unfold)
	&& !instance_exists(syst_menu2) && ui_overlay() == noone
	// portrait: the open drawer is the whole width and its top rows
	// would sit under the card - the card yields until it closes
	&& !(room_width <= 300 && instance_exists(syst_dials) && syst_dials.stage > 0);
var _cur  = objective_cur();
var _want = _live && (!is_undefined(_cur) || cel > 0);
a = move_to(a, _want ? 1 : 0, 6);
if (a < .004) a = 0;

// ---- the objective shown: swap once the celebration is over ----
var _k = is_undefined(_cur) ? "" : _cur.key;
if (cel <= 0 && _k != okey) {
	okey = _k;
	slide = (a > .5) ? 0 : 1;   // arrive from the left if the card is up; else just be there
	se = []; sf = [];
}
slide = min(1, slide + delta / 16);

// ---- per-step eases: a tick fills its box over a few frames and flashes ----
var _o = objective_by_key(okey);
if (!is_undefined(_o)) {
	var _n = array_length(_o.steps);
	for (var _i = 0; _i < _n; _i++) {
		var _d = objective_step_done(_o, _i);
		if (_i >= array_length(se)) { se[_i] = _d ? 1 : 0; sf[_i] = 0; continue; }
		if (_d && se[_i] < 1) {
			if (se[_i] == 0) { sf[_i] = 1; play_sound_ext(snd_softclick, 1.15, 1.25, .35, 1); }
			se[_i] = min(1, se[_i] + delta / 8);
		}
		sf[_i] = max(0, sf[_i] - delta / 30);
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
