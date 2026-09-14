/// @description cheat_config() -> the rows, as data. Add a row here and
/// read it with cheat_rate(key) at the ONE site that rate lives; the
/// panel, the save and the cap follow the array.
///   key   what cheat_rate answers to
///   name  the row's label
///   col   its colour (the bar, the label)
///   help  the footer's line while the row is hovered
/// THE SEATS (result-side, the upgrade bonuses' pattern - never an
/// input): dprofit / dspeed in update_dial; fab in autom_rate +
/// tiles_fab_charge; tout in tile_out (every tile's pay, so the tick,
/// the replay and the faces agree); merge in autom_rate +
/// tiles_merge_charge; ccap / crate in ccore_values; units in
/// rebirth_feed (every gain, as it lands - never in rebirth_calc).
function cheat_config() {
	static _c = {
		rows : [
			{ key : "dprofit", name : "dial profit",      col : c_sgreen,   help : "what every dial pays a cycle" },
			{ key : "dspeed",  name : "dial speed",       col : c_gold,     help : "how fast every dial cycles" },
			{ key : "fab",     name : "tile fabrication", col : c_aqua,     help : "how fast the fabricator runs - and what a charge is worth" },
			{ key : "tout",    name : "tile output",      col : c_horange,  help : "what every tile on the table pays" },
			{ key : "merge",   name : "automerger speed", col : c_aqua,     help : "how fast the automerger works - and what a charge is worth" },
			{ key : "ccap",    name : "core capacity",    col : c_lavender, help : "how many credits the core's well holds" },
			{ key : "crate",   name : "core rate",        col : c_lavender, help : "how fast the core's well fills" },
			// UNIT GROWTH, not units (his call, 2026-09-13): the row feeds the
			// rebirth profit AS YOU EARN, so it cannot be maxed at the last second
			{ key : "units",   name : "unit growth",      col : c_hred,     help : "how much of what you earn counts toward a rebirth - paid as you earn it, not at the end" },
		],
	};
	return _c;
}
