// ---- the suspend catch-up ----
var _now = date_current_datetime();
if (_now >= last_now) {
	var _gap = date_second_span(_now, last_now);
	if (_gap >= GAP && variable_global_exists("game_started") && g.game_started)
		offline_replay(_gap);
}
last_now = _now;

// ---- THE PILE'S BUTTON lives in the money room (both shapes of it),
// spawned here rather than placed in the rooms - one runtime instance,
// so neither room can forget it ----
if (variable_global_exists("game_started") && g.game_started)
if (in_room(rm_clicker) && !instance_exists(obj_offlinegold))
	create_obj(0, 0, obj_offlinegold);
// ...and THE VEIL, while the run has not unfolded (syst_unfold)
if (variable_global_exists("game_started") && g.game_started)
if (in_room(rm_clicker) && g.unfold == 0 && !instance_exists(syst_unfold))
	create_obj(0, 0, syst_unfold);

// ---- the report: THE WELCOME-BACK CARD (his ask, 2026-09-11 - the
// stack of banners is gone; syst_welcome tells the absence's story in
// one card, and a tap closes it) ----
if (!variable_global_exists("offline_report")) exit;
var _r = g.offline_report;
if (_r.shown) exit;
if (!in_room(rm_clicker)) exit;
if (!variable_global_exists("game_started") || !g.game_started) exit;
if (ui_overlay() != noone) exit;   // wait for whatever is up to go
_r.shown = true;
if (_r.secs < REPORT_MIN) exit;
create_obj(0, 0, syst_welcome);
