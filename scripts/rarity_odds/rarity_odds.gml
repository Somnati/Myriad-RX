/// @description rarity_odds(rate, scale, grow, cut, n);
/// @param rate   the luck rate feeding the ladder
/// @param scale  how wide a band is against the one below it
/// @param grow   how much that steepens per rung (clamped at rung 5)
/// @param cut    the rate at which one whole rung has fallen off
/// @param n      how many rungs to report
/// THE BAND LADDER AS A DISTRIBUTION - an array of n probabilities
/// summing to 1. This is Techdemo II's calculate_rarity turned inside
/// out: that script SAMPLES the ladder, and a sampler cannot be drawn
/// as a bar or read by a filter. Same bands, same shaping, same window
/// slide - answered as odds instead of as a roll.
///
/// TWO CUSTOMERS, which is why it is its own script: the upgrade table
/// (upgrade_rarity_odds) and the tile fabricator (tile_tier_odds). They
/// run the ladder with different knobs and different rung counts, and
/// the one thing they must not have is two copies of the arithmetic -
/// a chart that agrees with its generator only by coincidence agrees
/// with it only until someone edits one of them.
///
/// THE min(_r, 5) CLAMP is the tech demo's improvement over DE and the
/// reason to have ported from there: unclamped, the ratio between
/// neighbouring bands keeps steepening and the top rungs collapse from
/// rare to unreachable.
///
/// THE WINDOW SLIDES with the rate (DE's b_rarity): every full `cut`
/// retires the bottom rung entirely, so the lowest tier stops being
/// offered rather than merely becoming unlikely.
function rarity_odds(_rate, _scale, _grow, _cut, _n) {
	var _out = array_create(_n, 0);
	_cut = max(1, _cut);

	// how far INTO the next window the rate sits, curved - the tech
	// demo's 1.65 shaping, so a window slides in smoothly rather than
	// snapping over at the cutoff
	var _base = 100;
	var _f = frac(_rate / _cut);
	_f = power(_f, 1.65);
	_f = (((_base + 100) / lerp(100, _base + 100, _f)) - 1) * 100;
	_f = frac((_base - _f) / _base);

	var _shift = min(floor(_rate / _cut), _n - 1);
	var _bands = _n - _shift;

	var _w = array_create(_bands, 0);
	_w[0] = lerp(_base, 0, _f);
	var _tot = _w[0];
	for (var _r = 1; _r < _bands; _r++) {
		_w[_r] = lerp(
			_base * power(_scale + _grow * min(_r, 5), _r),
			_base * power(_scale + _grow * min(_r - 1, 5), _r - 1),
			_f);
		_tot += _w[_r];
	}

	if (_tot <= 0) { _out[_n - 1] = 1; return _out; }
	for (var _r = 0; _r < _bands; _r++) _out[_shift + _r] = _w[_r] / _tot;
	return _out;
}
