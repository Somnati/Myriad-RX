// the time bank's speed: the tile sim rides the SAME paid multiplier
// every other sim system got this frame (timebank_spend set live_m -
// one payment covers the whole layer)
var _m = variable_global_exists("timebank") ? g.timebank.live_m : 1;
tiles_tick(_m);

// ---- SHARDS, the table's own currency (his call) ----
// It used to pay profit, which made it a third faucet on a pile that
// already had two: the board's state had no consequence of its own, and
// rebirth - which prices a run off profit held - was quietly measuring
// the tile table. Shards close the loop instead. The board is the only
// source and tile_upg is the only sink, so what happens on the board is
// the only thing that moves either.
//
// WHOLE SECONDS, deliberately. do_scale clamps a sub-1 result up to
// arb(1), so paying a fraction of a second's income every frame would
// round a trickle up to a whole unit sixty times a second and mint
// currency out of nothing. Banking the seconds and paying when at least
// one has passed keeps the arithmetic honest at any rate.
pay_acc += (delta / 60) * _m;
if (pay_acc >= 1) {
	var _whole = floor(pay_acc);
	pay_acc -= _whole;
	if (g.tiles.gps >= arb(1)) {
		var _add = do_scale(g.tiles.gps, _whole);
		g.tiles.shards = (g.tiles.shards >= arb(1))
			? do_add(g.tiles.shards, _add) : _add;
		g.tiles.earned = (g.tiles.earned >= arb(1))
			? do_add(g.tiles.earned, _add) : _add;

		// ⚖️ THE SECOND'S EARNINGS, FLOATED OVER THE BOARD (his ask). It
		// is spawned HERE, at the one site that decides what a second
		// was worth, rather than in the room's Draw off a re-read of
		// gps - a float that recomputes its own number is a float that
		// can disagree with the bank it is reporting.
		//
		// THE ROOM IS THE GATE. This object ticks in every room by
		// design (that is the whole point of it being persistent), and a
		// float is ceremony: syst_tiles publishes where the board is and
		// only exists while you are looking at it, so its absence is
		// exactly the right condition for staying silent.
		if (instance_exists(syst_tiles))
			float_text(syst_tiles.float_x, syst_tiles.float_y,
				"+" + crunch_arb(_add), c_aqua, fnt_outline);
	}
}
