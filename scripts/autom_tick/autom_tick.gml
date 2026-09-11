/// @description autom_tick();
/// THE AUTOMATION RUNNER - one pulse a second, from syst_production's
/// heartbeat, so it runs in every room rather than only while the
/// automation screen is open.
///
/// ONE ATTEMPT PER SECOND, and the adaptive step size is what scales
/// throughput (Myriad's cadence). Never speed the clock up to buy more:
/// a faster pulse spends the same money in smaller, more expensive
/// pieces, because every dial curve accelerates.
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
	var _a = g.autom;
	_a.tic -= delta / 60;
	if (_a.tic > 0) return;
	_a.tic = 1;

	// ---- autobuy: the dials ----
	if (variable_global_exists("dial")) {
		var _dn = min(g.dial_total, array_length(_a.dial));
		for (var _i = 0; _i < _dn; _i++) {
			var _p = _a.dial[_i];
			if (!_p.on) { _p.st = 0; continue; }
			autom_piece(_p, _i);
		}
	}

	// ---- the upgrade table ----
	autom_upgrades();

	// ---- the tile table's upgrades ----
	autom_tiles();

	// ---- autorebirth: EVERY enabled condition must pass ----
	var _r = _a.reb;
	if (!(_r.t_on || _r.u_on || _r.g_on || _r.c_on || _r.p_on)) return;
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
		// a fresh run gets fresh ramps: the old q was a guess about a
		// wallet that no longer exists
		for (var _k = 0; _k < array_length(_a.dial); _k++) {
			_a.dial[_k].q = 1; _a.dial[_k].h = 0; _a.dial[_k].st = 0;
		}
	}
}
