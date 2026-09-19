

// THE BOOT (2026-09-15, his ask: a black screen with a spinner while the
// galaxy built; 2026-09-17, his call: "the loading screen on boot needs to
// go"): the load goes at once and the title follows (syst_roomtrans waits
// for boot_phase 2); THE GALAXY CHARTS IN THE BACKGROUND under play (the
// Step, bg_* - a small slice a frame), then the home world's rows and bake.
// Whatever needs it first waits with the expedition panel's loading veil
// (the boot's spinner, moved there) or, for a trip's clock, is owed (exped_tick)
action = -1;
boot_phase = 0;       // 0 a frame's grace, 1 the load queued, 2 THE CHART (q256: the galaxy, then the home world's sheet, capped), 3 done
boot_t0 = 0;          // the chart phase's start (current_time) - the cap counts from here
boot_gen = undefined;
boot_t = 0;
// THE BUDGET (2026-09-16, his report: "it stutters pretty bad"): every boot
// job - the galaxy's passes, the worlds' rows, the bakes' stamps - runs in
// slices of this many ms a frame and resumes next frame, so the spinner
// turns at the frame rate. 9 ms leaves a 60 Hz frame its draw; a faster
// monitor simply shows more frames of it
boot_budget = 9;
boot_prog = 0;        // 0..1, the boot's real progress (the bar under the caption)
boot_prog_v = 0;      // the bar, easing to it
boot_world = "";      // the world being built now (the caption names it - his ask, 2026-09-16)

// THE LAST PROFILE PLAYED (his report, 2026-09-17: continue always opened
// profile 1). settings.ini remembers it - handle_settings WRITES it on
// every settings save and never reads it back (a read there would drag a
// freshly loaded profile back to the last one mid-load). Read once, here,
// before the pointer below is seated. (setgame's boot default only fills
// the global in if this has not run yet - either creation order works)
ini_open("settings.ini");
g.profile = clamp(floor(ini_read_real("gameplay", "profile", 0)), 0, 3);
ini_close();
file_to_handle = save_slot_path(0); // active profile's main save

// boot failsafe: if the device died mid-write and mangled the main
// save, restore the newest valid autosave BEFORE the first load reads it
save_recover();

// continue = the run you were ACTUALLY on (his report): if a rotating
// autosave is NEWER than the main save (played on, quit without a
// manual save), promote it over the main - the exact restore move the
// saves menu does by hand, done automatically at boot.
var __dt = function(_f) {
	if (!file_exists(_f)) return 0;
	ini_open(_f);
	var _d = ini_read_real("system", "save_datetime", 0);
	ini_close();
	return _d;
};
var _main_dt = __dt(file_to_handle);
var _best = -1;
var _best_dt = _main_dt;
for (var _s = 1; _s <= 3; _s++) {
	var _d = __dt(save_slot_path(_s));
	if (_d > _best_dt) { _best_dt = _d; _best = _s; }
}
if (_best > 0) {
	if (file_exists(file_to_handle)) file_delete(file_to_handle);
	file_copy(save_slot_path(_best), file_to_handle);
	show("> boot: autosave " + string(_best) + " was newer - promoted");
}

// rotating autosave clock (autosave_1/2/3.ini, newest first). fires on
// the interval, but only writes when gameplay flagged a change via
// save_mark_dirty()
autosave_delay = 60000; // ms, 1 minute
autosave_next  = current_time + autosave_delay;

// the absence watcher (game/offline): persistent, spawned here so it
// exists from boot in every room without a room placement
if (!instance_exists(syst_offline)) create_obj(0, 0, syst_offline);
if (!instance_exists(syst_objectives)) create_obj(0, 0, syst_objectives);   // the objective card (the money room's top left)
// the credit panel (game/credits): persistent, every room, self-hiding
if (!instance_exists(obj_display_credits)) create_obj(0, 0, obj_display_credits);
// the spark pool: persistent, allocated once, idle in every room that
// never calls spark_burst (its Step and Draw both leave immediately on
// an empty pool)
if (!instance_exists(syst_sparks)) create_obj(0, 0, syst_sparks);
// the time bank's burn indicator: persistent, shows itself only in the
// money room and only while a multiplier is running
if (!instance_exists(syst_timebank)) create_obj(0, 0, syst_timebank);
// ...and DE's speed arrow, top-right of the same room while it runs
if (!instance_exists(obj_boost_spd)) create_obj(0, 0, obj_boost_spd);

// the galaxy's seed, peeked off the save before anything loads (a save
// from before the galaxy, or no save at all, gets the tech demo's 1337; a
// NEW game rolls its own later and builds that one in the moment)
var _gs = 1337;
if (file_exists(file_to_handle)) { ini_open(file_to_handle); _gs = ini_read_real("exped", "ex_galaxy", 1337); ini_close(); }
g.galaxy_seed = max(1, floor(_gs));
bg_gen = undefined;       // the background chart's context (starmap_gen_begin) while it runs
bg_budget = 2.5;          // ms a frame for it under play (the panel's veil rushes it to the boot's 9)
bg_rush = false;
bg_world_done = false;    // the home world's rows and bake, after the chart
// (rm_gameload is a 144x296 stub with no obj_set_landscape: the gui was
// the window's own pixels and the spinner drew warped - the landscape
// rooms' 480x270 gui, so the boot screen is the game's own scale)
display_set_gui_size(480, 270);
