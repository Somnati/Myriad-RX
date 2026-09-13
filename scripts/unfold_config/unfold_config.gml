/// @description unfold_config() -> THE TIME-GATED ARRIVALS, one row a
/// feature: key, the banner, need() - true when the game says it is
/// time - and an optional on() that runs once when it does. Rows are
/// checked in order every second (unfold_tick); a row whose need is
/// met unfolds for good (unfold_grant). The first fold, "tap", is the
/// veil (syst_unfold). EVERYTHING ELSE ARRIVES THROUGH THE OBJECTIVES
/// (objective_config, his spec 2026-09-13): the drawer, upgrades,
/// automation, tiles, abilities, the core, rebirth, and the things not
/// on by default - critical taps, the overcharger, the dice, the puck.
/// Only what an absence or the clock earns lives here.
function unfold_config() {
	static _c = [
		// the battery and the offline log, after the first real absence -
		// once there are dials for it to have run
		{ key : "battery", banner : "the battery ran while you were away",
		  need : function() { return unfold_has("dials") && variable_global_exists("time_played_offline") && g.time_played_offline >= 60; } },
		{ key : "offlog", banner : "",
		  need : function() { return unfold_has("battery"); } },
		// the time bank, after a longer one
		{ key : "timebank", banner : "new: the time bank",
		  need : function() { return unfold_has("battery") && variable_global_exists("time_played_offline") && g.time_played_offline >= 600; } },
		// REBIRTH'S SAFETY NET: the objective chain grants it (the last
		// objective), but a chain stalled on "merge two tiles" must never
		// hold the loop hostage - within a decade of the gate it arrives
		// regardless (unfold_grant is idempotent: whichever comes first)
		{ key : "rebirth", banner : "new: rebirth",
		  need : function() { return variable_global_exists("rebirth") && (g.rebirth.total > 0 || rebirth_calc().gfrac >= 5 / 6); } },
		// the daily gift, a quarter hour in
		{ key : "gift", banner : "a gift is waiting",
		  need : function() { return variable_global_exists("time_played_active") && g.time_played_active >= 900; } },
		// the first sprite wanders in - and with it, expeditions
		{ key : "sprite", banner : "someone wandered in",
		  need : function() { return unfold_has("tiles") && variable_global_exists("dial") && g.profit >= arb(1000000); },
		  on : function() {
			if (!variable_global_exists("sprites")) sprites_init();
			if (array_length(g.sprites) == 0) { var _sp = sprite_spawn("tap"); _sp.found = "home"; }
		  } },
		{ key : "expeditions", banner : "new: expeditions",
		  need : function() { return unfold_has("sprite"); } },
	];
	return _c;
}
