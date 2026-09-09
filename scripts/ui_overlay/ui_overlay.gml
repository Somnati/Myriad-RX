/// @description ui_overlay() - the full-screen panel currently up over
/// the room, or noone.
///
/// ⚖️ THE ONE ANSWER. Settings and statistics both stopped being rooms
/// (2026-09-08, his ask) and became panels drawn over whatever you are
/// standing in. Two things need to know that: syst_input, which holds
/// the room behind them quiet, and the burger, which becomes the X that
/// closes them. Asking each of those to name every overlay is how the
/// third one gets forgotten in one of the two places - so they ask here,
/// and adding an overlay is a line in this function.
///
/// Order is arbitrary because they are mutually exclusive by
/// construction: each open() refuses while another is up.
function ui_overlay() {
	if (instance_exists(syst_settings))      return syst_settings;
	if (instance_exists(syst_statistics_v2)) return syst_statistics_v2;
	return noone;
}
