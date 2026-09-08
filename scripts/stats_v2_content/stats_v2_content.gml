/// @description stats_v2_content() - THE list, declared as calls
/// (adding a stat is one line, and lines can appear conditionally so
/// the list stays alive). runs in syst_statistics_v2's scope every
/// rebuild. widgets are lazily spawned controller-side and
/// re-registered each pass.
/// NOTE: bodies run even when their folder is CLOSED (favorites/
/// search/dump need the whole tree) - keep per-line work trivial.
/// MYRIAD RX (fresh foundation, 2026-08-14): engine tree only. Every
/// DE system rebuilt onto RX adds its folder here as it lands (the
/// techdemo's stats_v2_content is the shape reference for widgets,
/// sparks and session-delta guards - arb deltas must guard the
/// subtract, the library can't say negative).
function stats_v2_content() {

	// session view: the "values" cycle in options flips this - deltas
	// against the boot/load snapshot instead of lifetime totals
	var _sess = (variable_global_exists("stats_mode") && g.stats_mode == 1);
	var _sc = c_seagreen; // session values read green, prefixed +

	// ---- general ----
	if (stats_v2_folder("general", c_sgreen)) {
		// TWO CLOCKS (his ask): what you played, and that plus the time
		// the save spent away. They never overlap, so the second is
		// simply their sum - DE's single total_seconds_played figure.
		if (variable_global_exists("time_played_active")) {
			var _act = g.time_played_active;
			var _off = variable_global_exists("time_played_offline")
				? g.time_played_offline : 0;
			if (_sess) {
				_act = max(0, _act - g.stats_base.playtime);
				_off = max(0, _off - (g.stats_base[$ "playtime_off"] ?? 0));
			}
			stats_v2_line("time played", crunch_time_long(_act * 60), -1,
				_sess ? _sc : -1);
			stats_v2_line("total time", crunch_time_long((_act + _off) * 60), -1,
				_sess ? _sc : -1);
		}
		if (variable_global_exists("profile_name"))
			stats_v2_line("profile", g.profile_name[g.profile], -1,
				g.profile_color[g.profile]);
	}
	stats_v2_folder_end();

	// ---- tapping ----
	if (variable_global_exists("total_taps"))
	if (stats_v2_folder("tapping", c_gold)) {
		var _tp = g.total_taps;
		var _cr = variable_global_exists("total_crits") ? g.total_crits : 0;
		if (_sess) {
			_tp = max(0, _tp - (g.stats_base[$ "taps"]  ?? 0));
			_cr = max(0, _cr - (g.stats_base[$ "crits"] ?? 0));
		}
		stats_v2_line("taps", string(_tp), -1, _sess ? _sc : -1);
		stats_v2_line("critical taps", string(_cr), -1,
			_sess ? _sc : ((_cr > 0) ? c_aqua : -1));
		// the OBSERVED rate, not the configured one - over enough taps
		// the two converge, and watching them do it is the interesting
		// part. Below a hundred taps the sample says nothing, so it
		// says so rather than printing a number that swings from 0% to
		// 12% and back.
		stats_v2_line("crit rate", (_tp >= 100)
			? string_format(100 * _cr / _tp, 1, 2) + "%"
			: "-", -1, c_gray);
		if (variable_global_exists("click_crit"))
			stats_v2_line("crit chance", string(g.click_crit) + "%", -1, c_gray);
		if (variable_global_exists("click_critx_min"))
			stats_v2_line("crit payout", "x" + string_format(g.click_critx_min, 1, 1)
				+ " - x" + string_format(g.click_critx_max, 1, 1), -1, c_gray);
		if (variable_global_exists("click_gps"))
			stats_v2_line("per tap", crunch_arb(g.click_gps), -1, g.profit_color);
	}
	stats_v2_folder_end();

	// ---- history ----
	// The spark rows. They read g.stats_hist, filled once a second by
	// stats_hist_tick off the production heartbeat, so a graph is
	// always the last two minutes and always of the run you are in.
	// Session view changes nothing here: a history IS a session view.
	// LIFETIME, not session (his call): the buffer decimates itself so
	// the window covers the whole account, and it is saved. The session
	// view deliberately changes nothing here - a lifetime graph that
	// reset when you asked for a session view would be answering a
	// different question than the one on the label.
	if (variable_global_exists("stats_hist"))
	if (stats_v2_folder("history", c_steelblue)) {
		stats_v2_spark("profit held",  "h_profit", c_sblue,  4);
		stats_v2_spark("rebirth units", "h_units", c_hred,   4);
		stats_v2_spark("profit / sec", "h_ps",     c_sgreen, 4);
	}
	stats_v2_folder_end();

	// ---- upgrades ----
	if (variable_global_exists("upg"))
	if (stats_v2_folder("upgrades", c_lavender)) {
		var _ub = upgrade_bonus();
		var _held = 0;
		for (var _i = 0; _i < upgrade_slots(); _i++)
			if (is_struct(g.upg.slot[_i]) && g.upg.slot[_i].tier > 0) _held++;
		stats_v2_line("slots", string(_held) + " / " + string(upgrade_slots()));
		stats_v2_line("bought", string(g.upg.total));
		stats_v2_line("rolled", string(g.upg.rolls));
		stats_v2_line("roll price", string(upgrade_roll_cost()) + " credits",
			-1, c_lavender, "what one roll into an empty slot costs. it "
			+ "rides the same drift the buy prices do.");
		stats_v2_line("price drift",
			"x" + string_format(upgrade_inflation(), 1, 2), -1, -1,
			"every upgrade ever bought makes the next one dearer - three "
			+ "percent per hundred, up to three times. sell prices are "
			+ "quoted off the original base and never see it.");
		// what the whole table would fetch, which is the one number the
		// sell mode cannot show you: it is a per-row button
		var _sv = 0;
		for (var _i = 0; _i < upgrade_slots(); _i++)
			if (is_struct(g.upg.slot[_i])) _sv += upgrade_sell_value(_i);
		stats_v2_line("table value", string(_sv) + " credits", -1,
			(_sv > 0) ? c_lavender : c_gray,
			"selling every slot right now would pay this. it counts the "
			+ "stake on each roll plus " + string(round(UPG_SELL_BACK * 100))
			+ "% of every tier bought into it.");
		stats_v2_line();
		// the derived totals, which is the only place they exist
		stats_v2_line("tap profit",    "+" + string_format(_ub.tap_profit, 1, 1) + "%",
			-1, (_ub.tap_profit > 0) ? c_gold : c_gray);
		stats_v2_line("crit chance",   "+" + string_format(_ub.crit_rate, 1, 1) + "%",
			-1, (_ub.crit_rate > 0) ? c_horange : c_gray);
		stats_v2_line("crit payout",   "+" + string_format(_ub.crit_multi, 1, 2) + "x",
			-1, (_ub.crit_multi > 0) ? c_horange : c_gray);
		stats_v2_line("dial profit",   "+" + string_format(_ub.dial_profit, 1, 1) + "%",
			-1, (_ub.dial_profit > 0) ? c_sgreen : c_gray);
		stats_v2_line("dial speed",    "+" + string_format(_ub.dial_speed, 1, 1) + "%",
			-1, (_ub.dial_speed > 0) ? c_sblue : c_gray);
		stats_v2_line("dial discount", "-" + string_format(_ub.dial_cost, 1, 1) + "%",
			-1, (_ub.dial_cost > 0) ? c_steelblue : c_gray);
		stats_v2_line("credit refill", "+" + string_format(_ub.credit_rate, 1, 1) + "%",
			-1, (_ub.credit_rate > 0) ? c_lavender : c_gray);
		stats_v2_line("credit luck",   "+" + string_format(_ub.credit_luck, 1, 1) + "%",
			-1, (_ub.credit_luck > 0) ? c_lavender : c_gray);
		stats_v2_line("rebirth units", "+" + string_format(_ub.rebirth_units, 1, 1) + "%",
			-1, (_ub.rebirth_units > 0) ? c_hred : c_gray);

		// ---- the rarity spread (Techdemo II's rarity bar) ----
		// The odds a roll plays by, drawn straight from the array the
		// roll walks, with the histogram of what has actually come out
		// underneath it. Both halves matter: the first is the promise,
		// the second is whether the promise is being kept.
		if (stats_v2_folder("rarity", c_horange)) {
			var _rod = upgrade_rarity_odds();
			var _rent = [];
			var _rbest = -1;
			for (var _rk = 0; _rk < UPG_RARITY_N; _rk++) {
				var _rif = upgrade_rarity_info(_rk);
				var _rsn = (_rk < array_length(g.upg.seen)) ? g.upg.seen[_rk] : 0;
				if (_rsn > 0) _rbest = _rk;
				array_push(_rent, {
					name : _rif.name,
					col  : _rif.col,
					p    : _rod[_rk],
					seen : _rsn,
				});
			}
			stats_v2_rarity("spread", _rent);
			stats_v2_line("rolls", string(g.upg.rolls), -1, -1,
				"every roll, ever - the tally beside each rung above adds "
				+ "up to this. it survives rebirth, like the upgrades do.");
			stats_v2_line("best rolled",
				(_rbest >= 0) ? upgrade_rarity_info(_rbest).name : "-", -1,
				(_rbest >= 0) ? upgrade_rarity_info(_rbest).col : c_gray);
			stats_v2_line("value multiplier",
				"x" + string_format(upgrade_rarity_mult(0), 1, 1) + " .. x"
				+ string_format(upgrade_rarity_mult(UPG_RARITY_N - 1), 1, 1),
				-1, -1, "what a rung is worth: it scales the rolled value, "
				+ "the price and the tier ceiling by the same number, so a "
				+ "rare rung is never simply a better version of a common one.");
		}
		stats_v2_folder_end();
	}
	stats_v2_folder_end();

	// ---- credits ----
	if (variable_global_exists("credits"))
	if (stats_v2_folder("credits", c_lavender)) {
		stats_v2_line("credits", (g.credits >= arb(1)) ? crunch_arb(g.credits) : "0", -1, c_lavender);
		stats_v2_line("lifetime", (g.total_credits >= arb(1)) ? crunch_arb(g.total_credits) : "0");
		stats_v2_line("pool", string_format(g.credit_pool, 1, 2) + " / " + string(g.credit_cap));
		stats_v2_line("cooldown", (g.credit_cool > 0) ? string_format(g.credit_cool, 1, 1) + "s" : "ready");
		stats_v2_line("chance per tap", string(g.credit_tap_chance) + "%");
		stats_v2_line("max per drop", string(g.credit_maxpull));
		stats_v2_line("refill", string(g.credit_refill) + " / hour");
	}
	stats_v2_folder_end();

	// ---- rebirth ----
	if (variable_global_exists("rebirth"))
	if (stats_v2_folder("rebirth", c_hred)) {
		stats_v2_line("units", (g.rebirth.units >= arb(1)) ? crunch_arb(g.rebirth.units) : "0");
		stats_v2_line("total rebirths", string(g.rebirth.total));
		stats_v2_line("unit boost", "x" + crunch_arb(rebirth_boost()));
		var _c = rebirth_calc();
		stats_v2_line("next rebirth", _c.can ? "+" + crunch_arb(_c.units) + " units"
			: "need " + crunch_arb(_c.lack));
	}
	stats_v2_folder_end();

	// ---- dial profit: WHY each dial earns what it earns (his ask) ----
	// Myriad DE had a page like this and his verdict was that it was
	// lame. It was a list of numbers, and a list cannot answer the only
	// question worth asking - which of these is actually carrying the
	// dial. dial_breakdown answers it by working in LOG10, where a
	// product becomes a sum and a sum can be shared out; the bar draws
	// those shares. A x2 milestone beside a x1000 base curve stops
	// looking equally important, because it is not.
	if (variable_global_exists("dial"))
	if (stats_v2_folder("dial profit", c_gold)) {
		var _any = false;
		for (var _i = 0; _i < g.dial_total; _i++) {
			var _d = g.dial[_i];
			if (_d.level <= 0) continue;   // an unbought dial has no story
			_any = true;
			var _bd = dial_breakdown(_i);
			var _hd = "dial " + dial_config(_i).name + "   "
				+ crunch_arb(_d.gps) + " / sec";
			if (stats_v2_folder(_hd, dial_color(_i))) {
				// the bar first: the answer before the working
				stats_v2_bar("share of output", _bd.steps, 4);

				// then the factors themselves, each with what it does
				for (var _s = 0; _s < array_length(_bd.steps); _s++) {
					var _st = _bd.steps[_s];
					var _sv = "";
					// mult -1 = show the value itself (the base curve),
					// -2 = a packed arb too big for string_format
					if (_st.mult == -1)      _sv = crunch_arb(_st.val);
					else if (_st.mult == -2) _sv = "x" + crunch_arb(_st.val);
					else                     _sv = "x" + string_format(_st.mult, 1, 2);
					stats_v2_line(_st.name, _sv, _st.col,
						(_st.share < 0) ? c_hred : -1, _st.note);
				}

				stats_v2_line();
				stats_v2_line("per cycle", crunch_arb(_d.gpc), -1, g.profit_color);
				stats_v2_line("cycle", string_format(_d.cycle_t, 1, 1) + "s");
				// the mirror's self-check. It should never show; if it
				// does, update_dial has moved and dial_breakdown has not
				if (!_bd.ok)
					stats_v2_line("! breakdown drift", "chain "
						+ string_format(_bd.derived, 1, 2) + " vs live "
						+ string_format(_bd.live_lg, 1, 2), c_hred, c_hred,
						"dial_breakdown mirrors update_dial's chain and the "
						+ "two no longer agree - one was edited without the "
						+ "other. The bar above is not trustworthy until "
						+ "they match.");
			}
			stats_v2_folder_end();
		}
		if (!_any) stats_v2_line("no dials running", "", c_gray, c_gray);
	}
	stats_v2_folder_end();

	// ---- milestones: THE DEBUG LIST (his ask) - every dial's rungs,
	// earned or locked, the live totals, the next rung's premium ----
	if (variable_global_exists("milestones") && variable_global_exists("dial"))
	if (stats_v2_folder("milestones", c_aqua)) {
		stats_v2_line("premium", "x" + string(g.milestone_cost_mult) + " the crossing level");
		for (var _i = 0; _i < g.dial_total; _i++) {
			var _d  = g.dial[_i];
			var _ms = milestone_get(_i, _d.level);
			var _hd = "dial " + dial_config(_i).name + "  lv " + string(_d.level);
			if (stats_v2_folder(_hd, dial_color(_i))) {
				stats_v2_line("speed", "x" + string(_ms.speed), -1, (_ms.speed > 1) ? c_sgreen : c_gray);
				stats_v2_line("profit", "x" + string(_ms.profit), -1, (_ms.profit > 1) ? c_sgreen : c_gray);
				for (var _k = 0; _k < array_length(g.milestones); _k++) {
					var _m = g.milestones[_k];
					stats_v2_line("lv " + string(_m.level) + " " + _m.kind + " x" + string(_m.mult),
						_ms.earned[_k] ? "earned" : "locked", -1,
						_ms.earned[_k] ? c_sgreen : c_gray);
				}
				if (_ms.next > 0 && _d.level > 0)
					stats_v2_line("next rung cost",
						crunch_arb(dial_cost(_i, _ms.next - 1, _ms.next)), -1, c_gold);
			}
			stats_v2_folder_end();
		}
	}
	stats_v2_folder_end();

	// ---- options: LIVE toggles + cycles (data-driven - each row
	// flips or advances the global it names) ----
	if (stats_v2_folder("options", c_steelblue)) {
		stats_v2_cycle("values", "stats_mode", ["total", "session"]);
	}
	stats_v2_folder_end();
}
