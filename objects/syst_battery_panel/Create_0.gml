/// syst_battery_panel - THE BATTERY, as a panel over whatever room you
/// are standing in (his design, 2026-09-11 - read battery_init for the
/// laws). The offline budget's face: the charge, how long it lasts at
/// the offline rates, the three rate sliders, the two credit ladders,
/// and THE CRANK - a wheel you spin to fast-charge it (his ask: "a
/// crank fidget in the battery room"). On the overlay contract the
/// time bank and automation panels share: battery_open is the one
/// door, the burger's X and escape close it (battery_close), ui_overlay
/// lists it, ui_blur_tick softens the room behind.
///
/// Draw-only plus region hits, both off the geometry declared here.

battery_init();
depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by battery_close; the Step destroys at zero

hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar

// ---- layout (region law: Step's hits and Draw share these) ----
// the left column: the charge, the rates, the upgrades. the right: the crank
col_x   = 14;
col_w   = 292;
bat_y   = hh + 30;     // the charge meter
bat_w   = 220;
bat_h   = 22;
rate_y  = hh + 96;     // the three offline rate rows
rate_p  = 18;
trk_x   = col_x + 92;
trk_w   = 120;
upg_y   = hh + 160;    // the two upgrade rows
upg_p   = 22;
btn_w   = 62;

rates   = ["run", "fab", "merge"];
rate_lbl = ["dials cycling", "fabricator", "auto merge"];
rate_col = [c_sgreen, c_seagreen, c_seagreen];

// ---- THE CRANK ----
// A wheel with a handle. Grab the handle (or anywhere on the wheel)
// and drag it round: every degree swept in either direction is charge
// - a full revolution is a sixtieth of the capacity (BAT_CRANK_REV),
// so a hard thirty seconds of cranking fills it from empty. Let go
// and it keeps spinning on its momentum, still charging, winding down
// on friction - the one bit of physics that makes a crank feel like a
// crank rather than a dial. A ratchet click every 45 degrees.
crank_cx = 396;
crank_cy = hh + 118;
crank_r  = 34;
ang      = 0;       // the handle's angle
vel      = 0;       // degrees per frame, free-spinning
held     = false;
grab_a   = 0;       // pointer angle at the last frame while held
ratchet  = 0;       // degrees since the last click
crank_glow = 0;     // eased, lights the wheel while it turns

// the quote cache for the two ladders (a slow tick, the Draw reads it)
qtic   = 0;
q_cap  = { ok : false, cost : 0, lv : 0 };
q_rate = { ok : false, cost : 0, lv : 0 };

// the drag in progress on a rate track
drag_row = -1;

/// @func __part(i)
__part = function(_i) {
	var _e = ui_anim_in(oa, _i);
	if (_e < .001) return 0;
	var _o = (1 - _e) * UI_IN_DEAL;
	if (_o != 0) matrix_set(matrix_world, matrix_build(0, _o, 0, 0, 0, 0, 1, 1, 1));
	ui_fade_set(_e);
	return _e;
};
__part_end = function() {
	ui_fade_set(1);
	matrix_set(matrix_world, matrix_build_identity());
};

__trk_r = function(_i) { return { x : trk_x, y : rate_y + _i * rate_p + 4, w : trk_w, h : 5 }; };
__btn_r = function(_i) { return { x : col_x + col_w - btn_w, y : upg_y + _i * upg_p, w : btn_w, h : 14 }; };

/// charge from a sweep of the crank, in degrees
__crank_add = function(_deg) {
	var _b = g.battery;
	var _cap = battery_cap();
	_b.charge = min(_cap, _b.charge + abs(_deg) / 360 * _cap / BAT_CRANK_REV);
	ratchet += abs(_deg);
	if (ratchet >= 45) {
		ratchet -= 45;
		play_sound_ext(snd_softclick, 1.3 + random(.3), 1.6, .25, 0);
	}
};
