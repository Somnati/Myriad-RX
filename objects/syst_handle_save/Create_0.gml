

action = sv_load;

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
// the credit panel (game/credits): persistent, every room, self-hiding
if (!instance_exists(obj_display_credits)) create_obj(0, 0, obj_display_credits);
// the spark pool: persistent, allocated once, idle in every room that
// never calls spark_burst (its Step and Draw both leave immediately on
// an empty pool)
if (!instance_exists(syst_sparks)) create_obj(0, 0, syst_sparks);
// the time bank's burn indicator: persistent, shows itself only in the
// money room and only while a multiplier is running
if (!instance_exists(syst_timebank)) create_obj(0, 0, syst_timebank);
