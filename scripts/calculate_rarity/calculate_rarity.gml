/// @description calculate_rarity(rarity_rate,scale,growth,base,clamp_rarity?);
/// @param rarity_rate
/// @param scale
/// @param growth
/// @param base
/// @param clamp_rarity?
function calculate_rarity() {

	/*			// EXAMPLE
	calculate_rarity(20,.3,.03,800)

	RARITY_RATE = rate to feed through such as [20] "20%".
	SCALE = the amount next rarity compares to previous rarity.
	GROWTH = adds to scale for each rarity.
	BASE = this is the point in which the lowest rarity falls off and a new one starts coming in.
	CLAMP_RARITY_ = limits the used rarity

	*/

	// INIT
	_rarity_rate = argument[0];
	_scale = argument[1]; // SCALE
	_growth = argument[2]; // GROWTH
	_rarity_cutoff = max(1,argument[3]); // BASE (rarity reset point)
	_used_rarities = -1; // limits the used rarity
	if argument_count > 4 _used_rarities = argument[4];

	_p = random(100); // value to use for random pick
	_total_rarities = 14; // number of rarities
	_selected_rarity = 0;
	_max_rng = 0;
	_base_rarity = 0;
	if _rarity_cutoff != -1 _base_rarity = floor((_rarity_rate) / _rarity_cutoff);
	

	// CALCULATE RARITY RATE
	_rate = frac(_rarity_rate / _rarity_cutoff);
	_base = 100;
	_rate = power(_rate, 1.65);
	_rate = (((_base + 100) / lerp(100, _base + 100, _rate)) - 1) * 100;
	_rate = frac((_base - _rate) / _base);

	// limits the used rarity
	if _used_rarities != -1 {
		_total_rarities = clamp(_total_rarities, _used_rarities - _base_rarity, _used_rarities);
	}

	//////////////// rarity calc
	_r = 0; 
	_min_rarity[_r] = 0;
	_max_rarity[_r] = lerp(_base, 0, _rate);

	repeat _total_rarities - 1 {
		_r++;
		_min_rarity[_r] = _max_rarity[_r - 1];
		_max_rarity[_r] = _min_rarity[_r] +
			lerp(
				(_base * power(_scale + (_growth * min(_r, 5)), _r)),
				(_base * power(_scale + (_growth * (min(_r - 1, 5))), _r - 1)),
				_rate
			);
	}

	//////////////// END
	_max_rng = _max_rarity[_r];
	_p = random(1) * _max_rng;
	_r = 0;
	repeat _total_rarities {
		if _p >= _min_rarity[_r] and _p <= _max_rarity[_r] {
			_selected_rarity = _r;
		}
		_r++;
	}

	return _selected_rarity;
}
