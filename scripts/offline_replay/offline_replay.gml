/// @description offline_replay(seconds, [src]) - THE OFFLINE CALCULATOR
/// @param [src]  what triggered it, for the OFFLINE LOG ("boot return"
///               / "suspended" / "sim 1h") - see offlog_init
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
function offline_replay(_secs, _src = "boot return") {
	if (_secs < 1) return;
	// THE LOG ENTRY (offlog_init): every number below is a snapshot of
	// what the systems actually saw, filed at the end through
	// offlog_record - syst_offlog reads it back, plain or in debug
	var _t0 = get_timer();
	var _L = { at : current_time, when : date_datetime_string(date_current_datetime()),
	           src : _src, secs : _secs, cov : _secs, ms : 0, mode : "" };

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
	// A LONG ABSENCE leaves a scratch ticket on the desk (2026-09-13) - a
	// real one, not the bench's simulated hours
	if (_secs >= ticket_config().away_secs && string_copy(_src, 1, 3) != "sim") ticket_grant("away");
	// OFFLINE UPGRADES (DE's calculate_offline_gain): an absence past 1 /
	// 5 / 10 / 15 / 20 / 30 minutes owes that many offers, spawned on
	// return one a frame while the table has room (upgrade_meter_tick's
	// force path). Only while none are already owed, DE's guard
	if (variable_global_exists("upg") && string_copy(_src, 1, 3) != "sim" && g.upg.meter.uoff <= 0) {
		var _uo = 0;
		if (_secs > 60)   _uo++;
		if (_secs > 300)  _uo++;
		if (_secs > 600)  _uo++;
		if (_secs > 900)  _uo++;
		if (_secs > 1200) _uo++;
		if (_secs > 1800) _uo++;
		g.upg.meter.uoff = _uo;
	}

	// THE TIME BANK, on top (the hybrid - see timebank_init). The
	// absence is about to be replayed as production exactly as it always
	// was; this banks a slice of it as spendable speed as well. It
	// deliberately double-counts, and it is safe because the slice is
	// always under an hour per hour.
	timebank_init();
	var _tb0 = g.timebank.bank;
	var _banked = timebank_add(_secs);
	_L.tb = { bank0 : _tb0, bank1 : g.timebank.bank, add : _banked, full : g.timebank.last_full,
	          mph : timebank_rate() * 60, cap : timebank_cap() };

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
	// THE AWAY MODE (his list, 2026-09-12): a saved setup flagged for
	// offline is applied around the replay - the machines it switches
	// off draw nothing, the automerger it switches on runs - and the
	// setup you left is put back after. autom_pack / unpack is the one
	// road in and out, so nothing here can drift from a load
	var _online = undefined;
	autom_init();
	for (var _mi = 0; _mi < array_length(g.autom.presets); _mi++)
		if (g.autom.presets[_mi].offline) { _L.mode = g.autom.presets[_mi].name; _online = autom_pack(); autom_unpack(g.autom.presets[_mi].pack); break; }
	// THE OPTIMISER (his idea, 2026-09-11 - read battery_optimise): with
	// the ability on, the replay runs at the rates that make the most
	// of the charge over exactly this absence, not the ones you left.
	// The player's own rates are never written; this is a per-replay
	// override autom_rate and battery_draw read
	var _opt = undefined;
	if (variable_global_exists("bat_opt") && g.bat_opt) _opt = battery_optimise(_secs);
	g.battery.opt_rate = _opt;
	var _rt = g.battery[$ "opt_rate"] ?? g.battery.rate;   // the rates the absence ran at (for the log)
	var _draw = battery_draw();
	var _ch0  = g.battery.charge;
	var _cov  = (_draw > 0) ? min(_secs, g.battery.charge / _draw) : _secs;
	g.battery.charge = max(0, g.battery.charge - _cov * _draw);
	g.battery.dry_at = (_cov < _secs - 1) ? _cov : 0;
	_L.cov = _cov;
	_L.bat = { ch0 : _ch0, ch1 : g.battery.charge, cap : battery_cap(), draw : _draw,
	           dry : (_cov < _secs - 1), opt : (_opt == undefined) ? 0 : _opt.s,
	           run : _rt.run, fab : _rt.fab, merge : _rt.merge,
	           run_on : g.autom.run.on, fab_on : g.autom.fab.on,
	           merge_on : (variable_global_exists("tiles") && g.tiles.automerge) };
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
	// THE BOARD NEVER TOUCHES THE DIALS (his law, restated 2026-09-18:
	// "tiles' additive value isn't supposed to contribute to dial output").
	// Since the 09-13 rebalance tile_dial_boost is the flux ladder's PROFIT
	// RUNG alone - (1 + TILE_PROFIT_STEP)^rung - and a rung is bought by
	// hand, never by the replay, so the dials' boost is one constant across
	// the absence. (The logarithmic-mean-of-the-board machinery that stood
	// here was the pre-rebalance law, a no-op since; gone - q231)
	var _ts = undefined;   // the table before the replay (the log's tiles block)
	// ...AND NOT BEFORE THE TABLE IS UNLOCKED (his report, 2026-09-17:
	// tiles had run offline before he ever opened them) - tiles_tick
	// keeps the same gate online
	var _tiles_on = TILES_LIVE && variable_global_exists("tiles") && unfold_has("tiles");
	if (_tiles_on)
		_ts = { hi0 : g.tiles.highest, sh0 : g.tiles.shards, gps0 : g.tiles.gps,
		        made0 : g.tiles.made, mg0 : g.tiles.merges, bailed : false,
		        merge_on : g.tiles.automerge };   // (the log hides the merge row while it is off)
	if (_tiles_on)
		if (variable_global_exists("tiles")) {
			var _ff = tiles_fastforward(_cov);
			if (is_struct(_ff) && !is_undefined(_ts)) _ts.bailed = _ff[$ "bailed"] ?? false;
		}
	if (!is_undefined(_ts)) {
		_ts.hi1 = g.tiles.highest; _ts.sh1 = g.tiles.shards; _ts.gps1 = g.tiles.gps;
		_ts.made1 = g.tiles.made; _ts.mg1 = g.tiles.merges;
		_ts.lg = arb_log10(tile_dial_boost());   // (the rung's boost the dials paid at - constant; the log's debug row)
	}
	_L.tiles = _ts;

	g.offline_pooling = true;
	prod_dials(_cov);
	// the dials' payouts, read for the log before the flags clear below
	var _dl = [];
	for (var _i = 0; _i < g.dial_total; _i++) {
		var _d = g.dial[_i];
		if (_d.paid) array_push(_dl, { i : _i, lv : _d.level, amt : _d.paid_amt });
	}
	_L.dials = { n : g.dial_total, paid : _dl };
	// THE SPRITES, on their own law (attention decay, off the battery -
	// sprites_offline), into the pool with everything else
	sprites_offline(_secs);
	var _spr_taps = 0;
	var _sl = [];
	for (var _si = 0; _si < array_length(g.sprites); _si++) {
		var _s = g.sprites[_si];
		_spr_taps += _s.away;
		array_push(_sl, { name : _s[$ "name"] ?? "sprite", rar : _s[$ "rar"] ?? 0, job : _s[$ "job"] ?? "tap",
		                  trip : _s[$ "trip"] ?? false, taps : _s.away, asleep : _s.asleep });
	}
	_L.sprites = { taps : _spr_taps, list : _sl, work : SPRITE_ATTN * ln(1 + _secs / SPRITE_ATTN) };
	g.offline_pooling = false;
	g.offline_replaying = false;
	g.battery.opt_rate = undefined;
	if (!is_undefined(_online)) autom_unpack(_online);   // the away mode comes off
	// the wall-clock systems, with a before/after for the log
	credits_init(); ccore_init(); exped_init();
	var _cp0 = g.credit_pool;
	var _cc0 = { st : g.ccore.st, xp : g.ccore.xp };
	// every trip out: its id -> how long its diary was (the new lines are the log's)
	var _ex0 = { n : array_length(g.exped.trips), logn : {} };
	for (var _ti = 0; _ti < array_length(g.exped.trips); _ti++) {
		var _tr0 = g.exped.trips[_ti];
		_ex0.logn[$ string(_tr0.id)] = array_length(_tr0.log);
	}
	credit_tick(_secs);   // the dropper's pool refills over the absence too (wall clock, not the battery's)
	ccore_tick(_secs);    // ...and the credit core's well fills (to its cap) on the same clock
	exped_tick(_secs);    // ...and an expedition walks its rooms (the fights resolve as they come)
	moods_tick(_secs);    // ...and the crew rests over the absence (q282; it ticked on active play alone - a sprite came home tired and stayed so until two hours of play had passed)
	_L.credits = { pool0 : _cp0, pool1 : g.credit_pool, cap : g.credit_cap,
	               lv : g.ccore.lv, st0 : _cc0.st, st1 : g.ccore.st, xp0 : _cc0.xp, xp1 : g.ccore.xp,
	               ccap : (g.ccore.lv > 0) ? ccore_values().cap : 0 };
	var _ex1 = exped_away_after(_ex0.logn);   // (the section as one function - the owed walk writes it again; q230)
	// THE OWED HOURS (bug hunt 5 / q230): the chart builds under play only once a crew is out (syst_handle_save), so this
	// tick OWED the absence; the section above says so, and exped_owed_report rewrites it - this same entry, by
	// reference - when the last owed slice has walked
	if ((g[$ "exped_owed"] ?? 0) > 0) g.exped_owed_rep = { L : _L, logn : _ex0.logn };
	_L.exped = { before : _ex0, after : _ex1 };

	// the paid flags are for the drawer's motes; nothing flies for a
	// bulk absence (thirteen bursts on the first frame would be noise)
	for (var _i = 0; _i < g.dial_total; _i++) g.dial[_i].paid = false;

	// what the absence earned is what the POOL grew by; the pile itself
	// did not move, so nothing is held back and the profit graph draws
	// a flat line across the absence (it steps up at the tap)
	var _gain = (g.offline_pool > _pool0) ? do_subtract(g.offline_pool, _pool0) : 0;
	_L.profit = { gain : _gain, rate : _rate, before : _before, pool0 : _pool0, pool1 : g.offline_pool };
	// THE GRAPHS GET THE ABSENCE TOO. Everything it needs was measured
	// right here and nowhere else: how long, what the pile was, what the
	// replay paid, and the rate it paid at.
	stats_hist_offline(_secs, _before, 0, _rate);

	g.offline_report = { secs : _secs, gain : _gain, rate : _rate,
		banked : _banked, bank_full : g.timebank.last_full, shown : false,
		bat_ran : _cov, bat_dry : (_cov < _secs - 1),
		bat_pct : floor(100 * g.battery.charge / max(1, battery_cap())), // what is LEFT (his ask, 2026-09-11)
		bat_opt : (_opt == undefined) ? 0 : _opt.s,
		sprite_taps : _spr_taps, sprite_n : array_length(g.sprites),
		ccore_full : (g.ccore.st == 2) };
	_L.ms = (get_timer() - _t0) / 1000;
	offlog_record(_L);
	show("offline > away " + crunch_time_long(_secs * 60)
		+ ", earned +" + ((_gain > 0) ? crunch_arb(_gain) : "0"));
}
