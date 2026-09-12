/// @description tap_breakdown() - WHY A TAP PAYS WHAT IT PAYS, term by
/// term: the data behind the statistics screen's tapping page (his ask,
/// 2026-09-10: "the tapper stats need a breakdown as well").
///
/// dial_breakdown's sibling, with one honest difference. A dial's
/// output is a PRODUCT of factors, so its bar shares out logs. A tap is
/// a SUM first - levels + rebirth units + the fleet syphon - and only
/// then a product of the result-side multipliers (update_click's own
/// order, which is the authority; this mirrors it and CHECKS ITSELF
/// against the live g.click_gps). So the bar here shares out the sum
/// linearly - each term's fraction of the tap before the multipliers -
/// and the multipliers are listed after it as what they are: a x on
/// the whole. Crits are reported as the expectation they add and are
/// NOT in the chain, because g.click_gps is the pre-crit figure and
/// tap_fire rolls them per tap.
///
/// Returns { terms : [{name, note, val, share, col}],
///           mults : [{name, note, mult, col}],
///           base, crit_x, derived, live_lg, ok }
///   base     the additive sum (a packed arb) - the tap before the x's
///   crit_x   1 + rate x (mean multiplier - 1): what crits add on average
///   derived  log10 of the mirrored chain; live_lg of g.click_gps; ok if
///            they agree (they should - if not, update_click moved)
function tap_breakdown() {
	var _out = { terms : [], mults : [], base : 0, crit_x : 1,
	             derived : 0, live_lg : 0, ok : true };
	if (!variable_global_exists("click_gps")) return _out;
	if (!variable_global_exists("all_level")) return _out;

	// ---- the additive lane ----
	// 1. levels: 1 + the sum of every dial's level (DE's base)
	var _lv = arb(1 + g.all_level);
	array_push(_out.terms, {
		name : "dial levels", note : "1 + " + string(g.all_level) + " levels across the fleet",
		val : _lv, share : 0, col : c_gold,
	});
	// 2. rebirth units, added whole (DE's click_gps += units)
	rebirth_init();
	if (g.rebirth.units >= arb(1))
		array_push(_out.terms, {
			name : "rebirth units", note : "+" + crunch_arb(g.rebirth.units) + " units, added whole",
			val : g.rebirth.units, share : 0, col : c_hpurple,
		});
	// 3. the fleet syphon: tapsyphon of the fleet's PAID rate (fleet_total
	// - the tile table's boost included, as DE's pre_os_gps was)
	if (variable_global_exists("tapsyphon_pull") && g.tapsyphon_pull >= arb(1))
		array_push(_out.terms, {
			name : "fleet syphon",
			note : string_format(g.tapsyphon * 100, 1, (g.tapsyphon * 100 == floor(g.tapsyphon * 100)) ? 0 : 1)
				+ "% of " + crunch_arb(g.all_gps) + "/sec",
			val : g.tapsyphon_pull, share : 0, col : c_aqua,
		});

	// the sum, and each term's linear share of it - in log space, since
	// the arb library does not divide
	var _sum = 0;
	for (var _i = 0; _i < array_length(_out.terms); _i++)
		_sum = (_i == 0) ? _out.terms[_i].val : do_add(_sum, _out.terms[_i].val);
	_out.base = _sum;
	var _slg = (_sum >= arb(1)) ? arb_log10(_sum) : 0;
	for (var _i = 0; _i < array_length(_out.terms); _i++) {
		var _v = _out.terms[_i].val;
		_out.terms[_i].share = (_v >= arb(1)) ? clamp(power(10, arb_log10(_v) - _slg), 0, 1) : 0;
	}

	// ---- the multipliers, result-side, in update_click's order ----
	var _lg = _slg;
	var _ub = upgrade_bonus_live();
	if (_ub.tap_profit > 0) {
		var _m = 1 + _ub.tap_profit / 100;
		array_push(_out.mults, {
			name : "tap upgrades", note : "+" + string_format(_ub.tap_profit, 1, 1) + "% tap profit",
			mult : _m, col : c_sgreen,
		});
		_lg += log10(_m);
	}
	var _oc = overcharge_multi();
	if (_oc > 1) {
		array_push(_out.mults, {
			name : "overcharge",
			note : "lv " + string(g.overcharge_lv) + " of " + string(overcharge_maxlv()) + " - drains when you stop",
			mult : _oc, col : vis_tier_color(g.overcharge_lv - 1),
		});
		_lg += log10(_oc);
	}

	// ---- the self-check ----
	_out.derived = _lg;
	_out.live_lg = (g.click_gps >= arb(1)) ? arb_log10(g.click_gps) : 0;
	_out.ok = (abs(_out.derived - _out.live_lg) < .12) || (_out.live_lg <= 0);

	// ---- crits, as the expectation they add (obj_clicker's readout law) ----
	var _rt = clamp((g.click_crit + _ub.crit_rate) * luck_mod() / 100, 0, 1);
	var _mn = (g.click_critx_min + g.click_critx_max) * .5 + _ub.crit_multi;
	_out.crit_x = 1 + _rt * max(0, _mn - 1);

	return _out;
}
