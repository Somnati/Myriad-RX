/// @description framework (DE's Step, line for line)
if (!variable_global_exists("game_started") || !g.game_started) exit;
rebirth_init();

// set income (DE: the displayed gold, or the cycle income by its networth
// setting; RX: the profit pile)
var _v = (variable_global_exists("profit") && g.profit >= arb(1)) ? g.profit : 0;
income_track = trickle(income_track, _v, 7);
deci = clamp_min((((frac(income_track) * 10) - 1) / 9), 0);
income = floor(income_track) + deci;
// set scales
scale_min = clamp_min(income - scale_min_os, 0);
scale_max = income + scale_max_os;
// set percentage
perc = (income - scale_min) / (scale_max - scale_min);
// adjust scale
income_track_scale_max = trickle(income_track_scale_max, 120, 200);
income_track_scale_min = trickle(income_track_scale_min, 120, 200);
scale_max_os = trickle(scale_max_os, scale_max_os_des, income_track_scale_max);
scale_min_os = trickle(scale_min_os, scale_min_os_des, income_track_scale_min);
// pre milestone approach
scale_max_os_des = 4;
scale_min_os_des = 2;
// milestones approach
if (income_track + 6 >= maxxp)
if (income_track < maxxp) {
	scale_max_os_des = clamp_min(6 - ((income_track + 5) - maxxp), 4);
	scale_min_os_des = clamp(1 + ((income_track + 1) - maxxp), 1, 2);
}
// milestone stats
lv = ceil(clamp_min((income_track - bb) / ii, 0));
prevxp = (bb + (ii * (lv - 1))) * clamp(lv, 0, 1);
maxxp = bb + (ii * lv);
__colors();
// highest
tic -= delta;
if (lv > g.rebirth.hi_ms) {
	g.rebirth.hi_ms = lv;
	if (tic <= 0) {
		play_sound_ext(snd_milestone, .8, 1.2, .5, 2);
		assign_banner("rebirth milestone achieved", cprev, c_black);
		assign_banner("reach a profit of " + crunch_arb(maxxp + .1), c_white, c_black);
	}
	tic = tic_;
	save_mark_dirty();
}

/// position
open = true;
desy = (room_height - sprite_height) - 10;
var _ovl = ui_overlay();
var _rb  = instance_exists(syst_rebirth) && syst_rebirth.open;
if (in_room(rm_clicker)) {
	if (_ovl != noone && !_rb) desy = room_height + 10;   // DE: syst_rm_modules
}
if (!unfold_has("scale")) { open = false; y = room_height + 20; }
if (!in_room(rm_clicker)) {
	if (!_rb) desy = room_height + 20;
}
if (instance_exists(obj_ui_menu2) && obj_ui_menu2.open) open = false;   // DE: obj_button_mainoptions.open
if (!open) y = trickle(y, room_height + 20, 7);
if (open)  y = trickle(y, desy, 7);
// unlock (DE flipped uf_rebirthmilestone here when income_track + 8 >=
// maxxp at lv 0; RX's unfold row does the same test and this instance
// sees the flip - DE's opening window, verbatim: three hundred orders
// wide, trickling shut over the next seconds)
if (!seen && unfold_has("scale")) {
	seen = true;
	if (lv == 0) {
		scale_max_os = (310 - income_track);
		scale_max = scale_max_os;
		scale_min = 0;
		scale_min_os = -(300 - income_track);
		income_track_scale_max = 100000 / 2;
		income_track_scale_min = 100000 / 2.5;
	}
}
// depth
depth = 10;   // over the visualizer's fx layers (see the Create)
if (_rb) depth = syst_rebirth.depth - 1;
