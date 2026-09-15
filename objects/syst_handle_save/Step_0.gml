// ---- THE BOOT: the galaxy a pass a frame, then the load ----
if (boot_phase == 0) {
	boot_t += 1;
	if (boot_t >= 2 && is_struct(boot_gen) && starmap_gen_step(boot_gen)) { boot_gen = undefined; boot_phase = 1; action = sv_load; }
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
// THE BOARD'S WORLDS TOO (his report, 2026-09-15: "the planet looks really
// bad then all of a sudden updates" - the lite portrait stood in while the
// rows built): their maps are built here behind the spinner, a few rows a
// frame, so the panel opens on the finished model
if (boot_phase == 1) {
	var _bdone = true;
	if (variable_global_exists("exped")) for (var _bi = 0; _bi < array_length(g.exped.board); _bi++) {
		var _bpn = planet_get(g.exped.board[_bi].seed, exped_planet_hint(g.exped.board[_bi]));
		if (_bpn.row < _bpn.th) { planet_gen_step(_bpn, 12); _bdone = false; }
		else planet_bake(_bpn);   // (the textures too, behind the spinner: 320x160 x three is a stamp storm)
	}
	if (_bdone) boot_phase = 2;   // (the boot's load ran, the worlds are whole: the title may come)
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
