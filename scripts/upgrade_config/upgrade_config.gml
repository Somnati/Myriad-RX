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
///   band   [min, max] BASE value a tier - DE's 4..6 for the profit
///          rows - before the tier law (upgrade_tier_add: the per-tier
///          ramp, the last tier's jump and the rarity multiplier all
///          live there, ported from DE 2026-09-17)
///   cap    tier ceiling before rarity widens it
///   cost   base credit price of tier 1
///   col    the colour the row wears
///   help   one line, shown under the name
///   avail  a function returning whether this can be rolled yet. THE
///          UNLOCK GATE - an upgrade for a system that does not exist
///          must not appear, and this is where that is decided.
///   dial   (per-dial entries) which dial the boost lands on
///   group  (optional) the automation panel's toggle key - the thirteen
///          per-dial entries share one, with `gname` as its label
///   burst  (grants) true = a TIMED burst: `band` is the multiplier's
///          excess (x1 + band x sqrt(rarity)), `dur` its clock in seconds
///          (x sqrt(rarity)), `kind` the lane ("tap" / "dial")
///
/// THE REWORK (his call, 2026-09-16 - "scrap all the upgrade types you
/// added"): three standing modifiers - tap profit, ALL-dial profit, ONE
/// dial's profit (offered for the two highest dials you own, the ones
/// carrying the run) - stacking MULTIPLICATIVELY in update_dial, and two
/// bursts - x tap profit / x dial profit for a while, the number and the
/// clock rolled ("sometimes i might get x1.58 for 2:30min"). Bursts of
/// one kind ADD their bonus parts and keep SEPARATE clocks (his rule).
/// Crit, speed, discount, credit, luck and rebirth rows are gone.
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
			band : [4, 6], cap : 10, cost : 6, col : c_gold,
			help : "every tap pays more",
			avail : function() { return true; },
		},
		{
			id : "dial_profit", name : "dial profit", stat : "dial_profit",
			band : [2, 4], cap : 10, cost : 8, col : c_sgreen,
			help : "every dial pays more per cycle",
			avail : function() { return true; },
		},
	];

	// ---- ONE DIAL'S PROFIT, an entry per dial ----
	// The id names the dial (upgrade_bonus reads `dial` off the entry,
	// so the completed ledger needs nothing new). Offered only for the
	// TWO HIGHEST dials you own - the ones carrying the run; a boost on
	// dial a while dial e is paying is a dead roll, and a boost on a
	// dial you have not opened does nothing until you do.
	var _dn = variable_global_exists("dial_total") ? g.dial_total : 13;
	for (var _i = 0; _i < _dn; _i++) {
		array_push(g.upg_cfg, {
			id : "dial_one_" + string(_i), name : "dial " + dial_config(_i).name + " profit",
			stat : "dial_one", dial : _i, group : "dial_one", gname : "one dial's profit",
			band : [4, 6], cap : 8, cost : 5, col : c_seagreen,
			help : "this one dial pays more per cycle - it multiplies with dial profit",
			// self is the entry (a function literal in a struct literal
			// binds to the struct), so `dial` is this entry's own
			avail : function() { return upgrade_dial_hot(dial); },
		});
	}

	// ---- THE BURSTS (grants with a value) ----
	// ⚖️ A GRANT IS NOT A MODIFIER, and mixing the two is what forced
	// DE's effects to be accumulated rather than derived. A modifier
	// is a number recomputed from what you own; a grant changes state
	// once and is gone. Keeping them apart is what lets everything
	// else be derived - see upgrade_bonus. A burst is a grant: buying
	// it frees the slot and starts a clock (upgrade_burst_start); the
	// payout seats read the running bursts result-side
	// (upgrade_burst_mult), never the slot.
	array_push(g.upg_cfg,
		{
			id : "burst_tap", name : "tap burst", stat : "", burst : true, kind : "tap",
			band : [0.5, 1.3], dur : [90, 180], cap : 1, cost : 10, col : c_gold,
			help : "every tap pays x more for a while, from the moment you buy it",
			avail : function() { return true; },
		},
		{
			id : "burst_dial", name : "dial burst", stat : "", burst : true, kind : "dial",
			band : [0.5, 1.3], dur : [90, 180], cap : 1, cost : 12, col : c_sgreen,
			help : "every dial pays x more for a while, from the moment you buy it",
			avail : function() { return true; },
		});
	// ("another slot" is NOT an offer any more - his call, 2026-09-17: the
	// next locked slot shows a "new slot" upgrade sitting in it, and
	// buying that frees the slot. See upgrade_slot_buy / the screen. An
	// old save's new_slot offer drops on load like any retired id.)
	return g.upg_cfg;
}
