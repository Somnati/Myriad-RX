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
