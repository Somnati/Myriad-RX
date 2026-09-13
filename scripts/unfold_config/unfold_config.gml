/// @description unfold_config() -> THE ORDER THINGS ARRIVE, one row a
/// feature: key, the menu line's name (for the banner), need() - true
/// when the game says it is time - and an optional on() that runs once
/// when it does. The first fold, "tap", is the veil (syst_unfold).
/// Rows are checked in order every second (unfold_tick); a row whose
/// need is met is seen for good. Edit here to move a feature earlier
/// or later - the gates are the game's own numbers.
function unfold_config() {
	static _c = [
		// the dial drawer, once the first dial is within reach
		{ key : "dials", name : "dials", banner : "something on the right",
		  need : function() { return variable_global_exists("dial") && (g.profit >= arb(60) || g.dial[0].level > 0); } },
		// statistics, with the dials
		{ key : "statistics", name : "statistics", banner : "",
		  need : function() { return unfold_has("dials"); } },
		// the upgrades table, with the first credit
		{ key : "upgrades", name : "upgrades", banner : "a credit - the menu has a use for it",
		  need : function() { return variable_global_exists("credits") && (g.credits >= arb(1) || g.total_credits >= arb(1)); } },
		// automation, once there are three dials to run
		{ key : "automation", name : "automation", banner : "new: automation",
		  need : function() { return variable_global_exists("dial") && g.dial_total > 2 && g.dial[2].level > 0; } },
		// the tile table, at the fourth dial or a hundred thousand
		{ key : "tiles", name : "tiles", banner : "new: tiles",
		  need : function() { return variable_global_exists("dial") && ((g.dial_total > 3 && g.dial[3].level > 0) || g.profit >= arb(100000)); } },
		// the deck, once credits have a rhythm
		{ key : "abilities", name : "abilities", banner : "new: abilities",
		  need : function() { return variable_global_exists("credits") && g.total_credits >= arb(10); } },
		// the credit core, a little later
		{ key : "ccore", name : "credit core", banner : "new: the credit core",
		  need : function() { return variable_global_exists("credits") && g.total_credits >= arb(15); } },
		// rebirth, within a decade of the gate (or ever done)
		{ key : "rebirth", name : "rebirth", banner : "new: rebirth",
		  need : function() { return variable_global_exists("rebirth") && (g.rebirth.total > 0 || rebirth_calc().gfrac >= 5 / 6); } },
		// the battery and the offline log, after the first real absence
		{ key : "battery", name : "battery", banner : "the battery ran while you were away",
		  need : function() { return variable_global_exists("time_played_offline") && g.time_played_offline >= 60; } },
		{ key : "offlog", name : "offline log", banner : "",
		  need : function() { return unfold_has("battery"); } },
		// the time bank, after a longer one
		{ key : "timebank", name : "time bank", banner : "new: the time bank",
		  need : function() { return variable_global_exists("time_played_offline") && g.time_played_offline >= 600; } },
		// the daily gift, a quarter hour in
		{ key : "gift", name : "daily gift", banner : "a gift is waiting",
		  need : function() { return variable_global_exists("time_played_active") && g.time_played_active >= 900; } },
		// the first sprite wanders in - and with it, expeditions
		{ key : "sprite", name : "sprites", banner : "someone wandered in",
		  need : function() { return unfold_has("tiles") && variable_global_exists("dial") && g.profit >= arb(1000000); },
		  on : function() {
			if (!variable_global_exists("sprites")) sprites_init();
			if (array_length(g.sprites) == 0) { var _sp = sprite_spawn("tap"); _sp.found = "home"; }
		  } },
		{ key : "expeditions", name : "expeditions", banner : "new: expeditions",
		  need : function() { return unfold_has("sprite"); } },
	];
	return _c;
}
