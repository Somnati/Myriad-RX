// THE SIM, a frame at a time (delta = the frame in sixtieths)
delta_tick(d, delta / 60, true);
if (note_t > 0) note_t -= delta / 60;
if (tut && d.life >= 1) tut = false;
// THE GROUND SHEET: the grid into the buffer, the buffer onto the surface (buffer_set_surface, the house lesson) - fifteen
// times a second (two thousand cells of colour maths is a frame's worth in the vm)
sheet_t += delta;
if (sheet_t >= 4 || !surface_exists(gsurf)) {
	sheet_t = 0;
	var _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3], _n = d.w * d.h;
	for (var _i = 0; _i < _n; _i++) {
		var _c = __cell_col(_i), _o = _i * 4;
		buffer_poke(gbuf, _o + _or, buffer_u8, colour_get_red(_c)); buffer_poke(gbuf, _o + _og, buffer_u8, colour_get_green(_c)); buffer_poke(gbuf, _o + _ob, buffer_u8, colour_get_blue(_c)); buffer_poke(gbuf, _o + _oa, buffer_u8, 255);
	}
	if (!surface_exists(gsurf)) gsurf = surface_create(d.w, d.h);
	buffer_set_surface(gbuf, gsurf, 0);
}
// ---- input (region pattern, arbitrated) ----
hover = __cell_at(mouse_x, mouse_y);
if (!input_free()) exit;
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (__hit(__back_r())) { play_sound_ext(snd_matclick2, .8, .9, .5, 1); back_room(); exit; }
// the panel's rows: an upgrade buys, a tool arms (again disarms)
for (var _i = 0; _i < array_length(rows); _i++) {
	if (!__hit(__row_r(_i))) continue;
	var _k = rows[_i].k;
	if (_k == "levee" || _k == "channel") { tool = (tool == _k) ? "" : _k; play_sound_ext(snd_softclick, 1.0, 1.1, .4, 1); note = (tool == "") ? "the hand" : ("tap the ground to lay a " + tool + "  -  " + string(delta_cost(d, tool)) + " grain each"); note_t = 4; exit; }
	if (delta_buy(d, _k)) { play_sound_ext(snd_softclick, 1.05, 1.2, .5, 1); note = "bought: " + rows[_i].lbl; note_t = 3; if (_k == "valley") { d = g.alluv; tut = false; sheet_t = 99; note = "valley " + string(d.valley) + "  -  a new land, the river at its head"; note_t = 6; } }
	else { play_sound_ext(snd_matclick2, .7, .8, .3, 0); note = "not enough grain"; note_t = 2; }
	exit;
}
// the ground: a tool lays its mark; the hand reads the cell
if (hover >= 0) {
	if (tool != "") {
		if (delta_buy(d, tool, hover mod d.w, hover div d.w)) { play_sound_ext(snd_tap_click2, .9, 1.1, .4, 0); note = tool + " laid  -  the next " + string(delta_cost(d, tool)); note_t = 3; }
		else { play_sound_ext(snd_matclick2, .7, .8, .3, 0); note = (d.hgt[hover] < d.sea && tool == "channel") ? "nothing to dig under the sea" : "not enough grain"; note_t = 2; }
	} else {
		var _hv = d.hgt[hover];
		if (_hv < d.sea) note = d.sea0[hover] ? "the sea  -  " + string(round((d.sea - _hv) * 100)) + " deep; every droplet that reaches it lays mud here" : "the sea";
		else note = ((d.sea0[hover]) ? "the delta  -  " : "land  -  ") + "height " + string(round(_hv * 100)) + ", silt " + string(round(d.silt[hover] * 100)) + ", wet " + string(round(d.wet[hover] * 100)) + ((d.crop[hover] > 0) ? (", the crop " + string(round(d.crop[hover] * 100)) + "% ripe") : "") + ((d.lev[hover] == 1) ? "  (a levee)" : ((d.lev[hover] == 2) ? "  (a channel)" : ""));
		note_t = 4;
	}
}
