/// @description profit_color_config() - THE PROFIT COLOURS, as data:
/// Myriad DE's four (syst_production's profit_color_picked table, named
/// as its statistics page named them), for the settings pill (his ask,
/// 2026-09-10: "DE let me change the color of profit from green to other
/// colors... wire those into RX"). g.profit_color holds the COLOUR
/// itself (settings.ini has always saved the value, not an index), so
/// the pill matches the value back to a row for its label and a colour
/// nothing here names reads as "custom". Add a row to add a colour;
/// everything profit-denominated already reads g.profit_color.
function profit_color_config() {
	return [
		{ id : "green",   name : "green",   col : c_sgreen },          // DE's default
		{ id : "glimmer", name : "glimmer", col : rgb(131, 255, 250) }, // DE's $83FFFA
		{ id : "gold",    name : "gold",    col : c_gold },
		{ id : "spark",   name : "spark",   col : rgb(5, 254, 186) },   // DE's c_spark
	];
}
