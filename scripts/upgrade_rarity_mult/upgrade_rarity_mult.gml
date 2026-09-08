/// @description upgrade_rarity_mult(rarity);
/// @param rarity
/// What a rarity is WORTH: the multiplier on the rolled value, and by
/// the same curve the multiplier on the price. One table, so a rarity
/// cannot mean one thing to the value and another to the cost.
///   common 1x  uncommon 1.6  rare 2.5  epic 3.8  legendary 5.6
///   elite 8.2  divine 11.5  ultimate 16
/// Eight rungs, matching DE's upgrade ladder - see upgrade_rarity_info
/// for why that is a different ladder from the gear one.
function upgrade_rarity_mult(_r) {
	var _t = [1, 1.6, 2.5, 3.8, 5.6, 8.2, 11.5, 16];
	return _t[clamp(floor(_r), 0, array_length(_t) - 1)];
}
