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
		// THE SAFETY NET (his report, 2026-09-13: "the credit core disappeared"
		// - a chain stalled on an earlier objective never reached it). Every
		// feature the objectives grant ALSO arrives by the game's own
		// numbers, whichever comes first (unfold_grant is idempotent): the
		// chain teaches, it does not gate
		{ key : "dials", banner : "something on the right",
		  need : function() { return variable_global_exists("dial") && (g.profit >= arb(100) || g.dial[0].level > 0); } },
		{ key : "statistics", banner : "",
		  need : function() { return unfold_has("dials"); } },
		{ key : "upgrades", banner : "a credit - the menu has a use for it",
		  need : function() { return variable_global_exists("total_credits") && g.total_credits >= arb(1); } },
		{ key : "automation", banner : "new: automation",
		  need : function() { return variable_global_exists("dial") && g.dial_total > 2 && g.dial[2].level > 0; } },
		{ key : "tiles", banner : "new: tiles",
		  need : function() { return variable_global_exists("dial") && ((g.dial_total > 3 && g.dial[3].level > 0) || g.profit >= arb(100000)); } },
		{ key : "abilities", banner : "new: abilities",
		  need : function() { return variable_global_exists("rebirth") && g.rebirth.total >= 2; } },   // (the second rebirth, his call 2026-09-14)
		{ key : "ccore", banner : "new: the credit core",
		  need : function() { return variable_global_exists("total_credits") && g.total_credits >= arb(15); } },
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
		// THE MILESTONE SCALE'S SAFETY NET (2026-09-13): the objective batch
		// after rebirth grants it; a pile within eight orders of the first
		// milestone (DE's uf_rebirthmilestone test: 1e8 toward 1e16) gets
		// it regardless, as does any pile past a milestone
		{ key : "scale", banner : "new: the milestone scale",
		  need : function() { return variable_global_exists("profit") && variable_global_exists("rebirth") && (rebirth_fed() >= arb(100000000) || g.rebirth.hi_ms > 0); } },
		// THE CHEAT SHOP (2026-09-13): rebirth_do grants it; the net for a save
		// that rebirthed before it existed
		{ key : "cheat", banner : "new: the cheat shop",
		  need : function() { return variable_global_exists("rebirth") && g.rebirth.total > 0; } },
		// THE COIN'S NET (2026-09-13): the abilities objective rewards it; a save
		// that finished that batch before the coin existed gets it here
		{ key : "coin", banner : "a coin on the table - tap it to flip",
		  need : function() { return variable_global_exists("obj") && (g.obj.done[$ "abil"] ?? false); } },
		// THE PUCK (his call, 2026-09-14: "not till the tutorial is complete"):
		// the chain done, the puck arrives - the toy is the graduation
		{ key : "puck", banner : "a puck - fling it",
		  need : function() { return variable_global_exists("obj") && is_undefined(objective_cur()); } },
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
