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
		if (instance_exists(syst_tiles)) {
			float_text(syst_tiles.float_x, syst_tiles.float_y,
				"+" + crunch_arb(_add), c_aqua, fnt_outline);

			// ⚖️ THE BITS (his ask): one mote a second per occupied
			// tile, in THAT TILE'S COLOUR, into the spark - the same
			// bezier framework the dials pay through, pointed at the
			// shard count instead of the header. It is what makes the
			// board read as PRODUCING rather than as a grid with a
			// number floating over it, and a high tier's colour arriving
			// is a high tier paying.
			//
			// ⚖️ FROM EACH TILE, FROM UNDERNEATH (his call, 2026-09-10,
			// the third shape of this). First they left from every tile
			// over the board - "pretty noisy". Then from one point over
			// the top edge - a fountain, quiet, but the colours no
			// longer said WHICH tile was paying. Now each tile throws
			// its own mote again, at a depth one below the board, so it
			// spawns hidden under the tile and emerges from its edge on
			// the way up - the source is legible and nothing crosses the
			// tiles in front. The near-straight curve and the pace stay.
			//
			// No amount carried - that lane holds the HEADER's counter
			// back until motes land, and shards have no such counter to
			// hold. Purely the flow, drawn.
			//
			// NEARLY STRAIGHT AND QUICK: swing 6 - a bow of a few px,
			// not Myriad's room-wide swoop - and x1.3 on the pace. The
			// tight curve is most of the speed by itself: the library
			// paces on path length, and a control point thrown across
			// the room made a short hop a 250px path.
			var _sx = syst_tiles.spark_x;
			var _sy = syst_tiles.spark_y + 4;
			var _dp = syst_tiles.depth + 1;
			with (syst_tiles) {
				for (var _k = 0; _k < g.tiles.slots; _k++) {
					var _tk = g.tiles.tier[_k];
					if (_tk == 0) continue;
					bezier_bits(__slot_x(_k) + tw * .5, __slot_y(_k) + th * .5,
						1, tile_color(_tk), _sx, _sy, -1, 0, 6, 1.3, "tile", _dp);
				}
			}
		}
	}
}
