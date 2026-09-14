/// @description update_dial(i) - re-derive ONE dial's live numbers from
/// its level (Myriad DE's update_auto). Call it after anything that
/// changes a dial; nothing here is ever stored in a save.
/// THE SHAPE, in DE's own order:
///   1. base output from the curve            dial_gps(tier, level)
///   2. the LEVEL RAMP md = clamp(level/50, .1, 1) - a dial under
///      level 50 runs at a fraction of its output and reaches full
///      strength at 50. The early-game warm-up.
///   3. the timer: autoeff .3 stretches every cycle 30% longer than
///      its roster time (DE's b_autoeff; its autostarter abilities buy
///      that back later). cps = cycles per second.
///   4. per-cycle pay = base x cycle-seconds x ramp; per-second =
///      per-cycle x cps.
/// NOTE THE CANCELLATION: per-second output is almost independent of
/// cycle length - a slow dial simply banks the same income in bigger,
/// rarer lumps (the 30% autoeff stretch is the only real cost). Cycle
/// length is PACING, not power; power comes from the tier head start.
/// The multiplier chain DE runs between these steps (abilities, gear,
/// refinery, milestones, tiles, rebirth) has no layer yet - each one
/// re-enters HERE, result-side, as it gets rebuilt.
function update_dial(_i) {
	var _d   = g.dial[_i];
	var _cfg = dial_config(_i);

	_d.b_gps = dial_gps(_i, _d.level);
	if (_d.level <= 0) {
		_d.gps = 0; _d.gpc = 0; _d.cps = 0; _d.cycle_t = _cfg.cycle;
		return;
	}

	// the milestones this level has earned (derived, never stored)
	var _ms = milestone_get(_i, _d.level);

	// the timer chain (autoeff comes from the config - one source);
	// a SPEED milestone divides the stretched cycle (DE's seat:
	// timer_ /= p_ms_speed)
	_d.cycle_t = _cfg.cycle * (1 + _cfg.autoeff) / max(1, _ms.speed);
	_d.cps     = 1 / _d.cycle_t;

	// the level ramp, then the two payout readings
	var _md = clamp(_d.level / 50, .1, 1);
	_d.gpc = do_ceil(do_scale(_d.b_gps, max(1, _cfg.cycle * _md)));

	// a PROFIT milestone multiplies the per-cycle pay (DE's seat:
	// give x p_ms_profit)
	if (_ms.profit > 1) _d.gpc = do_scale(_d.gpc, _ms.profit);

	// ---- UPGRADES, RESULT-SIDE ----
	// dial profit multiplies the per-cycle pay; dial speed divides the
	// cycle, which is the same seat a SPEED milestone uses, so the two
	// stack the way the player expects rather than one overriding the
	// other.
	var _ub = upgrade_bonus_live();
	if (_ub.dial_profit > 0) _d.gpc = do_scale(_d.gpc, 1 + _ub.dial_profit / 100);
	if (_ub.dial_speed > 0) {
		_d.cycle_t /= (1 + _ub.dial_speed / 100);
		_d.cps = 1 / _d.cycle_t;
	}

	// THE REBIRTH BOOST (DE's update_auto: give x total_rebirth_boost) -
	// 1 + units, on the per-cycle pay, dials only (the tap takes the
	// units flat instead, see update_click)
	var _rb = rebirth_boost();
	if (_rb > arb(1)) _d.gpc = do_multi(_d.gpc, _rb);

	// THE CHEAT SHOP (2026-09-13): dial profit and dial speed, the player's
	// own allocation (cheat_rate is 1 until the shop unfolds). Result-side,
	// after everything else, the way the upgrade seats above are
	var _cp = cheat_rate("dprofit");
	if (_cp != 1) _d.gpc = do_scale(_d.gpc, _cp);
	var _cs = cheat_rate("dspeed");
	if (_cs != 1) { _d.cycle_t /= _cs; _d.cps = 1 / _d.cycle_t; }

	_d.gps = do_scale(_d.gpc, _d.cps);
}
