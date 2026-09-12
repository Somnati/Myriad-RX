/// @description upgrade_config() - THE UPGRADE ROSTER, declared as data.
///
/// >>> TO ADD AN UPGRADE: add ONE entry to the array below. Nothing
/// >>> else. The effect is named by `stat`, the derivation reads it
/// >>> generically, and the screen draws whatever is here.
///
/// Myriad DE spread each upgrade across four files - the roster, a
/// 25-branch `if name = "..."` chain inside buy_upgrade, the display
/// function, and a separate accumulator reset - and a typo in any one
/// of those strings silently did nothing at all. Same authoring shape
/// as dial_config and settings_content instead: one place, and a
/// mistake is a missing field rather than a silent no-op.
///
/// THE MODEL (DE's, kept - it is the best idea in their version):
/// slots are SCARCE and each holds one rolled offer you can keep
/// LEVELLING. Buying raises its tier and its price; selling refunds
/// part of what you put in and frees the slot for a new roll. That
/// makes a slot a standing investment with a real sunk cost, rather
/// than a shopping list you work down.
///
/// FIELDS:
///   id     save key. NEVER change one - it is what a save stores.
///   name   what the screen calls it
///   stat   which accumulator it feeds (see upgrade_bonus). "" = a
///          GRANT, which does something once and consumes itself.
///   band   [min, max] value per tier at rarity 0, before the rarity
///          multiplier. Percent for every current entry.
///   cap    tier ceiling before rarity widens it
///   cost   base credit price of tier 1
///   col    the colour the row wears
///   help   one line, shown under the name
///   avail  a function returning whether this can be rolled yet. THE
///          UNLOCK GATE - an upgrade for a system that does not exist
///          must not appear, and this is where that is decided.
function upgrade_config() {
	// ⚖️ BUILT ONCE. upgrade_entry runs per row per frame on the screen,
	// and rebuilding ten structs and ten closures each time is real
	// allocation churn for a list that never changes. The `avail`
	// closures are evaluated at ROLL time, not here, so caching the
	// array does not freeze the gates - they still answer live.
	if (variable_global_exists("upg_cfg")) return g.upg_cfg;
	g.upg_cfg = [
		{
			id : "tap_profit", name : "tap profit", stat : "tap_profit",
			band : [4, 9], cap : 12, cost : 6, col : c_gold,
			help : "every tap pays more",
			avail : function() { return true; },
		},
		{
			id : "crit_rate", name : "critical chance", stat : "crit_rate",
			band : [1, 2.5], cap : 10, cost : 9, col : c_horange,
			help : "more taps roll a critical",
			// no point offering it before crits exist as a concept
			avail : function() { return variable_global_exists("click_crit"); },
		},
		{
			id : "crit_multi", name : "critical payout", stat : "crit_multi",
			band : [0.15, 0.4], cap : 10, cost : 11, col : c_horange,
			help : "criticals pay a bigger multiple",
			avail : function() { return variable_global_exists("click_crit"); },
		},
		{
			id : "dial_profit", name : "dial profit", stat : "dial_profit",
			band : [5, 11], cap : 14, cost : 8, col : c_sgreen,
			help : "every dial pays more per cycle",
			avail : function() { return true; },
		},
		{
			id : "dial_speed", name : "dial speed", stat : "dial_speed",
			band : [3, 7], cap : 10, cost : 10, col : c_sblue,
			help : "every dial cycles faster",
			avail : function() { return true; },
		},
		{
			id : "dial_cost", name : "dial discount", stat : "dial_cost",
			band : [1.5, 3.5], cap : 10, cost : 12, col : c_steelblue,
			help : "dial levels cost less profit",
			avail : function() { return true; },
		},
		{
			id : "credit_rate", name : "credit refill", stat : "credit_rate",
			band : [6, 14], cap : 10, cost : 7, col : c_lavender,
			help : "the credit pool refills faster",
			avail : function() { return variable_global_exists("credit_refill"); },
		},
		{
			id : "credit_luck", name : "credit luck", stat : "credit_luck",
			band : [4, 10], cap : 8, cost : 9, col : c_lavender,
			help : "more taps find credits",
			avail : function() { return variable_global_exists("credit_tap_chance"); },
		},
		{
			// LUCK (DE's, his ask 2026-09-12): flat points, not a percent -
			// luck_mod turns the points into the multiplier every chance
			// in the game takes. DE's roster gave 1 a tier at rare up to
			// 5 at ultimate for 25 credits; here the band is the points
			// and the rarity multiplier does the climbing
			id : "luck", name : "luck", stat : "luck",
			band : [1, 2], cap : 10, cost : 25, col : c_seagreen,
			help : "every roll in the game leans your way",
			avail : function() { return true; },
		},
		{
			id : "rebirth_units", name : "rebirth units", stat : "rebirth_units",
			band : [3, 7], cap : 8, cost : 14, col : c_hred,
			help : "rebirth awards more units",
			// meaningless until a rebirth is actually reachable
			avail : function() {
				return variable_global_exists("rebirth") && g.rebirth.total > 0;
			},
		},
		{
			// the hold's rate, DE's u_tps lane. A percentage rather than
			// DE's flat points because tap_rate is fractional here and a
			// percentage keeps its value as the base grows through
			// abilities and gear later.
			id : "tap_rate", name : "tap speed", stat : "tap_rate",
			band : [6, 14], cap : 12, cost : 7, col : c_gold,
			help : "holding taps faster",
			avail : function() { return true; },
		},

		// ---- GRANTS ----
		// ⚖️ A GRANT IS NOT A MODIFIER, and mixing the two is what forced
		// DE's effects to be accumulated rather than derived. A modifier
		// is a number recomputed from what you own; a grant changes state
		// once and is gone. Keeping them apart is what lets everything
		// else be derived - see upgrade_bonus.
		{
			id : "new_slot", name : "another slot", stat : "",
			band : [1, 1], cap : 1, cost : 30, col : c_white,
			help : "one more upgrade slot, permanently",
			avail : function() {
				return upgrade_slots() < UPG_SLOT_MAX;
			},
		},
	];
	return g.upg_cfg;
}
