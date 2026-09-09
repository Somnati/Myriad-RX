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
///
/// ⚖️ THE CONTRACT, as of the open animation (2026-09-09): anything
/// returned from here MUST carry `oa` (its 0..1 open ease) and
/// `closing`. ui_blur_tick reads oa off whatever is up so the blur
/// rides the panel in and out, and it would throw on a panel without
/// one. A new overlay is still one line here - plus those two
/// variables in its Create and the three-line ease in its Step.
function ui_overlay() {
	if (instance_exists(syst_settings))      return syst_settings;
	if (instance_exists(syst_statistics_v2)) return syst_statistics_v2;
	return noone;
}
