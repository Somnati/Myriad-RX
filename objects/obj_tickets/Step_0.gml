if (!variable_global_exists("game_started") || !g.game_started) exit;
ticket_init();
t += delta / 60;
var _pile = g.tickets.pile;
var _n = array_length(_pile);

// ---- is there a desk to be on ----
var _show = unfold_has("tickets") && in_room(rm_clicker)
	&& !(instance_exists(obj_ui_menu2) && obj_ui_menu2.open)
	&& (ui_overlay() == noone)
	&& !(instance_exists(syst_unfold) && syst_unfold.veil > .5);
if (!_show && open) __close();
if (open && (cur == undefined || _n == 0 || _pile[0] != cur)) __close();

// ---- the mask is the live rect ----
oa = trickle(oa, open ? 1 : 0, 6);
// put back and home: let go of the ticket (its scratch stays on the struct)
if (!open && oa <= .05 && cur != undefined) { cur = undefined; roll = undefined; }
var _r = __card();
if (open || oa > .05) {
	x = _r.x; y = _r.y; image_xscale = _r.w; image_yscale = _r.h;
} else if (_show && _n > 0) {
	var _p = __pile();
	x = _p.x - 1; y = _p.y - 5; image_xscale = PW + 6 + 16; image_yscale = PH + 7;
} else {
	x = -1000; y = -1000; image_xscale = 1; image_yscale = 1;
}
hot = input_free() && mouse_over();
depth = (open || oa > .05) ? -30 : 10;

// ---- closed: tap the pile ----
if (!open) {
	if (_show && _n > 0 && hot && mouse_check_button_pressed(mb_left)) __open();
}
// ---- open: scratch ----
else {
	var _xr = __xrect(_r);
	var _on_x = point_in_rectangle(mouse_x, mouse_y, _xr.x, _xr.y, _xr.x + _xr.w, _xr.y + _xr.h);
	if (mouse_check_button_pressed(mb_left) && hot) {
		if (_on_x) { __close(); play_sound_ext(snd_matclick2, .7, .8, .5, 1); }
		else if (!done) { held = true; lmx = mouse_x; lmy = mouse_y; }
	}
	if (keyboard_check_pressed(vk_escape)) __close();
	if (!mouse_check_button(mb_left)) held = false;
	if (open && held && peel < 0 && oa > .95) {
		var _k = __scratch(lmx, lmy, mouse_x, mouse_y);
		snd_t -= delta;
		if (_k > 0 && snd_t <= 0) {
			play_sound_ext(snd_scratch, .85, 1.2, .45, 1);   // a coin on foil (his call: the synth rasp went)
			snd_t = 5;
		}
	}
	lmx = mouse_x; lmy = mouse_y;
	// the self-peel: at 85% the rest goes in a sweep, left to right
	if (open && peel < 0 && cur.cleared >= GN * GN * .85) peel = 0;
	if (open && peel >= 0 && peel < 1) {
		peel = min(1, peel + delta / 16);
		var _g = __grid(_r);
		var _to = floor(peel * GN);
		for (var _c = 0; _c <= _to && _c < GN; _c++)
			for (var _rr = 0; _rr < GN; _rr++) __clear(_c, _rr, _g.x, _g.y);
		if (peel >= 1) __reveal();
	}
	if (open && done) {
		done_t -= delta / 60;
		if (done_t <= 0) __finish();
	}
}

// ---- the flakes ----
for (var _i = array_length(flakes) - 1; _i >= 0; _i--) {
	var _f = flakes[_i];
	_f.x += _f.vx * delta; _f.y += _f.vy * delta;
	_f.vy += .12 * delta;
	_f.life -= delta / 26;
	if (_f.life <= 0) array_delete(flakes, _i, 1);
}
