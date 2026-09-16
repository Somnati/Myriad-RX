/// @description egg_word(hue, seed) -> the word for an egg's colour ("rose", "teal"...), a pool a band of the hue wheel, picked by the seed
/// THE EGGS (his ask, 2026-09-16: "sometimes the sprites bring back coloured eggs... that could be how new sprites are acquired")
function egg_word(_hue, _seed) {
	static _pools = [
		["scarlet", "red", "cherry", "ember"], ["amber", "orange", "rust", "copper"], ["gold", "yellow", "honey", "straw"],
		["leaf", "green", "moss", "lime"], ["teal", "jade", "sea", "mint"], ["sky", "blue", "cobalt", "azure"],
		["indigo", "violet", "plum", "iris"], ["pink", "rose", "magenta", "coral"],
	];
	var _b = clamp(floor(((_hue mod 256) + 12) / 32), 0, 7) mod 8;
	var _p = _pools[_b];
	return _p[hash_mix(_seed, 53) mod array_length(_p)];
}
