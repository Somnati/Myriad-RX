/// @description save_autosave_rotate();
/// the rotating autosave: flushes the live state to the main savefile,
/// then walks it down a ladder of three backup slots.
///
/// IT USED TO BE A FLAT SHIFT - 3 <- 2 <- 1 <- fresh, every rotation -
/// and since the clock fires every 60 seconds that gave three restore
/// points spanning THREE MINUTES. Fine as crash protection, useless as
/// "put me back to before I did that". You could not see it until the
/// saves menu started printing a stamp on every row (2026-09-07); then
/// it read 1 minute / 2 minutes / 3 minutes ago and the problem was
/// obvious.
///
/// THE LADDER: slot 1 always takes the fresh snapshot, but a promotion
/// into slot 2 only happens once slot 2 is older than g.backup_mid, and
/// into slot 3 once slot 3 is older than g.backup_deep. The gate is on
/// the RECEIVING slot's age, so each rung holds its ground until it has
/// earned its place in the past:
///   slot 1   the last minute
///   slot 2   up to backup_mid old   (default 10 minutes)
///   slot 3   up to backup_deep old  (default 1 hour)
/// Both knobs live in settings > gameplay. Setting them to 0 restores
/// the old flat cascade exactly - every rotation promotes.
///
/// Three SEPARATE files, so a death mid-write can only ever corrupt one
/// of them; the boot failsafe (save_recover) walks them newest-first.
function save_autosave_rotate() {

	// flush current state to the main save first
	with (syst_handle_save) {
		action = sv_save;
		handle_save();
		action = -1;
	}

	var _main = syst_handle_save.file_to_handle;
	if (!file_exists(_main)) return false;

	var _a1 = save_slot_path(1);
	var _a2 = save_slot_path(2);
	var _a3 = save_slot_path(3);

	// the gates, in minutes (defaults match settings_defaults, so this
	// still behaves if it somehow runs before settings.ini loads)
	var _mid  = variable_global_exists("backup_mid")  ? g.backup_mid  : 10;
	var _deep = variable_global_exists("backup_deep") ? g.backup_deep : 60;

	// how old a slot is, in minutes. a gm datetime IS days as a real, so
	// the span is a subtraction x 1440. A missing or unstamped file
	// counts as INFINITELY old, which is what fills an empty ladder
	// straight up on the first rotations instead of leaving 2 and 3
	// blank. A stamp in the FUTURE (clock wound back) reads negative and
	// simply never promotes - the same anti-rollback stance the offline
	// replay takes, and holding still until time catches up costs
	// nothing.
	var _now = date_current_datetime();
	var _age = function(_f, _n) {
		if (!file_exists(_f)) return 999999;
		ini_open(_f);
		var _d = ini_read_real("system", "save_datetime", 0);
		ini_close();
		if (_d <= 0) return 999999;
		return (_n - _d) * 1440;
	};

	// promote from the BOTTOM UP, so slot 2's outgoing content reaches
	// slot 3 before slot 1 overwrites it (delete first: file_copy onto
	// an existing file is undefined-ish across platforms, never risk it)
	if (_age(_a2, _now) >= _mid) {
		if (_age(_a3, _now) >= _deep) {
			if (file_exists(_a3)) file_delete(_a3);
			if (file_exists(_a2)) file_copy(_a2, _a3);
		}
		if (file_exists(_a2)) file_delete(_a2);
		if (file_exists(_a1)) file_copy(_a1, _a2);
	}

	// slot 1 always takes the fresh snapshot
	if (file_exists(_a1)) file_delete(_a1);
	file_copy(_main, _a1);

	show("autosave > rotated");
	return true;
}
