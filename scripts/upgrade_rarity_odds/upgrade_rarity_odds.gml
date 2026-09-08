/// @description upgrade_rarity_odds();
/// THE RARITY DISTRIBUTION, as an array of probabilities summing to 1.
/// upgrade_roll walks it, the statistics bar draws it and the autosell
/// filter's quick-set reads it, so the odds have exactly one owner.
///
/// ⚖️ THIS IS TECHDEMO II'S calculate_rarity, NOT DE'S, and not the
/// cube law it replaces. Three reasons, in order of how much they
/// matter.
///
/// 1. IT IS A BAND LADDER, so each rung is a fixed RATIO of the one
///    below rather than a slice of a cube root. The cube law gave
///    common 50% and then everything above it 4-13% - a flat tail where
///    "ultimate" landed one roll in twenty-three and meant nothing. A
///    ratio ladder makes the tail actually rare, which is the only way
///    a rarity name earns its colour.
///
/// 2. THE TECH DEMO CLAMPS THE GROWTH TERM AT RUNG 5 (min(_r, 5)) where
///    DE lets it run. DE's scale is (s + g*r)^r, so the ratio between
///    neighbouring bands keeps steepening and the top rungs collapse to
///    nothing at all - unreachable rather than rare. The clamp holds the
///    ratio constant past rung 5, which is the improvement worth
///    porting and the reason this is the tech demo's version.
///
/// 3. IT TAKES A LUCK RATE. g.upgrade_rarity slides the whole window
///    upward: past one full cutoff the BOTTOM rung stops being offered
///    at all, which is DE's "commons fall off" and the exact thing the
///    autosell filter is built to survive (upgrade_keep_rarity reads
///    these odds live, so a percentage keeps meaning the same slice of
///    what you actually see).
///
/// Returned as probabilities rather than as a sample, which the tech
/// demo's version could not do: a sampler cannot be drawn as a bar, and
/// a bar computed a second way is a bar that eventually lies.
function upgrade_rarity_odds() {
	var _n = UPG_RARITY_N;
	var _out = array_create(_n, 0);

	var _rate_in = variable_global_exists("upgrade_rarity") ? g.upgrade_rarity : 0;
	var _cut   = max(1, UPG_RARITY_CUT);
	var _scale = UPG_RARITY_SCALE;
	var _grow  = UPG_RARITY_GROW;

	// how far INTO the next window the luck rate sits, curved (the tech
	// demo's 1.65 shaping - the window slides in smoothly rather than
	// snapping over at the cutoff)
	var _base = 100;
	var _f = frac(_rate_in / _cut);
	_f = power(_f, 1.65);
	_f = (((_base + 100) / lerp(100, _base + 100, _f)) - 1) * 100;
	_f = frac((_base - _f) / _base);

	// ⚖️ AND THE WHOLE WINDOW SLIDES (DE's b_rarity, which the first cut
	// of this port dropped - without it the fractional blend above just
	// wrapped at every cutoff and the ladder never actually moved).
	// Every full cutoff of luck retires the bottom rung: the bands are
	// computed over what is LEFT and the results are shifted up, so
	// commons stop being offered at all rather than merely becoming
	// unlikely. That is the case a fixed-rung autosell filter could
	// never have survived, and the reason upgrade_keep_rarity is a
	// percentage read off these odds.
	var _shift = min(floor(_rate_in / _cut), _n - 1);
	var _bands = _n - _shift;

	// the bands. width(0) shrinks toward nothing as the window slides
	// within its cutoff, which is how a rung fades out before it goes;
	// every rung above is the previous times a ratio that stops
	// steepening at rung 5.
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
