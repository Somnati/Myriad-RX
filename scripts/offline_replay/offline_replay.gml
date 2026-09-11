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

	// ⚖️ THE BATTERY (his design, 2026-09-11): the machines run for
	// min(absence, charge / draw) seconds and then STOP - a hard stop,
	// his call - so a long absence cannot compound the table past what
	// the charge allows. The time bank above banked the RAW absence (the
	// hybrid's intent); only the replay's budget shrinks. Nothing is
	// forked: the same prod_dials and tiles_fastforward run, on fewer
	// seconds, at the battery panel's offline rates (autom_rate reads
	// g.offline_replaying).
	battery_init();
	// THE OPTIMISER (his idea, 2026-09-11 - read battery_optimise): with
	// the ability on, the replay runs at the rates that make the most
	// of the charge over exactly this absence, not the ones you left.
	// The player's own rates are never written; this is a per-replay
	// override autom_rate and battery_draw read
	var _opt = undefined;
	if (variable_global_exists("bat_opt") && g.bat_opt) _opt = battery_optimise(_secs);
	g.battery.opt_rate = _opt;
	var _draw = battery_draw();
	var _cov  = (_draw > 0) ? min(_secs, g.battery.charge / _draw) : _secs;
	g.battery.charge = max(0, g.battery.charge - _cov * _draw);
	g.battery.dry_at = (_cov < _secs - 1) ? _cov : 0;
	g.offline_replaying = true;

	var _before = g.profit;
	var _rate   = g.all_gps;      // the rate the absence ran at
	// ⚖️ INTO THE PILE, NOT THE POCKET (DE's offline_gold, his ask
	// 2026-09-10): everything the replay pays lands in g.offline_pool -
	// give_profit reads this flag - and waits for the button in the
	// money room. The flag is lowered before anything else runs, so a
	// live payout can never be caught by it.
	var _pool0 = g.offline_pool;

	// THE TILE TABLE FIRST, replayed exactly: tiles_fastforward walks
	// the absence as a histogram rather than a loop, so a month away
	// costs the same as a minute. Behind TILES_LIVE while the table is
	// being finalised - a bug in the tile replay must not be able to
	// break a LOAD, which is the one path a player cannot route around.
	//
	// ⚖️ AND THE DIALS PAY AT THE MEAN OF THE BOARD, NOT ITS START (the
	// offline audit, 2026-09-10). The table multiplies every dial payout
	// (tile_dial_boost), and online that boost climbs every second as
	// the board merges upward. The replay paid the whole absence at the
	// boost you LEFT with - the dials ran first and the table after -
	// which under-paid a night away by whatever the board did in it.
	// Now the table goes first, and the dials pay at the LOGARITHMIC
	// MEAN of the boost you left at and the boost you returned to: for
	// a quantity that grows geometrically that is the exact time
	// average, and (B1 - B0) / ln(B1 / B0) is one line in log space
	// whatever size the arbs are. Offline == online to within the
	// board's own replay, which was already the honest half.
	var _lg0 = arb_log10(tile_dial_boost());
	if (TILES_LIVE)
		if (variable_global_exists("tiles")) tiles_fastforward(_cov);
	var _lg1 = arb_log10(tile_dial_boost());
	var _lgm = max(_lg0, _lg1);
	if (abs(_lg1 - _lg0) > .0001) {
		var _hi = max(_lg0, _lg1), _lo = min(_lg0, _lg1);
		_lgm = _hi + log10(1 - power(10, _lo - _hi)) - log10((_hi - _lo) * ln(10));
	}
	g.tile_boost_override = log_to_arb(max(0, _lgm));

	g.offline_pooling = true;
	prod_dials(_cov);
	g.offline_pooling = false;
	g.offline_replaying = false;
	g.battery.opt_rate = undefined;
	g.tile_boost_override = undefined;
	credit_tick(_secs);   // the dropper's pool refills over the absence too (wall clock, not the battery's)

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
		banked : _banked, bank_full : g.timebank.last_full, shown : false,
		bat_ran : _cov, bat_dry : (_cov < _secs - 1),
		bat_opt : (_opt == undefined) ? 0 : _opt.s };
	show("offline > away " + crunch_time_long(_secs * 60)
		+ ", earned +" + ((_gain > 0) ? crunch_arb(_gain) : "0"));
}
