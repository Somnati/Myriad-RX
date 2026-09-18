/// @description dims_init([force]) - THE DIMENSIONS' state (the antimatter-dimensions cascade, ported from the tech demo 2026-09-18 - stand-alone: nothing feeds on it yet; its currency DARK MATTER, the demo's placeholder renamed)
/// The bench's state (his ask, 2026-07-07: an AD-style cascade to feel
/// out before deciding what it feeds - the candidate resin multiplier
/// is DISPLAYED, not wired). g.dims: 8 tiers where tier 0 produces
/// DARK MATTER (the antimatter analog, also the currency the bench spends)
/// and tier i produces tier i-1's COUNT - bought copies also count
/// toward the per-10 doubling, produced copies don't (AD's split,
/// mirrored). `last` is a WALL-CLOCK stamp (universal clock doctrine:
/// date_current_datetime x 86400): dims_tick advances by real elapsed
/// seconds whether the game ran or not - offline progress is EXACT by
/// construction here (closed form, see dims_tick).
///
/// LOG10 REWORK (his bug report: raw floats hit 1.8e308 and the bench
/// drowned in inf/NaN): counts, dark matter and costs now LIVE as log10
/// values - the same trick the arb library plays internally - so the
/// ceiling is gone (log10 itself would have to overflow) and the
/// closed form stays exact. zero is the `lz` sentinel (no log of 0);
/// ladd/lsub are the log-space + and - (log-sum-exp: peel the bigger
/// term out, the tail is a plain float). bought/tick_bought stay
/// small ints. starts with 10 dark matter (log10 = 1), AD's opening hand.
///
/// THE WALL IS THE GAME (round 2, his call after beating the
/// uncapped bench in 10min): log10 dark matter 308.2547 = 1.8e308 = AD's
/// infinity ENDS the run - dims_tick freezes the cascade, the room
/// shows the banner with the run clock, [big crunch] calls
/// dims_init(true). `best` (fastest infinity, wall-clock seconds)
/// SURVIVES the crunch - it's the score.
function dims_init(_force = false) {
	if (variable_global_exists("dims") && !_force) return;
	var _best = -1; // the one field that rides across crunches
	if (variable_global_exists("dims") && is_struct(g.dims))
		_best = g.dims[$ "best"] ?? -1;
	g.dims = {
		n : 8,
		// log-space ZERO sentinel (a billion decades down: 10^lz is 0
		// in any world). "does this count exist" checks compare
		// against lz/2. NOTE plain digits: GML has no 1e9 literals
		lz : -1000000000,
		count  : array_create(8, -1000000000), // live counts, LOG10
		bought : array_create(8, 0),    // per-10 doubling rides THESE only
		dark : 1,                            // log10(10)
		tick_bought : 0,                // tickspeed: x1.15 each, global
		last : date_current_datetime() * 86400,
		// ---- the race ----
		start : date_current_datetime() * 86400, // run clock, wall time
		wall : 308.2547, // log10(1.8e308): AD's infinity, the finish line
		inf : false,     // crossed: cascade frozen until the big crunch
		run : -1,        // the finished run's seconds (banner readout)
		best : _best,    // fastest infinity ever - survives crunches
		// log10(10^a + 10^b): past ~15 decades apart the small term is
		// below double precision - just keep the big one
		ladd : function(_a, _b) {
			if (_a < _b) { var _t = _a; _a = _b; _b = _t; }
			if (_a - _b > 15) return _a;
			return _a + log10(1 + power(10, _b - _a));
		},
		// log10(10^a - 10^b), a >= b; spending everything bottoms out
		// at the zero sentinel instead of log10(0). near-equal spends
		// land on a hugely negative log - effectively zero, harmless
		lsub : function(_a, _b) {
			var _r = power(10, _b - _a);
			if (_r >= 1) return lz;
			return _a + log10(1 - _r);
		},
	};
}
