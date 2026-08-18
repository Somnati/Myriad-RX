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
	update_click();
}
