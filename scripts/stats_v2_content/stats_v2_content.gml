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
		if (variable_global_exists("playtime")) {
			if (_sess) stats_v2_line("time played",
				crunch_time_long(max(0, g.playtime - g.stats_base.playtime) * 60), -1, _sc);
			else stats_v2_line("time played", crunch_time_long(g.playtime * 60));
		}
		if (variable_global_exists("profile_name"))
			stats_v2_line("profile", g.profile_name[g.profile], -1,
				g.profile_color[g.profile]);
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

	// ---- options: LIVE toggles + cycles (data-driven - each row
	// flips or advances the global it names) ----
	if (stats_v2_folder("options", c_steelblue)) {
		stats_v2_cycle("values", "stats_mode", ["total", "session"]);
	}
	stats_v2_folder_end();
}
