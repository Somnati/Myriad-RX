/// @description offline_replay(seconds) - THE OFFLINE CALCULATOR
/// (Myriad DE's calculate_offline_gain, rebuilt simple).
/// DE'S LAWS, KEPT: every dial earns at 100% of its online rate for
/// the whole absence - no cap on time away, no efficiency fraction, no
/// minimum; whole cycles are paid and the remainder stays in the cycle
/// so nothing is lost or double-paid across the boundary; a dial with
/// its autonomy off banks ONE cycle; the tapper earns nothing while
/// you are gone (DE's loop never visits the tapper's index).
/// DE had to simulate that in chunks across a loading room because its
/// tick was per-frame. RX's prod_dials takes a SECONDS BUDGET and pays
/// whole cycles in bulk - one do_scale per dial - so the same result
/// is ONE call to the SAME code. Offline is online; there is no second
/// formula to drift.
/// Profit lands immediately (DE banked it behind a tap-to-claim coin
/// button; the simple version pays on arrival). The report waits in
/// g.offline_report for syst_offline to announce on the next visit to
/// the money room, DE's obj_idletime style.
/// Called from two places, both in game/offline: syst_handle_save
/// after a LOAD (the closed-app absence, measured from the save's
/// datetime stamp) and syst_offline's Step (a SUSPEND: the phone
/// backgrounded the app, the laptop slept - GM stopped stepping while
/// the wall clock ran on).
function offline_replay(_secs) {
	if (_secs < 1) return;

	// THE AWAY CLOCK. Counted here because this is the ONE place an
	// absence is measured - a suspend (syst_offline's Step) and a
	// closed app (syst_handle_save after a load) both arrive through
	// this call, so neither can be missed or counted twice. It is a
	// fact about the wall clock, so it is banked BEFORE the guard
	// below: the time passed whether or not there was anything to
	// replay. g.time_played_active only ticks while the game is
	// running, so the two never overlap.
	g.time_played_offline += _secs;
	save_mark_dirty();

	// THE TIME BANK, on top (the hybrid - see timebank_init). The
	// absence is about to be replayed as production exactly as it always
	// was; this banks a slice of it as spendable speed as well. It
	// deliberately double-counts, and it is safe because the slice is
	// always under an hour per hour.
	var _banked = timebank_add(_secs);

	if (!variable_global_exists("dial")) return;

	var _before = g.profit;
	var _rate   = g.all_gps;      // the rate the absence ran at
	// ⚖️ INTO THE PILE, NOT THE POCKET (DE's offline_gold, his ask
	// 2026-09-10): everything the replay pays lands in g.offline_pool -
	// give_profit reads this flag - and waits for the button in the
	// money room. The flag is lowered before anything else runs, so a
	// live payout can never be caught by it.
	var _pool0 = g.offline_pool;
	g.offline_pooling = true;
	prod_dials(_secs);
	g.offline_pooling = false;
	credit_tick(_secs);   // the dropper's pool refills over the absence too

	// THE TILE TABLE, replayed exactly: tiles_fastforward walks the
	// absence as a histogram rather than a loop, so a month away costs
	// the same as a minute. Behind TILES_LIVE while the table is being
	// finalised - a bug in the tile replay must not be able to break a
	// LOAD, which is the one path a player cannot route around.
	if (TILES_LIVE)
		if (variable_global_exists("tiles")) tiles_fastforward(_secs);

	// the paid flags are for the drawer's motes; nothing flies for a
	// bulk absence (thirteen bursts on the first frame would be noise)
	for (var _i = 0; _i < g.dial_total; _i++) g.dial[_i].paid = false;

	// what the absence earned is what the POOL grew by; the pile itself
	// did not move, so nothing is held back and the profit graph draws
	// a flat line across the absence (it steps up at the tap)
	var _gain = (g.offline_pool > _pool0) ? do_subtract(g.offline_pool, _pool0) : 0;
	// THE GRAPHS GET THE ABSENCE TOO. Everything it needs was measured
	// right here and nowhere else: how long, what the pile was, what the
	// replay paid, and the rate it paid at.
	stats_hist_offline(_secs, _before, 0, _rate);

	g.offline_report = { secs : _secs, gain : _gain, rate : _rate,
		banked : _banked, bank_full : g.timebank.last_full, shown : false };
	show("offline > away " + crunch_time_long(_secs * 60)
		+ ", earned +" + ((_gain > 0) ? crunch_arb(_gain) : "0"));
}
