/// @description vis_tier_color(tier) - the big-number visualiser's
/// palette: one colour per magnitude tier (Myriad DE's
/// mod_get_gpscolor, which the same palette also gives to tiles and
/// upgrade rarities).
/// Tier 1 is white and 2..8 walk the house rarity ladder; past 8 the
/// hue is generated on a fixed rotation so the ladder never runs out.
/// IMPROVED vs DE: DE's version calls random() mid-formula and then
/// randomize(), which both scrambles the caller's RNG stream and makes
/// the colour depend on when it was asked for. RX derives everything
/// from the tier and restores the seed (the house deterministic-roll
/// law), so a given magnitude is always the same colour.
function vis_tier_color(_tier) {
	if (_tier <= 1) return c_white;
	if (_tier == 2) return c_rarity_uncommon;
	if (_tier == 3) return c_rarity_rare;
	if (_tier == 4) return c_rarity_epic;
	if (_tier == 5) return c_rarity_legendary;
	if (_tier == 6) return c_rarity_elite;
	if (_tier == 7) return c_rarity_divine;
	if (_tier == 8) return c_rarity_ultimate;

	// past the named rarities: DE's hue wheel, seeded by the tier
	var _seed = random_get_seed();
	random_set_seed(_tier * 1450);

	var _t = round(lerp(0, 10, frac(_tier / 10)));
	var _hue = 0;
	if (_t == 1) _hue = 180;
	if (_t == 3) _hue = 90;
	if (_t == 4) _hue = 270;
	if (_t == 5) _hue = random(360);
	if (_t == 6) _hue = -45;
	if (_t == 7) _hue = 135;
	if (_t == 8) _hue = random(360);
	if (_t == 9) _hue = 225;
	if (_t == 10) _hue = 45;
	_hue += (360 / 10) * _tier;
	_hue += 360 * 4;
	_hue /= 360;
	_hue = round(lerp(0, 255, frac(_hue)));

	var _todd = (_tier mod 2) == 1;
	var _kodd = (_t mod 2) == 1;
	var _sat = random(.5);
	if (_todd || !_kodd) _sat = random(.5) + .5;
	var _lum = random(.5);
	if (!_todd || _kodd) _lum = random(.5) + .5;

	random_set_seed(_seed);
	return make_colour_hsv(_hue, lerp(100, 255, _sat), lerp(150, 255, _lum));
}
