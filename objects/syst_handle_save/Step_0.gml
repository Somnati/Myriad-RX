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
// ---- THE CHART IN THE BACKGROUND (his call, 2026-09-17: "the loading screen
// on boot needs to go"): the galaxy in slices of bg_budget ms a frame under
// play - invisible - then the home world's rows and its bake the same way
// (the panel opens on the finished model; his report 2026-09-15). The
// expedition panel's veil sets bg_rush while it waits, and the slice grows
// to the boot's 9 ms. A new game's fresh seed restarts it (starmap_get
// finishes a half-built one in place if anything asks first) ----
if (boot_phase >= 2) {
	var _bgb = bg_rush ? 9 : bg_budget;
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
