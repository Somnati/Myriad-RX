/// syst_timebank_panel - THE TIME BANK, as a panel over whatever room
/// you are standing in (his ask, 2026-09-10: "move the time bank out of
/// its own room and make it stand alone like settings and statistics.
/// no back button, use the menu X"). rm_timebank and syst_rm_timebank
/// are gone; this is that screen's face and hits, re-seated on the
/// overlay contract settings and statistics share:
///   - opened through timebank_open() (the one door), closed through
///     timebank_close() - which the burger's X and escape both call
///     via ui_overlay_close(); ui_overlay() lists it, so syst_input
///     holds the room quiet and ui_blur_tick softens it behind
///   - oa / closing: the open ease every overlay must carry. The
///     backdrop lands first, the strip slides in from under the header,
///     then the parts deal down in order (bank, speeds, burns, upgrades,
///     explainer) - ui_anim_in with an index each, ui_fade_set for the
///     alpha, the settings screen's recipe
/// The state is g.timebank; banking happens in offline_replay, spending
/// in timebank_spend on syst_production's heartbeat. This binds the
/// speed choice, the burns and the two upgrades and paints the numbers.
/// The house pattern: draw-only plus region hits, both off the same
/// geometry declared here.

timebank_init();
depth = -510;     // over the room and its drawers, under the menu (-520) and the header (-1000)

oa      = 0;      // the open ease, 0 closed .. 1 open (Step)
closing = false;  // armed by timebank_close; the Step destroys at zero

hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;   // flush under the bar

// ---- layout (region law: Step's hits and Draw share these) ----
cx      = room_width * .5;
bank_y  = 68;

// THE SPEED ROW. His set: off / x2 / x4 / x10 / x50. The gaps widen as
// they climb because the choice is about PACE, not power - every speed
// converts the bank one for one (timebank_twin's invariant 2), so what
// the ladder is really offering is "how long do you want this to last".
spd_y   = 116;
spd_w   = 44;
spd_gap = 5;
spds    = [1, 2, 4, 10, 50];
NSPD    = 5;
spd_x0  = cx - (NSPD * spd_w + (NSPD - 1) * spd_gap) * .5;

// THE BURN ROW (his ask): spend a lump at once and have it happen, the
// way an absence of that length would have. See timebank_burn.
burn_y  = 152;
burn_w  = 52;
burn_gap = 6;
burns   = [60, 600, 3600, 21600];
burn_lbl = ["1m", "10m", "1h", "6h"];
NBURN   = 4;
burn_x0 = cx - (NBURN * burn_w + (NBURN - 1) * burn_gap) * .5;

upg_y   = 182;
upg_h   = 24;
upg_x   = 70;
upg_w   = room_width - 140;

// THE QUOTE CACHE. timebank_upg walks a log-space series and packs an
// arb; doing that twice a frame for a number that changes when you buy
// something is waste, so it runs on a slow tick and the Draw reads the
// answer.
qtic   = 0;
q_cap  = { ok : false, cost : 0, maxed : false, txt : "" };
q_rate = { ok : false, cost : 0, maxed : false, txt : "" };

// the last burn, so the screen can say what it paid rather than leaving
// the player to spot a counter move
burn_msg = "";
burn_hp  = 0;

/// @func __part(i)
/// @desc Seat part i for the open animation: a slide up into place and
///       a fade, both off ui_anim_in(oa, i). Returns the ease so the
///       caller can skip a part that has not started. Pair every call
///       with __part_end().
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
