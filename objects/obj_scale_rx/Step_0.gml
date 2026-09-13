if (!variable_global_exists("game_started") || !g.game_started) exit;
rebirth_init();
t += delta / 60;

// ---- the pile, as a continuous magnitude (DE's deci) ----
var _v = (variable_global_exists("profit") && g.profit >= arb(1)) ? g.profit : 0;
track = trickle(track, _v, 7);
income = floor(track) + clamp_min((((frac(track) * 10) - 1) / 9), 0);

// ---- the milestone ----
lv = ceil(clamp_min((income - bb) / ii, 0));
prevxp = (lv > 0) ? bb + ii * (lv - 1) : 0;
maxxp  = bb + ii * lv;
__colors();
var _d = maxxp - income;   // orders to go

// ---- the window: 3 behind / 9 ahead, tightening on the approach so the
// milestone tick rides two orders inside the right edge and the fill
// visibly accelerates toward it (DE's rule, widened) ----
var _mx_des = 9, _mn_des = 3;
if (_d < 9) { _mx_des = max(_d + 2, 5); _mn_des = clamp(1 + _d / 3, 1, 3); }
mx = trickle(mx, _mx_des, 90);
mn = trickle(mn, _mn_des, 90);
lo = clamp_min(income - mn, 0);
hi = income + mx;
perc = clamp((income - lo) / max(.0001, hi - lo), 0, 1);
ppo = W / max(.0001, hi - lo);

// ---- the rate, and the eta on the milestone ----
hist_t += delta / 60;
if (hist_t >= 1) {
	hist_t -= 1;
	array_push(hist, income);
	if (array_length(hist) > 61) array_delete(hist, 0, array_length(hist) - 61);
}
var _n = array_length(hist);
rate = (_n >= 5) ? (income - hist[0]) / (_n - 1) : 0;   // orders per second
eta  = (rate > .0000001 && _d > 0) ? _d / rate : -1;
if (eta > 86400 * 30) eta = -1;                          // a month out is "not soon"

// ---- the rebirth readout, on the second ----
units_tic -= delta;
if (units_tic <= 0) {
	units_tic = 60;
	var _r = rebirth_calc();
	units_txt = _r.can ? ("rebirth +" + crunch_arb(_r.units)) : "";
}

// ---- crossing ----
tic -= delta;
cel = max(0, cel - delta / 120);
if (lv > g.rebirth.hi_ms) {
	g.rebirth.hi_ms = lv;
	if (tic <= 0) {
		play_sound_ext(snd_milestone, .8, 1.2, .5, 2);
		assign_banner("rebirth milestone achieved", cprev, c_black);
		cel = 1;
	}
	tic = 300;
	save_mark_dirty();
}

// ---- the reveal: the window opens wide and zooms in ----
if (!seen && unfold_has("scale")) {
	seen = true;
	mx = 40; mn = 12;
}

// ---- the seat ----
open = unfold_has("scale") && in_room(rm_clicker);
var _ovl = ui_overlay();
var _rb  = instance_exists(syst_rebirth) && syst_rebirth.open;
if (_ovl != noone && !_rb) open = false;
if (instance_exists(obj_ui_menu2) && obj_ui_menu2.open) open = false;
seat = room_height - 15 - ((SCALE_COMPARE && instance_exists(obj_scale_de)) ? 30 : 0);
by = trickle(by, open ? seat : room_height + 20, 7);
depth = _rb ? syst_rebirth.depth - 1 : 40;
