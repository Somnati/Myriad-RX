/// @description create_dials([force]) - build the dial layer from
/// nothing (Myriad DE's create_new_auto, once per dial, plus the
/// clicker's own state). THE fresh-run entry point: setgame calls it at
/// boot, game_reset calls it for a new run.
/// IMPROVED vs DE: DE spreads a dial across ~40 parallel global arrays
/// (global.level[s], global.cps[s], global.gpc[s], ...). RX gives each
/// dial ONE struct in g.dial[], so a dial can be passed, inspected and
/// serialised as a single thing. The maths is DE's, untouched.
/// THE THIRTEEN: a..m, DE's roster (g.dial_total = 13).
function create_dials(_force = false) {

	g.dial_total = 13;
	g.dial = [];

	for (var _i = 0; _i < g.dial_total; _i++) {
		g.dial[_i] = {
			// ---- owned state (this is what the save carries) ----
			level     : 0,
			cycle     : 0,     // 0..1 progress through the current cycle
			auto      : true,  // DE gates autonomy behind an upgrade -
			                   // until that layer exists dials run free
			                   // once bought, or nothing would move
			// ---- derived every update_dial, never saved ----
			b_gps     : 0,     // the base curve's output (dial_gps)
			gps       : 0,     // per SECOND, after the level ramp
			gpc       : 0,     // per CYCLE - what a completed cycle pays
			cps       : 0,     // cycles per second
			cycle_t   : 0,     // seconds per cycle, after autoeff
			// ---- view feedback (consumed by the room, not saved) ----
			paid      : false, // one frame true when a cycle landed
			paid_amt  : 0,     // ...and what it paid, for the motes to carry
			glow      : 0,
		};
	}

	// the aggregates every consumer reads (DE's update_all_gps)
	g.all_level   = 0;
	g.all_gps     = 0;
	g.all_gps_raw = 0;   // the dial curves alone - see update_dials

	create_clicker();
	update_dials();
}
