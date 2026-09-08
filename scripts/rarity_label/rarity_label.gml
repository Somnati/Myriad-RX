/// @description rarity_label(p) - odds probability -> the market's
/// rarity text. p is the WITHIN-TIER "a fresh roll is at least this
/// good on its power axes" probability the roll scripts compute for
/// themselves (rar_p) - this is only the formatter, the math lives
/// with each roll.
/// round 3 (his call: "common roll" meant nothing): EVERYTHING reads
/// "1 in N", rounded to clean figures by magnitude (an exact 1 in
/// 3125 shows 1 in 3100 - last digits traded for readability). a
/// roll that rounds to 1 in 1 returns "" - callers drop the line.
function rarity_label(_p) {
	_p = clamp(_p, .0002, 1);
	var _n = 1 / _p;
	if (_n < 20)        _n = round(_n);
	else if (_n < 100)  _n = round(_n / 5) * 5;
	else if (_n < 1000) _n = round(_n / 10) * 10;
	else                _n = round(_n / 100) * 100;
	if (_n <= 1) return ""; // 1 in 1 says nothing
	return "1 in " + string(_n);
}
