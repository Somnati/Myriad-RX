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
/// rebirth_calc after the timeclamp and the upgrades.
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
			{ key : "units",   name : "rebirth units",    col : c_hred,     help : "what a rebirth pays" },
		],
	};
	return _c;
}
