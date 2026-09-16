// ---- THE BOOT: the galaxy in slices of boot_budget ms, then the load ----
if (boot_phase == 0) {
	boot_t += 1;
	if (boot_t >= 2 && is_struct(boot_gen)) {
		if (starmap_gen_step(boot_gen, boot_budget)) { boot_gen = undefined; boot_phase = 1; action = sv_load; boot_prog = .4; }
		else boot_prog = .4 * starmap_gen_progress(boot_gen);
	}
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
// THE BOARD'S WORLDS TOO (his report, 2026-09-15: "the planet looks really
// bad then all of a sudden updates" - the lite portrait stood in while the
// rows built): their maps are built here behind the spinner, a few rows a
// frame, so the panel opens on the finished model
// - one world at a time, a row at a time, then its bake row by row, all
// under boot_budget ms a frame (2026-09-16: twelve rows of three worlds a
// frame was the stutter; so was a whole bake in one)
if (boot_phase == 1) {
	var _bdone = true, _blim = get_timer() + boot_budget * 1000;
	var _rows_done = 0, _rows_all = 0, _bake_done = 0, _bake_all = 0;
	if (variable_global_exists("exped")) for (var _bi = 0; _bi < array_length(g.exped.board); _bi++) {
		var _bpn = planet_get(g.exped.board[_bi].seed, exped_planet_hint(g.exped.board[_bi]));
		if (_bdone) {
			boot_world = g.exped.board[_bi].name;
			while (_bpn.row < _bpn.th && get_timer() < _blim) planet_gen_step(_bpn, 1);
			if (_bpn.row < _bpn.th) _bdone = false;
			else if (!planet_bake(_bpn, _blim)) _bdone = false;   // (the textures too, behind the spinner: 320x160 x three is a stamp storm - sliced)
		}
		_rows_all += _bpn.th; _rows_done += _bpn.row;
		_bake_all += 3 * _bpn.th; _bake_done += (_bpn[$ "brow"] ?? 0);
	}
	boot_prog = .4 + .4 * ((_rows_all > 0) ? _rows_done / _rows_all : 1) + .2 * ((_bake_all > 0) ? _bake_done / _bake_all : 1);
	boot_prog_v = trickle(boot_prog_v, boot_prog, 4);
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
