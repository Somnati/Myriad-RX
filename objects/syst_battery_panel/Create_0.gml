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
// ⚖️ THE DIAL (his inspiration, 2026-09-11: a phone's charging screen -
// one big ring with the percentage inside and the charge as a LIQUID
// at the bottom). The disc sits in the middle; the crank's handle
// rides its rim - the whole ring IS the crank, grab anywhere on the
// disc and turn. The rates and the two ladders keep to the sides in
// landscape and stack below in portrait (the money room is both).
land    = (room_width > 300);
disc_cx = room_width * .5;
disc_r  = land ? 38 : 32;     // (54 was "ugly" - his word; a dial, not a moon)
disc_cy = land ? (hh + 22 + disc_r) : (hh + 12 + disc_r);
crank_cx = disc_cx;   // the crank's centre and radius ARE the disc's
crank_cy = disc_cy;
crank_r  = disc_r;
// the two readouts under the disc: "full in" left, "lasts" right
read_y  = disc_cy + disc_r + 14;
// the offline rate rows
rate_p  = land ? 18 : 14;
rate_y  = land ? (hh + 48) : (read_y + 30);
rate_x  = land ? 14 : 8;
trk_x   = land ? (rate_x + 64) : (rate_x + 40);
trk_w   = land ? 78 : 60;
// the two ladders
upg_p   = land ? 22 : 18;
upg_y   = land ? (hh + 48) : (rate_y + 3 * rate_p + 8);
upg_x   = land ? (room_width - 14 - 150) : 8;
upg_w   = land ? 150 : (room_width - 16);
btn_w   = land ? 54 : 44;

rates   = ["run", "fab", "merge"];
rate_lbl = land ? ["dials cycling", "fabricator", "auto merge"] : ["dials", "fab", "merge"];
rate_col = [c_sgreen, c_seagreen, c_seagreen];

// ---- THE CRANK ----
// A wheel with a handle. Grab the handle (or anywhere on the wheel)
// and drag it round: every degree swept in either direction is charge
// - a full revolution is a sixtieth of the capacity (BAT_CRANK_REV),
// so a hard thirty seconds of cranking fills it from empty. Let go
// and it coasts on its momentum like the techdemo's heavy knob (his
// ask, 2026-09-11), still charging, and the detent spring reels it
// into the nearest of eight notches as it dies; the clicks ride the
// speed. The knob flashes white on each.
// (the crank's centre and radius are the disc's - set with the layout
// above. Three stale lines here put the grab at the OLD spot, top
// right, while the dial drew in the middle: "the crank don't work")
ang      = 0;       // the handle's angle
vel      = 0;       // degrees per frame, free-spinning
held     = false;
grab_a   = 0;       // pointer angle at the last frame while held
crank_turn = 0;     // the unbounded sweep, for the detent clicks
crank_cell = 0;     // the last notch crossed
crank_flash = 0;    // frames the knob flashes white after a click
crank_glow = 0;     // eased, lights the wheel while it turns
liq_t = random(1000);   // the liquid's own clock (the waves)
liq_lvl = -1;           // the eased fill line, so a crank's charge rises rather than jumps

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
__btn_r = function(_i) { return { x : upg_x + upg_w - btn_w, y : upg_y + _i * upg_p, w : btn_w, h : 14 }; };

/// charge from a sweep of the crank, in degrees
__crank_add = function(_deg) {
	var _b = g.battery;
	var _cap = battery_cap();
	_b.charge = min(_cap, _b.charge + abs(_deg) / 360 * _cap / BAT_CRANK_REV);
	crank_turn += _deg;   // the Step's detent clicks read this
};
