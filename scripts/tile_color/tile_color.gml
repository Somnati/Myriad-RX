/// @description tile_color(tier) -> the tier's identity color.
/// tiers 2-8 walk Myriad's rarity ladder verbatim (uncommon..ultimate);
/// past 8 the hue wheel takes over: a fixed spoke per ones-digit plus
/// a 36-degree advance per tier, so neighboring tiers never share a
/// hue. rolls are seeded per tier and the RNG stream is restored after
/// (house rule: generators never leak into other streams).
function tile_color(_tier) {
	if (_tier <= 1) return c_white;
	if (_tier == 2) return rgb(60, 255, 69);    // uncommon
	if (_tier == 3) return rgb(65, 122, 255);   // rare
	if (_tier == 4) return rgb(160, 32, 255);   // epic
	if (_tier == 5) return rgb(255, 167, 10);   // legendary
	if (_tier == 6) return rgb(253, 14, 53);    // elite
	if (_tier == 7) return rgb(248, 131, 121);  // divine
	if (_tier == 8) return rgb(185, 242, 255);  // ultimate

	var _seed = random_get_seed();
	random_set_seed(_tier * 1450);

	// spoke by ones-digit (Myriad's wheel, minus the dead branches)
	var _d = _tier % 10;
	var _hue = 0;
	if (_d == 0) _hue = 45;
	if (_d == 1) _hue = 180;
	if (_d == 3) _hue = 90;
	if (_d == 4) _hue = 270;
	if (_d == 5) _hue = random(360);
	if (_d == 6) _hue = 315;
	if (_d == 7) _hue = 135;
	if (_d == 8) _hue = random(360);
	if (_d == 9) _hue = 225;

	_hue += 36 * _tier; // per-tier advance keeps neighbors apart
	_hue = frac((_hue + 3600) / 360) * 360;

	// saturation/value split so odd and even tiers alternate punchy
	// and pale - reads as variety instead of noise
	var _odd  = (_tier % 2 == 1);
	var _dodd = (_d % 2 == 1);
	var _sat = random(.5);
	if (_odd || !_dodd) _sat = random(.5) + .5;
	var _lum = random(.5);
	if (!_odd || _dodd) _lum = random(.5) + .5;

	random_set_seed(_seed);
	return make_colour_hsv(round(255 * (_hue / 360)),
		lerp(100, 255, _sat), lerp(150, 255, _lum));
}
