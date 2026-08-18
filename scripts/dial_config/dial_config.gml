/// @description dial_config(i) - THE dial roster, declared as data.
/// Myriad DE kept this in get_auto_timer as thirteen hand-written
/// set_protime lines; the ladder they spell out is exact and worth
/// stating plainly: the first dial cycles in 3 seconds and every dial
/// after it takes TWICE as long, a through m -
///   a 3s | b 6s | c 12s | d 24s | e 48s | f 1m36 | g 3m12 | h 6m24 |
///   i 12m48 | j 25m36 | k 51m12 | l 1h42m24 | m 3h24m48
/// A longer cycle is NOT a penalty: per-second output is independent of
/// cycle length (see update_dial - the cycle only decides how the same
/// income is parcelled), so the ladder is pure pacing/feel. Depth comes
/// from dial_lvdiv, which hands higher dials a large level head start.
/// DE also stretches the deep end a second time (set_protime's `mm`):
/// dials i and up take twice as long again, l and up four times.
function dial_config(_i) {
	var _mm = 1;
	if (_i >= 8)  _mm = 2;
	if (_i >= 11) _mm = 4;
	return {
		name  : chr(ord("a") + _i),
		cycle : 3 * power(2, _i) * _mm, // seconds per cycle at base speed
	};
}
