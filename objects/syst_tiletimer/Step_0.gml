// the time bank's speed: the tile sim rides the SAME paid multiplier
// every other sim system got this frame (timebank_spend set live_m -
// one payment covers the whole layer)
var _m = variable_global_exists("timebank") ? g.timebank.live_m : 1;
tiles_tick(_m);

// ---- THE PAYOUT, once a whole second at a time ----
// The tech demo published g.tiles.gps and let other systems read it as
// a bonus; in RX the table is an EARNER, so it pays through give_profit
// like everything else - one site, one lifetime total, one save mark.
//
// WHOLE SECONDS, and that is not fussiness. do_scale clamps a sub-1
// result up to arb(1), so paying a fraction of a second's income every
// frame would round a trickle up to a whole unit sixty times a second
// and mint profit out of nothing. Banking the seconds and paying when
// at least one has passed keeps the arithmetic honest at any rate.
pay_acc += (delta / 60) * _m;
if (pay_acc >= 1) {
	var _whole = floor(pay_acc);
	pay_acc -= _whole;
	if (g.tiles.gps >= arb(1)) give_profit(do_scale(g.tiles.gps, _whole));
}
