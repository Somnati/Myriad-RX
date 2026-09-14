// no header, no menu (a title-mode header slides away and goes; this goes with it)
if (!instance_exists(obj_ui_header)) { instance_destroy(); exit; }
// the menu doesn't exist until a run has started (his rule: no header
// menu before continue/new game) - the title screen stays clean. BEFORE
// A RUN the corner X still works while a panel is up (his report,
// 2026-09-13: settings on the title could not be closed); the bar tap
// and the hint stay off
var _pre = !(variable_global_exists("game_started") && g.game_started) || in_room(rm_titlescreen);
tic -= delta;
// the header slides on the title: the X rides it
var _oy = obj_ui_header.y;
// ⚖️ DE'S PATH (his call, 2026-09-13, after the tiles could not reach the
// menu): THE HEADER IS THE MENU BUTTON. A tap anywhere on the bar opens
// the drawer - over a panel too - and a tap on it with the drawer out
// folds it. The corner where the burger lived is the X now, for
// whatever is up: the drawer, or a panel. Nothing draws there while
// there is nothing to close (DE's clean header), and the bar TEACHES
// the gesture the way DE's did - "tap up here to open the menu",
// centred on it, fading with the run's magnitude (the Draw).
var _ovl = (ui_overlay() != noone);
var _any = open || _ovl;                        // something to close
ba = move_to(ba, _any ? 1 : 0, 4);              // the X is present only while something is up
rip = max(0, rip - .06 * delta);
hot = _any && point_in_rectangle(mousex, mousey, room_width - 26, 12 + _oy, room_width - 2, 32 + _oy);
// the bar: everything of it left of the corner (the window buttons and
// the X own the corner - and they are clickables, so the owner check
// below already keeps a press on them off the bar)
var _bh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
hot_bar = point_in_rectangle(mousex, mousey, 0, 0, room_width - 30, _bh);

var _free = input_free(ui_layer_menu) && (!variable_global_exists("click_owner") || g.click_owner == noone);

// ---- the corner X: closes the drawer, or the panel ----
if (_free && mouse_check_button_pressed(mb_left) && hot && tic <= 0) {
	tic = 8; rip = 1;
	if (open) open = false;
	else if (_ovl) ui_overlay_close();
	play_sound_ext(snd_matclick2, .7, .8, .5, 1);
}
// ---- the bar: the menu, open or shut (never before a run) ----
else if (!_pre && _free && mouse_check_button_pressed(mb_left) && hot_bar && tic <= 0) {
	tic = 8;
	open = !open;
	if (open) {
		if (!instance_exists(syst_menu2)) create_obj(0, 0, syst_menu2);
		play_sound_ext(snd_matclick2, 1, 1.1, .5, 1);
	}
	else play_sound_ext(snd_matclick2, .7, .8, .5, 1);
}

// escape closes (pc nicety; it never OPENS, so room escape uses stay safe)
if (open && keyboard_check_pressed(vk_escape)) {
	open = false;
	rip = 1;
	play_sound_ext(snd_matclick2, .7, .8, .5, 1);
}

// ---- THE HINT (DE's obj_button_mainoptions): shows once the run has
// earned 95 (DE's number) and the veil is gone; .6 fading with the
// magnitude of everything earned - gone by 1e100 (DE's law, term for
// term: .6 x (1 - exponent / 100)); full while the drawer is out, when
// it reads "tap here to close it" ----
var _want = 0;
if (!_pre && unfold_has("tap") && variable_global_exists("total_profit") && g.total_profit >= arb(95) && !_ovl) {
	var _lg = (g.total_profit >= arb(1)) ? arb_log10(g.total_profit) : 0;
	_want = open ? 1 : max(0, .6 * (1 - _lg / 100));
}
ha = move_to(ha, _want, 10);
