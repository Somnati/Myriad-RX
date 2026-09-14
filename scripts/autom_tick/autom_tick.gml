/// @description autom_tick();
/// THE AUTOMATION RUNNER - one pulse a second, from syst_production's
/// heartbeat, so it runs in every room rather than only while the
/// automation screen is open.
///
/// EVERY AUTOBUY ON ITS OWN CLOCK (his ask, 2026-09-11: "a timer slider
/// for each autobuy"): a row attempts once per its t seconds and buys
/// MAX within its cap. A faster clock costs RAM (ram_cost "timer") and
/// over the budget every clock runs at ram_throttle - the countdown
/// counts throttled seconds. The dials share ONE row (the master,
/// 2026-09-14 - autom_strategy walks the filter in the target's order);
/// the autorebirth rails and the table's roll/sell keep the one-second
/// base pulse.
///
/// AUTOREBIRTH FIRES THROUGH rebirth_calc AND rebirth_do, the same two
/// scripts the button uses. That is not tidiness - it is what makes the
/// timeclamp and the press cooldown bind automation exactly as they
/// bind a person. An automation path with its own copy of the rules is
/// an automation path that eventually dodges one.
///
/// ONLINE ONLY, deliberately: offline_replay neither autobuys nor
/// autorebirths. Buy events inside a bulk replay are a real design fork
/// (what did the wallet look like halfway through?) and nothing in the
/// room's UI promises otherwise.
function autom_tick() {
	autom_init();
	var _a  = g.autom;
	var _dt = delta / 60;
	var _th = ram_throttle();   // one read a step; every clock below rides it

	// ---- autobuy: the dials ----
	// THE RAIL first (his list): under the profit floor every dial
	// autobuy holds its fire - the clocks keep running, nothing buys
	var _d_rail = true;
	if (_a.rails.d_on) {
		var _plg = (g.profit >= arb(1)) ? arb_log10(g.profit) : 0;
		_d_rail = (_plg >= _a.rails.d_oom);
	}
	if (variable_global_exists("dial")) {
		var _dn = min(g.dial_total, array_length(_a.dial));
		// THE MASTER ROW: one clock, one cap, the filter's dials in the
		// target's order (autom_strategy)
		var _s = _a.dial_all;
		if (!_s.on) { _s.st = 0; _s.tic = 0; for (var _i = 0; _i < _dn; _i++) _a.dial[_i].st = 0; }
		else {
			_s.tic -= _dt * _th;
			if (_s.tic <= 0) {
				_s.tic = max(RAM_TIMER_FLOOR, _s.t);
				if (!_d_rail) _s.st = 1;
				else autom_strategy(_s, _dn);
			}
		}
	}

	// ---- THE AUTOTAPPER: rate taps a second, banked fractionally and
	// paid in whole taps (tap_fire's batch law), at the throttle. Not
	// your taps (_stat false); the ceremony plays in the money room ----
	// ...AND IT SCALES WITH EVERY TPS BONUS (his ask): the slider is a
	// base rate, multiplied by whatever tap_rate() multiplies the hold's
	// base by - upgrades today, abilities and gear tomorrow - so the
	// autotapper climbs into the thousands with them exactly as DE's did
	var _tp = _a.tap;
	if (_tp.on) {
		var _tps = _tp.rate * (tap_rate() / TAP_HOLD_BASE) * (1 + sprite_staff("tapper"));   // the staff on it
		_tp.acc += _tps * _dt * _th;
		var _nt = floor(_tp.acc);
		if (_nt >= 1) {
			_tp.acc -= _nt;
			tap_fire(_nt, room_width * .5, room_height / 2.5, true, true, false);
		}
	} else _tp.acc = 0;

	// ---- the upgrade table: buy on its clock, roll/sell on the pulse ----
	var _u = _a.upg;
	var _buy_due = false;
	if (_u.buy) {
		_u.tic -= _dt * _th;
		if (_u.tic <= 0) { _u.tic = max(RAM_TIMER_FLOOR, _u.t); _buy_due = true; }
	} else _u.tic = 0;

	// ---- the tile table's upgrades, each on its own clock ----
	autom_tiles(_dt * _th);

	// ---- the base pulse ----
	_a.tic -= _dt;
	if (_a.tic > 0) { if (_buy_due) autom_upgrades(true, false); return; }
	_a.tic = 1;
	autom_upgrades(_buy_due, true);

	// ---- autorebirth: the master switch, at least one rail armed, and
	// ---- EVERY armed rail must pass ----
	var _r = _a.reb;
	if (!_r.on) return;
	if (!(_r.t_on || _r.u_on || _r.g_on || _r.c_on || _r.p_on)) return;
	// NEVER WHILE THE REBIRTH PAGE IS OPEN (his ask): you are setting
	// the rails, not asking for the press
	if (instance_exists(syst_automation_panel) && syst_automation_panel.tab == AT_REB) return;
	var _c = rebirth_calc();
	if (!_c.can || _c.cool > 0) return;   // the lawyer's laws hold for auto

	if (_r.t_on && _c.run_s < _r.t_min * 60) return;
	if (_r.u_on && !(_c.units >= arb(_r.u_min))) return;
	if (_r.c_on && _c.tc < 1) return;     // wait out the timeclamp penalty
	if (_r.p_on) {
		var _lg = (g.profit >= arb(1)) ? arb_log10(g.profit) : 0;
		if (_lg < _r.p_oom) return;
	}
	if (_r.g_on) {
		var _held = g.rebirth.units;
		// a zero bank passes any percentage of nothing; a real one gates
		// on the arb compare (do_scale is fraction-safe)
		if (_held >= arb(1))
			if (!(_c.units >= do_scale(_held, _r.g_pct / 100))) return;
	}

	if (rebirth_do()) {
		// Myriad's auto ceremony: announce and STAY - every view derives
		// live, so there is nothing a room change would refresh
		play_sound_ext(snd_rebirthcollect, .9, 1.1, .5, 1);
		assign_banner("auto rebirth  units +"
			+ crunch_arb(g.rebirth.prev_units), c_hred, c_black);
		autom_log("auto rebirth  +" + crunch_arb(g.rebirth.prev_units) + " units", c_hred, "reb");
		// a fresh run: the chips' verdicts clear
		for (var _k = 0; _k < array_length(_a.dial); _k++) _a.dial[_k].st = 0;
	}
}
