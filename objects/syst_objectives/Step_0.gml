objective_init();
var _ob = g.obj;

// ---- a completion: celebrate the objective the card is showing ----
if (_ob.just != "") {
	if (_ob.just == okey || okey == "") {
		okey = _ob.just; cel = 2; open_t = 0;
		play_sound_ext(snd_obj_done, 1, 1, .6, 1);   // the whole objective complete (his sound: Success4, 2026-09-13)
	}
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
// the glass capture slot, remade per room (see the Create)
if (!instance_exists(snap_px)) {
	snap_px = create_obj(0, 0, obj_draw_proxy);
	snap_px.owner = id;
	snap_px.depth = depth + 1;
	snap_px.fn    = __snap_cap;
}
// ⚖️ IN EVERY ROOM AND OVER EVERY PANEL (his ask, 2026-09-13: "the
// objectives disappear when i head to the ability room even though one
// of the objectives tells me to... i want the objective UI to still show
// in any room"). It used to live in the money room only and yield to
// every overlay but the tiles; now only the title, the new-game flow and
// the veil hide it. Portrait still yields to the drawer and the dial
// column (there the card and they are the same width)
var _live = variable_global_exists("game_started") && g.game_started
	&& !in_room(rm_titlescreen) && !in_room(rm_newgame) && !in_room(rm_quit)
	// ...nor the benches whose own rails live where the card sits (the saves
	// screen's profile rail is the card's exact corner - 2026-09-14 bug hunt)
	&& !in_room(rm_saves) && !in_room(rm_gamepad) && !in_room(rm_services) && !in_room(rm_numfmt)
	&& unfold_has("tap") && !instance_exists(syst_unfold)
	// ...nor over the statistics (his call, 2026-09-17: nothing completes in there)
	&& !instance_exists(syst_statistics_v2)
	&& (_land || !instance_exists(syst_menu2))
	&& !(!_land && instance_exists(syst_dials) && syst_dials.stage > 0);
// the clear-room clock: runs only while nothing covers the card; anything
// that does puts it back to OBJ_CARD_DELAY
if (_live) clear_t = max(0, clear_t - delta / 60); else clear_t = OBJ_CARD_DELAY;
var _cur  = objective_cur();
var _gap  = (_ob.gap > 0);   // THE BREATH: after the celebration the card goes away until it ends
var _want = _live && clear_t <= 0 && ((cel > 0) || (!_gap && !is_undefined(_cur)));
a = move_to(a, _want ? 1 : 0, 6);
if (a < .004) a = 0;

// ---- the objective shown: swap once the celebration and the breath are over ----
var _k = is_undefined(_cur) ? "" : _cur.key;
if (cel <= 0 && !_gap && _k != okey) {
	okey = _k;
	slide = 0;                 // it arrives from the left, whether the card was up or not
	se = []; sf = []; sr = []; st = [];
	// a new objective opens the card AND KEEPS IT OPEN until it is tapped
	// (his ask, 2026-09-14: "a player needs to see what's next - they
	// might not know to click on the thing to open it")
	open_t = 0; pin = true;
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
		if (_d && !st[_i]) { sf[_i] = 1; open_t = 0; play_sound_ext(snd_obj_step, 1, 1, .55, 1); }
		if (!_d && st[_i]) { sr[_i] = 1; open_t = 0; }
		st[_i] = _d;
		se[_i] = _d ? min(1, se[_i] + delta / 8) : max(0, se[_i] - delta / 8);
		// the flashes fade only while the card can be seen
		if (a > .5) { sf[_i] = max(0, sf[_i] - delta / 30); sr[_i] = max(0, sr[_i] - delta / 50); }
	}
}

// ---- THE COLLAPSE: open for a while, then only the boxes ----
// the pointer on it (its rect NOW, folded or not)
var _r = __rect();
hov = (a > .5 && okey != "" && _live && input_free(ui_layer_overlay)
	&& point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h));
peek = move_to(peek, (hov && op < .5) ? 1 : 0, 5);
// the open clock runs only while the card is seen and not held open
if (a > .5 && !pin && !hov && cel <= 0) open_t += delta / 60;
// ...and OPEN while the menu is out (his ask: expand with the header,
// fold when it closes)
var _menu = instance_exists(obj_ui_menu2) && obj_ui_menu2.open;
if (menu_was && !_menu && !pin) open_t = OBJ_CARD_HOLD;   // the menu closing folds it (unless pinned by hand)
menu_was = _menu;
var _open = pin || cel > 0 || (open_t < OBJ_CARD_HOLD) || _menu;
op = move_to(op, _open ? 1 : 0, 6);

// ---- a click: pin it open, or fold it ----
if (a < .9 || okey == "") exit;
if (!input_free(ui_layer_overlay)) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (!__consumes(mouse_x, mouse_y)) exit;
if (op < .5) {
	// folded: open, and stay open until clicked again
	pin = true; open_t = 0;
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
} else {
	// open (pinned or on the clock): fold it now
	pin = false; open_t = OBJ_CARD_HOLD;
	play_sound_ext(snd_softclick, .9, 1, .4, 1);
}
