/// @description crunch_arb_full(packed, [hardpoint]);
/// @param packed      a packed arb
/// @param [hardpoint] exponent to start crunching at
/// THE COUNTER'S NUMBER, written out in full with thousands separators
/// while it is small enough to read that way, and crunched above it.
/// Myriad DE's obj_ui_drawgold does exactly this - crunch_arb_ext below
/// the hardpoint, crunch_arb above - and the reason is worth stating,
/// because it is the opposite of what an idle game usually does.
///
/// EARLY, THE DIGITS ARE THE GAME. 1,284 -> 1,291 is seven profit you
/// can see arrive; "1.28k -> 1.29k" is a number that mostly sits still
/// while you tap. The abbreviation only starts earning its keep once
/// the digits stop being individually meaningful, and that is a
/// threshold rather than a taste - past a hundred million, the low
/// digits are noise and the magnitude is the whole story.
///
/// Above the hardpoint it hands straight over to crunch_arb, so there
/// is exactly one abbreviation formatter in the project and this is a
/// front end to it, not a fork.
function crunch_arb_full(_a, _hard = PROFIT_DIGIT_MAX) {
	if (!(_a >= arb(1))) return "0";
	if (floor(_a) >= _hard) return crunch_arb(_a);

	var _n = round(unarb(_a));
	var _s = string(_n);
	// commas from the right, three at a time
	var _p = string_length(_s) - 3;
	while (_p > 0) {
		_s = string_insert(",", _s, _p + 1);
		_p -= 3;
	}
	return _s;
}
