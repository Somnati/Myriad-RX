/// @description ui_wordline([val]) - THE WORD UNDER THE COUNTER (his ask,
/// 2026-09-10: "the word version drew the word out beneath the profit
/// but had it abbreviated for the buy costs"). Under the words format
/// the header draws the shown pile's full name on a line of its own
/// just under the bar; everything else keeps the abbreviation.
///
/// ui_wordline(val)  the full name for a packed arb, or "" (not the
///                   words format, under a thousand, past the centillion)
/// ui_wordline_h()   the height that line takes - 9 px while the words
///                   format is on, 0 otherwise - so the readouts stacked
///                   under the header (the per-tap figure, the
///                   overcharger's ring, the bounce tracker) can move
///                   down out of its way. Reserved by FORMAT, not by
///                   value, so the column does not jump every time the
///                   pile crosses a thousand.
function ui_wordline(_v) {
	if (!variable_global_exists("num_format") || g.num_format != 1) return "";
	if (!(_v >= arb(1))) return "";
	var _e = floor(arb_log10(_v)) div 3;
	return num_word_full(_e);
}
