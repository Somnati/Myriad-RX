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

	// ORDER (2026-09-10's tidy): the account, the money room, the two
	// boards, the meta systems. (The total/session switch used to be a
	// one-row "options" folder up here; it is the [total]/[session]
	// pill in the title strip now - his ask, 2026-09-11: "we dont need
	// a whole tab... dedicated to 1 option".)

	// ---- general ----
	if (stats_v2_folder("general", c_feat_statistics)) {
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

	// ---- tapping ----
	if (variable_global_exists("total_taps"))
	if (stats_v2_folder("tapping", c_feat_clicker)) {
		// ---- why a tap pays what it pays (his ask, 2026-09-10; first in
		// the folder, his call) - the
		// dial pages' sibling: a bar of what the tap is MADE of (a sum,
		// shared linearly), then the multipliers on the whole ----
		if (variable_global_exists("click_gps"))
		if (stats_v2_folder("tap breakdown", c_feat_clicker)) {
			var _tbk = tap_breakdown();
			stats_v2_bar("what a tap is made of", _tbk.terms, 4);
			for (var _s = 0; _s < array_length(_tbk.terms); _s++) {
				var _tm = _tbk.terms[_s];
				stats_v2_line(_tm.name, "+" + crunch_arb(_tm.val), _tm.col, -1, _tm.note);
			}
			stats_v2_line("before multipliers", crunch_arb(_tbk.base), -1, c_gray);
			for (var _s = 0; _s < array_length(_tbk.mults); _s++) {
				var _mm = _tbk.mults[_s];
				stats_v2_line(_mm.name, "x" + string_format(_mm.mult, 1, 2), _mm.col, -1, _mm.note);
			}
			if (array_length(_tbk.mults) == 0)
				stats_v2_line("multipliers", "none yet", c_gray, c_gray,
					"tap profit upgrades and the overcharger multiply the sum above");
			stats_v2_line("crits, on average", "x" + string_format(_tbk.crit_x, 1, 2),
				c_aqua, -1,
				"not in the per-tap figure - tap_fire rolls them per tap. "
				+ "this is what they add over many taps: 1 + chance x "
				+ "(mean payout - 1)");
			stats_v2_line();
			stats_v2_line("per tap", crunch_arb(g.click_gps), -1, g.profit_color);
			if (!_tbk.ok)
				stats_v2_line("! breakdown drift", "chain "
					+ string_format(_tbk.derived, 1, 2) + " vs live "
					+ string_format(_tbk.live_lg, 1, 2), c_hred, c_hred,
					"tap_breakdown mirrors update_click's chain and the two "
					+ "no longer agree - one was edited without the other.");
		}
		stats_v2_folder_end();
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
			stats_v2_line("crit chance", string_format(g.click_crit * luck_mod(), 1, 1) + "%", -1, c_gray,
				"the base chance with your luck on it - every roll in the game takes luck_mod");
		stats_v2_line("luck", string(luck_points()) + "  (x" + string_format(luck_mod(), 1, 2) + ")", -1, c_seagreen,
			"DE's luck: flat points from the luck upgrade and every daily gift collected, "
			+ "turned into one multiplier every chance takes - crits, credit drops, the "
			+ "upgrade table's rarity, tile and sprite tiers");
		if (variable_global_exists("click_critx_min"))
			stats_v2_line("crit payout", "x" + string_format(g.click_critx_min, 1, 1)
				+ " - x" + string_format(g.click_critx_max, 1, 1), -1, c_gray);
		if (variable_global_exists("click_gps"))
			stats_v2_line("per tap", crunch_arb(g.click_gps), -1, g.profit_color);
		if (variable_global_exists("overcharge_lv"))
			stats_v2_line("overcharge", "x" + string(overcharge_multi())
				+ "  (lv " + string(g.overcharge_lv) + " / " + string(overcharge_maxlv()) + ")",
				-1, (g.overcharge_lv > 1) ? vis_tier_color(g.overcharge_lv - 1) : c_gray,
				"tapping charges it: every level is another x1 on what a tap "
				+ "pays, and it drains when you stop. the ring beside the "
				+ "per-tap figure is the charge toward the next level.");
		stats_v2_line("hold rate", string(floor(tap_rate())) + " a second", -1, c_gray,
			"hold the tap surface and it taps at this rate. taps bank as a "
			+ "fraction each frame and the whole part is paid in one go, so "
			+ "a rate past the frame rate is paid exactly rather than "
			+ "quietly capped at 60.");
		if (instance_exists(obj_clicker))
			stats_v2_line("taps a second", string(floor(obj_clicker.tps)), -1,
				(obj_clicker.tps >= 1) ? g.profit_color : c_gray,
				"what you are actually managing right now - your own taps "
				+ "over the last second, plus the hold rate while you hold.");
	}
	stats_v2_folder_end();

	// ---- dials: the per-dial pages, one folder (2026-09-10's tidy:
	// 'dial profit' and 'milestones' both walk the same dials, and two
	// top-level folders that each open into eight sub-folders read as
	// sixteen pages about one thing) ----
	if (variable_global_exists("dial"))
	if (stats_v2_folder("dials", c_feat_dials)) {
		// ---- dial profit: WHY each dial earns what it earns (his ask) ----
		// Myriad DE had a page like this and his verdict was that it was
		// lame. It was a list of numbers, and a list cannot answer the only
		// question worth asking - which of these is actually carrying the
		// dial. dial_breakdown answers it by working in LOG10, where a
		// product becomes a sum and a sum can be shared out; the bar draws
		// those shares. A x2 milestone beside a x1000 base curve stops
		// looking equally important, because it is not.
		if (variable_global_exists("dial"))
		if (stats_v2_folder("dial profit", c_feat_dials)) {
			var _any = false;
			for (var _i = 0; _i < g.dial_total; _i++) {
				var _d = g.dial[_i];
				if (_d.level <= 0) continue;   // an unbought dial has no story
				_any = true;
				var _bd = dial_breakdown(_i);
				// the PAID rate (raw curve x the tile table) - what the
				// drawer's rows and the bank agree on
				var _hd = "dial " + dial_config(_i).name + "   "
					+ crunch_arb(_bd.gps) + " / sec";
				if (stats_v2_folder(_hd, dial_color(_i), "dial " + dial_config(_i).name)) {
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
					var _tb2 = tile_dial_boost();
					var _pc2 = (_tb2 > arb(1)) ? do_multi(_d.gpc, _tb2) : _d.gpc;
					stats_v2_line("per cycle", crunch_arb(_pc2), -1, g.profit_color,
						(_tb2 > arb(1)) ? ("the curve pays " + crunch_arb(_d.gpc)
							+ " a cycle; the tile table multiplies it by x"
							+ crunch_arb(_tb2) + " on the way to the bank") : "");
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
		if (stats_v2_folder("milestones", c_feat_dials)) {
			stats_v2_line("premium", "x" + string(g.milestone_cost_mult) + " the crossing level");
			for (var _i = 0; _i < g.dial_total; _i++) {
				var _d  = g.dial[_i];
				var _ms = milestone_get(_i, _d.level);
				var _hd = "dial " + dial_config(_i).name + "  lv " + string(_d.level);
				if (stats_v2_folder(_hd, dial_color(_i), "dial " + dial_config(_i).name)) {
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
	}
	stats_v2_folder_end();

	// ---- tiles ----
	if (variable_global_exists("tiles"))
	if (stats_v2_folder("tiles", c_feat_tiles)) {
		// ---- the fabricator's luck, as a spread - FIRST in the folder
		// (his call, 2026-09-10) ----
		if (stats_v2_folder("rarity", c_horange)) {
			// TEN TIERS, not the ladder's full fourteen: past that the
			// odds are far below a tenth of a percent and the rows are
			// all the same shape. The bar's job is to show where the
			// mass actually is.
			var _tn = 10;
			var _to = tile_tier_odds(_tn);
			var _te = [];
			for (var _i = 0; _i < _tn; _i++)
				array_push(_te, {
					name : "tier " + string(_i + 1),
					col  : tile_color(_i + 1),
					p    : _to[_i],
				});
			// the fabricator's live rate, through the one authority that
			// knows the whole chain (base, deck adder, the multiplier)
			stats_v2_rarity("spread", _te,
				"rarity rate  +" + string(round(tile_rarity_rate())) + "%");
			stats_v2_line("fabricator luck",
				"+" + string(round(tile_rarity_rate())), -1,
				(tile_rarity_rate() > TILE_RARITY_BASE) ? c_horange : c_gray,
				"every fabricated tile rolls its tier through this. it "
				+ "shifts the whole spread up, and past each 800 the "
				+ "bottom tier stops being offered at all.");
		}
		stats_v2_folder_end();

		var _tl = g.tiles;
		if (!TILES_LIVE)
			stats_v2_line("preview", "not saved", -1, c_horange,
				"the tile table is finished but not tied in yet: it is "
				+ "kept out of the savefile, out of the offline replay "
				+ "and out of profit. one macro turns all three on.");
		var _used = 0;
		for (var _i = 0; _i < _tl.slots; _i++) if (_tl.tier[_i] != 0) _used++;

		stats_v2_line("shards", (_tl.shards >= arb(1)) ? crunch_arb(_tl.shards) : "0",
			-1, c_aqua,
			"the table's own currency, and the only thing tile upgrades "
			+ "cost. it deliberately does NOT feed profit: the board is "
			+ "the only source and the upgrades are the only sink, so "
			+ "what happens on the board is the only thing that moves it.");
		stats_v2_line("per second", "+"
			+ ((_tl.gps >= arb(1)) ? crunch_arb(_tl.gps) : "0"), -1, c_aqua,
			"merging into higher tiers grows this fast - a tier is worth "
			+ "about 2.8x the one below, and it only costs two of them.");
		stats_v2_line("lifetime shards",
			(_tl.earned >= arb(1)) ? crunch_arb(_tl.earned) : "0");
		stats_v2_line("board", string(_used) + " / " + string(_tl.slots), -1,
			(_used >= _tl.slots) ? c_horange : -1);
		stats_v2_line("banked", string(_tl.stored) + " / " + string(_tl.stored_max),
			-1, (_tl.stored >= _tl.stored_max) ? c_horange : -1,
			"tiles fabricated while the board was full. they deal onto "
			+ "open slots by themselves as space frees up - and at the cap "
			+ "the fabricator WAITS rather than throwing production away.");
		stats_v2_line("highest tier", string(_tl.highest), -1,
			tile_color(_tl.highest));
		stats_v2_line("tiles made", string(_tl.made));
		stats_v2_line("merges", string(_tl.merges));
		stats_v2_line("fabricator", string_format(_tl.fab_t / 60, 1, 1) + "s",
			-1, -1, "how long one tile takes. the auto-merger runs on a "
			+ "MULTIPLE of it, so anything that speeds fabrication speeds "
			+ "merging too.");

		// the table's prestige and what it feeds (2026-09-10)
		var _fx = _tl[$ "flux"] ?? 0;
		stats_v2_line("flux", string(_fx), -1, (_fx > 0) ? c_hred : c_gray,
			"the table's own rebirth currency: earned shards / 1e8 each "
			+ "rebirth, kept forever. every point is +1% to what every "
			+ "tile pays.");
		stats_v2_line("table rebirths", string(_tl[$ "rb_total"] ?? 0));
		stats_v2_line("flux boost", "x" + string_format(tile_rebirth_boost(), 1, 2),
			-1, (_fx > 0) ? c_hred : c_gray);
		var _db = tile_dial_boost();
		var _dbl = arb_log10(_db);
		stats_v2_line("dial boost", "x" + ((_dbl < 3)
			? string_format(power(10, _dbl), 1, 2) : crunch_arb(_db)), -1,
			(_db > arb(1)) ? c_aqua : c_gray,
			"what the table multiplies every dial's profit by. zero until "
			+ "the dial profit boost upgrade is bought - that upgrade IS "
			+ "the wire between the two.");
		stats_v2_line("duplication", string(tile_chance_rate("dup")) + "%", -1, c_gray,
			"the chance a fabricated tile comes out as two.");
		stats_v2_line("tier up", string(tile_chance_rate("tierup")) + "%", -1, c_gray,
			"the chance a merge climbs an extra tier.");

		// the upgrades, as levels - what they DO is on the rows
		// above, derived by tiles_sync, so this is only the ladder
		var _tuc2 = tile_upg_config();
		for (var _k = 0; _k < array_length(_tuc2); _k++) {
			var _lv2 = g.tiles.upg[$ _tuc2[_k].id] ?? 0;
			stats_v2_line(_tuc2[_k].name, "lv " + string(_lv2), -1,
				(_lv2 > 0) ? c_aqua : c_gray, _tuc2[_k].help);
		}

	}
	stats_v2_folder_end();

	// ---- upgrades ----
	if (variable_global_exists("upg"))
	if (stats_v2_folder("upgrades", c_feat_upgrades)) {
		// ---- the rarity spread (Techdemo II's rarity bar) - FIRST in the
		// folder (his call, 2026-09-10) ----
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
			// the roll's own rate, DE's phrasing - the one number every
			// rung below is a consequence of
			stats_v2_rarity("spread", _rent,
				"rarity rate  +" + string(round(g.upgrade_rarity)) + "%");
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

		var _ub = upgrade_bonus();
		var _held = 0;
		for (var _i = 0; _i < upgrade_slots(); _i++)
			if (is_struct(g.upg.slot[_i]) && g.upg.slot[_i].tier > 0) _held++;
		stats_v2_line("slots", string(_held) + " / " + string(upgrade_slots()));
		stats_v2_line("bought", string(g.upg.total));
		var _dnk = variable_struct_get_names(g.upg.done);
		var _dc  = 0;
		for (var _i = 0; _i < array_length(_dnk); _i++)
			_dc += g.upg.done[$ _dnk[_i]].n;
		stats_v2_line("completed", string(_dc), -1,
			(_dc > 0) ? c_gold : c_gray,
			"upgrades taken to their last tier. they free their slot and "
			+ "keep paying out - the totals below count them.");
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
	}
	stats_v2_folder_end();

	// ---- credits ----
	if (variable_global_exists("credits"))
	if (stats_v2_folder("credits", c_feat_credits)) {
		stats_v2_line("credits", (g.credits >= arb(1)) ? crunch_arb(g.credits) : "0", -1, c_lavender);
		stats_v2_line("lifetime", (g.total_credits >= arb(1)) ? crunch_arb(g.total_credits) : "0");
		// the credit core's own ledger (ccore_init: made / pulls, saved)
		if (variable_global_exists("ccore") && g.ccore.lv > 0) {
			var _ccv = ccore_values();
			stats_v2_line("credit core", "level " + string(g.ccore.lv) + "  -  " + string(_ccv.cap) + " cap, "
				+ string_format(_ccv.gain * 60, 1, 2) + "/min", -1, c_lavender);
			stats_v2_line("drawn from the core", string(g.ccore[$ "made"] ?? 0) + " credits over "
				+ string(g.ccore[$ "pulls"] ?? 0) + ((g.ccore[$ "pulls"] ?? 0) == 1 ? " collect" : " collects"), -1, c_lavender);
		}
		stats_v2_line("pool", string_format(g.credit_pool, 1, 2) + " / " + string(g.credit_cap));
		stats_v2_line("cooldown", (g.credit_cool > 0) ? string_format(g.credit_cool, 1, 1) + "s" : "ready");
		stats_v2_line("chance per tap", string(g.credit_tap_chance) + "%");
		stats_v2_line("max per drop", string(g.credit_maxpull));
		stats_v2_line("refill", string(g.credit_refill) + " / hour");
	}
	stats_v2_folder_end();

	// ---- automation ----
	if (variable_global_exists("autom"))
	if (stats_v2_folder("automation", c_feat_automation)) {
		// the master row (2026-09-14): what it watches - the filter's owned dials
		var _ax = g.autom.dial_all.on ? autom_strat_n() : 0;
		stats_v2_line("dials automated",
			string(_ax) + " / " + string(array_length(g.autom.dial)), -1,
			(_ax > 0) ? c_sblue : c_gray);
		stats_v2_line("reserve", string(g.autom.lock_pct) + "% of the peak",
			-1, (g.autom.lock_pct > 0) ? c_gold : c_gray,
			"this share of the HIGHEST pile you have held this run is kept "
			+ "out of spending. measured against the peak rather than the "
			+ "pile so that spending cannot walk it down - it is still "
			+ "profit and rebirth still counts it, autobuy just cannot "
			+ "reach it. turn the slider down and it releases at once.");
		stats_v2_line("run peak", (g.autom.lock_peak >= arb(1))
			? crunch_arb(g.autom.lock_peak) : "0", -1, c_gray,
			"the highest profit held this run - what the reserve is a "
			+ "percentage of. rises with earnings, never with spending, "
			+ "and resets at rebirth.");
		var _resv = profit_reserved();
		stats_v2_line("held back", (_resv >= arb(1)) ? crunch_arb(_resv) : "0",
			-1, (_resv >= arb(1)) ? c_gold : c_gray,
			"a percentage of what you hold, worked out fresh - so turning "
			+ "the slider down releases it that instant. it is a brake on "
			+ "spending, not a vault: spending lowers the pile, which "
			+ "lowers the reserve with it.");
		stats_v2_line("spendable", (profit_spendable() >= arb(1))
			? crunch_arb(profit_spendable()) : "0", -1, g.profit_color);
		var _rb = g.autom.reb;
		var _rn = (_rb.t_on ? 1 : 0) + (_rb.u_on ? 1 : 0) + (_rb.g_on ? 1 : 0)
			+ (_rb.c_on ? 1 : 0) + (_rb.p_on ? 1 : 0);
		stats_v2_line("rebirth rails", (_rn > 0) ? (string(_rn) + " armed") : "off",
			-1, (_rn > 0) ? c_hred : c_gray,
			"every armed condition has to pass before an auto rebirth "
			+ "fires. they are rails, not triggers.");
		// the filter, as what it actually rejects rather than as a
		// threshold - it stopped being one when the flags went explicit
		var _fs = 0;
		for (var _k = 0; _k < UPG_RARITY_N; _k++)
			if (!g.autom.upg.rar[_k]) _fs++;
		var _fkn = variable_struct_get_names(g.autom.upg.kind);
		var _fk = 0;
		for (var _k = 0; _k < array_length(_fkn); _k++)
			if (!g.autom.upg.kind[$ _fkn[_k]]) _fk++;
		stats_v2_line("upgrade filter",
			(_fs + _fk > 0) ? (string(_fs) + " rarities, " + string(_fk) + " kinds")
			                : "keeping everything",
			-1, (_fs + _fk > 0) ? c_horange : c_gray,
			"what the autosell throws away. a slot goes if either its "
			+ "rarity or its kind is switched to sell - set both on the "
			+ "automation room's filter page.");
	}
	stats_v2_folder_end();

	// ---- time bank ----
	if (variable_global_exists("timebank"))
	if (stats_v2_folder("time bank", c_feat_timebank)) {
		var _tb = g.timebank;
		stats_v2_line("banked", (_tb.bank >= 1)
			? crunch_time_long(_tb.bank * 60) : "empty", -1,
			(_tb.bank >= 1) ? c_gold : c_gray);
		stats_v2_line("capacity", crunch_time_long(timebank_cap() * 60));
		stats_v2_line("rate", string(round(timebank_rate() * 3600))
			+ " sec / hour away", -1, -1,
			"how much of an absence banks as spendable speed. it stays "
			+ "under an hour per hour by law - time never multiplies "
			+ "itself, it only becomes available later.");
		stats_v2_line("active speed", "x" + string(_tb.spd), -1,
			(_tb.spd > 1) ? c_gold : c_gray);
		stats_v2_line("capacity buys", string(_tb.cap_lv));
		stats_v2_line("rate buys", string(_tb.rate_lv));
	}
	stats_v2_folder_end();

	// ---- the coin (2026-09-13) ----
	if (variable_global_exists("coin") && unfold_has("coin"))
	if (stats_v2_folder("the coin", c_gold)) {
		var _cn = g.coin;
		stats_v2_line("flips", string(_cn.flips));
		stats_v2_line("heads", string(_cn.heads)
			+ ((_cn.heads + _cn.tails > 0) ? " (" + string(round(100 * _cn.heads / (_cn.heads + _cn.tails))) + "%)" : ""));
		stats_v2_line("tails", string(_cn.tails));
		stats_v2_line("best run of one side", string(_cn.best));
	}
	stats_v2_folder_end();

	// ---- scratch tickets (2026-09-13) ----
	if (variable_global_exists("tickets") && unfold_has("tickets"))
	if (stats_v2_folder("scratch tickets", c_feat_tickets)) {
		var _tk = g.tickets;
		stats_v2_line("on the desk", string(array_length(_tk.pile)));
		stats_v2_line("scratched", string(_tk.scratched));
		stats_v2_line("winners", string(_tk.won)
			+ ((_tk.scratched > 0) ? " (" + string(round(100 * _tk.won / _tk.scratched)) + "%)" : ""));
		if (_tk.best >= 0) stats_v2_line("best win", _tk.best_txt, -1, ticket_config().rars[_tk.best].col);
	}
	stats_v2_folder_end();

	// ---- rebirth ----
	if (variable_global_exists("rebirth"))
	if (stats_v2_folder("rebirth", c_feat_rebirth)) {
		stats_v2_line("units", (g.rebirth.units >= arb(1)) ? crunch_arb(g.rebirth.units) : "0");
		stats_v2_line("total rebirths", string(g.rebirth.total));
		stats_v2_line("fed profit", (g.rebirth.fed >= arb(1)) ? crunch_arb(g.rebirth.fed) : "0", -1, -1,
			"what a rebirth counts: the pile as fed through the cheat shop's unit growth row, earn by earn");
		stats_v2_line("unit boost", "x" + crunch_arb(rebirth_boost()));
		var _c = rebirth_calc();
		stats_v2_line("next rebirth", _c.can ? "+" + crunch_arb(_c.units) + " units"
			: "need " + crunch_arb(_c.lack));
	}
	stats_v2_folder_end();
}
