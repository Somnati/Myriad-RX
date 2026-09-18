// ---- THE BOOT: a frame's grace, then the load at once (the galaxy no longer waits here - his call, 2026-09-17) ----
if (boot_phase == 0) {
	boot_t += 1;
	if (boot_t >= 2) { boot_phase = 1; action = sv_load; boot_prog = .5; }
	boot_prog_v = trickle(boot_prog_v, boot_prog, 4);
	exit;
}



if not file_exists(file_to_handle) {action = sv_save;}

if action != -1{

var _was_save = (action == sv_save);
var _was_load = (action == sv_load);
handle_save();
handle_settings(action);
if _was_save {
	g.save_dirty = false; // a manual save counts as clean
	// ux pass: saving is invisible work - one quiet toast says it
	// happened (the banner is persistent, lives everywhere)
	assign_banner("progress saved", c_sgreen, c_black);
}

// THE OFFLINE CATCH-UP (game/offline): a load measures the absence
// from the save's own datetime stamp (last_datetime, read back by
// handle_save's system section) and replays it through the same
// prod_dials that runs live. DE's anti-rollback guard, kept: a stamp
// in the FUTURE means the clock was wound back - replay nothing.
if (_was_load) {
	var _now = date_current_datetime();
	if (last_datetime > _now) assign_banner("times off...", c_hred, c_black);
	else offline_replay(date_second_span(_now, last_datetime));
	if (instance_exists(syst_offline)) syst_offline.last_now = _now;
}

action = -1;}
// the load ran (the handler above): the title may come
if (boot_phase == 1 && action == -1) { boot_phase = 2; boot_prog = 1; }
boot_prog_v = trickle(boot_prog_v, boot_prog, 4);
// ---- THE CHART, ON DEMAND (q202, his call 2026-09-18: "take the loading of
// any planets off the base game - it's causing lag and a hitch when booting
// up... when I hit the expedition header button, if needed, take me to a
// loading screen"): NOTHING of the galaxy or its worlds builds under play.
// The builder below - the chart in slices, then the home world's rows and
// its bake - runs only in the frames the expedition panel's VEIL asks for
// it (bg_rush, set every frame the veil shows), nine ms a frame behind the
// loading screen; the expeditions' clock owes its seconds until the chart
// stands (exped_tick) and replays them then. A new game's fresh seed
// restarts it (starmap_get finishes a half-built one in place if anything
// asks first). (Before: bg_budget slices under play from boot - the 09-17
// design, retired) ----
if (boot_phase >= 2 && bg_rush) {
	var _bgb = 9;
	if (galaxy_ready()) { if (is_struct(bg_gen)) bg_gen = undefined; }
	else {
		if (!is_struct(bg_gen) || bg_gen.seed != g.galaxy_seed) { bg_gen = starmap_gen_begin(g.galaxy_seed); bg_world_done = false; }
		if (starmap_gen_step(bg_gen, _bgb)) bg_gen = undefined;
	}
	if (galaxy_ready() && !bg_world_done && variable_global_exists("exped") && array_length(g.exped.board) > 0) {
		var _blim = get_timer() + _bgb * 1000;
		var _bpn = planet_get(g.exped.board[0].seed, exped_planet_hint(g.exped.board[0]));
		while (_bpn.row < _bpn.th && get_timer() < _blim) planet_gen_step(_bpn, 1);
		if (_bpn.row >= _bpn.th && planet_bake(_bpn, _blim)) bg_world_done = true;
	}
	bg_rush = false;
}

// ---- playtime clock ----
// real seconds, saved per savefile, shown by the save menu slots
g.time_played_active += delta_time / 1000000;

// ---- rotating autosave ----
// on the clock AND dirty AND allowed: idle sessions don't churn the
// disk, and the settings screen's autosave toggle can switch it off
if current_time >= autosave_next {
	autosave_next = current_time + autosave_delay;
	if g.save_dirty
	if (!variable_global_exists("autosave") || g.autosave) {
		save_autosave_rotate();
		g.save_dirty = false;
		assign_banner("autosaved", c_sgreen, c_black); // ux pass
	}
}
