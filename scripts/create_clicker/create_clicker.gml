/// @description create_clicker() - the TAP's own state (Myriad DE's
/// create_new_clicker). Tapping is not bought and has no level of its
/// own: its power is DERIVED from the dial fleet every update_click,
/// so the two halves of the game pull in the same direction.
/// In DE the tapper is a phantom entry at dial index 13, sharing the
/// dial arrays; RX gives it plain globals instead - the fiction was
/// only ever there to reuse those arrays.
function create_clicker() {
	g.click_gps      = arb(1);  // profit per tap, derived
	g.tapsyphon      = .01;     // the SYPHON: 1% of the fleet's per-second
	                            // output rides on every tap (DE's abilities
	                            // raise this to .02 / .12 / .62)
	g.tapsyphon_pull = 0;       // what the syphon actually contributed
	g.total_taps     = 0;       // lifetime taps (DE feeds abilities off it)

	// ---- CRITICAL TAPS (DE's create_new_clicker, base values kept) ----
	// DE: click_b_crit = 5, critx_min = 1.5, critx_max = 5. A crit pays
	// a RANDOM multiple in that range, so no two land the same - which
	// is most of why they read as luck rather than as a bigger number.
	// DE gates the whole thing behind an unlockable ability
	// (g.ad_critical, drawn from the deck) and folds a luck stat into
	// the roll; RX has neither layer yet, so crits are simply ON and
	// the roll is the plain chance. Both re-enter here when those
	// layers land - the rate is one multiply away from a luck mod.
	// DE also encodes chance ABOVE 100% as guaranteed extra crit tiers
	// (crit_tier = floor(click_crit/100)); nothing in RX can push the
	// rate past 100 yet, so that half is deliberately not ported.
	g.click_crit      = 5;   // percent chance per tap
	g.click_critx_min = 1.5; // the multiplier rolls uniformly
	g.click_critx_max = 5;   //   between these two
	g.total_crits     = 0;   // lifetime crits, DE's g.total_crits

	update_click();
}
