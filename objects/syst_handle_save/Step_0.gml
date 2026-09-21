// ---- THE BOOT: a frame's grace, then the load at once (the galaxy no longer waits here - his call, 2026-09-17) ----
if (boot_phase < 3) boot_t += 1;   // (the spinner's clock runs the whole boot - it stopped at phase 0 and the chart phase drew black; q270)
if (boot_phase == 0) {
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
// the load ran (the handler above): THE CHART PHASE (q256, his call - "a short loading screen on boot for the galaxy
// bake"; 09-17's screen went because a 9 ms slice hitched under play - this one does the work BEFORE play and is
// bounded): the galaxy charts behind the boot spinner at 14 ms a frame, then the home world's SHEET (rows and bake,
// not the tier) as far as it gets, the whole phase CAPPED at BOOT_CHART_CAP ms of wall time - the panel's veil and
// the background share finish whatever is left, exactly as before. "Something that only has to run once" - his words
if (boot_phase == 1 && action == -1) { boot_phase = 2; boot_t0 = current_time; boot_prog = .5; }
if (boot_phase == 2) {
	var _cap = (current_time - boot_t0) >= BOOT_CHART_CAP;
	if (!galaxy_ready()) {   // (the chart charts to the END whatever the cap - q270: a chart cut short was finished in one frame by the first asker (starmap_get), the stutter on [sprites]; only the home sheet is best-effort)
		if (!is_struct(bg_gen) || bg_gen.seed != g.galaxy_seed) { bg_gen = starmap_gen_begin(g.galaxy_seed); bg_world_done = false; }
		if (starmap_gen_step(bg_gen, 14)) bg_gen = undefined;
		boot_world = "charting the galaxy"; boot_prog = .5 + .3 * galaxy_progress();
	}
	else if (galaxy_ready() && !_cap && !bg_world_done) {
		var _hm0 = galaxy_home(), _gw0 = galaxy_world(_hm0.star, _hm0.planet);
		if (is_struct(_gw0)) {
			var _bpn0 = planet_get(_gw0.seed, exped_planet_hint(_gw0));
			boot_world = "building " + _gw0.name; boot_prog = .8 + .2 * planet_build_progress(_bpn0);
			if (planet_build_step(_bpn0, get_timer() + 14000)) bg_world_done = true;
		} else bg_world_done = true;
	}
	else { boot_phase = 3; boot_prog = 1; boot_world = ""; }
}
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
// DEBUG (q210, his ask): F10 unlocks every mechanic (unfold_all) - DEBUG_KEYS false for release
if (DEBUG_KEYS && keyboard_check_pressed(vk_f10)) { unfold_all(); assign_banner("everything unlocked (f10)", c_gold, c_black); }
if (boot_phase >= 3 && bg_rush) {
	var _bgb = 9;
	if (galaxy_ready()) { if (is_struct(bg_gen)) bg_gen = undefined; }
	else {
		if (!is_struct(bg_gen) || bg_gen.seed != g.galaxy_seed) { bg_gen = starmap_gen_begin(g.galaxy_seed); bg_world_done = false; }
		if (starmap_gen_step(bg_gen, _bgb)) bg_gen = undefined;
	}
	if (galaxy_ready() && !bg_world_done && variable_global_exists("exped") && array_length(g.exped.board) > 0) {
		var _blim = get_timer() + _bgb * 1000;
		var _bpn = planet_get(g.exped.board[0].seed, exped_planet_hint(g.exped.board[0]));
		if (planet_build_step(_bpn, _blim)) bg_world_done = true;   // (rows, then the sheets, on the deadline - the one builder's step, q225)
	}
	bg_rush = false;
}
// THE CHART UNDER PLAY, FOR A CREW OUT (q230, his call (b), 2026-09-18): with the chart off the boot a crew's hours were
// OWED until the expedition panel opened - a session without the panel was a session nobody walked. So while a crew is
// out and the chart is not there, it builds here at one millisecond a frame - the chart alone, no world (the walk reads
// the regions' noise, not a map) - and lands a few seconds after boot, when exped_tick pays the owed hours back in
// slices on the heartbeat. Nobody out, nothing builds: q202's rule stands for the base game
else if (boot_phase >= 3 && !galaxy_ready() && variable_global_exists("exped") && is_struct(g.exped) && array_length(g.exped.trips) > 0) {
	if (!is_struct(bg_gen) || bg_gen.seed != g.galaxy_seed) { bg_gen = starmap_gen_begin(g.galaxy_seed); bg_world_done = false; }
	if (starmap_gen_step(bg_gen, 1)) bg_gen = undefined;
}
// THE TRIPS' WORLDS UNDER PLAY (q293 / q294): a region is its world's territory now (q287), and the territories come with
// the world's build - a crew out on a world that has not stood owes its hours until it has (exped_tick). So the TRIPS'
// worlds build here after boot, a millisecond a frame (the texels answer to it since q294), one at a time. Never the
// board: the board is every world ever opened on the map (thirty and more), and the cache keeps eight - his 2.4 gb
else if (boot_phase >= 3 && galaxy_ready() && variable_global_exists("exped") && is_struct(g.exped)) {
	for (var _bw = 0; _bw < array_length(g.exped.trips); _bw++) {
		var _bwd = g.exped.trips[_bw].dest;
		if (!is_struct(_bwd) || region_ready(_bwd)) continue;
		var _bwp = planet_get(_bwd.seed, exped_planet_hint(_bwd));
		if (!is_struct(_bwp) || _bwp.kind == "gas" || _bwp.tw < 200) continue;
		planet_build_step(_bwp, get_timer() + 1000);
		break;
	}
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
