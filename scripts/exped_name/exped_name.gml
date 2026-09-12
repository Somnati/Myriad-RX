/// @description exped_name(seed) -> a world's name, from its seed
/// Two or three soft syllables and a roman numeral now and then - the
/// sprites' naming voice, so the two systems sound like one game.
/// @param seed
function exped_name(_seed) {
	var _rs = random_get_seed();
	random_set_seed(_seed);
	var _c = ["v", "r", "th", "k", "s", "n", "m", "l", "d", "x", "z", "t"];
	var _v = ["a", "e", "i", "o", "u", "ae", "ia", "ou"];
	var _n = "";
	repeat (2 + irandom(1)) _n += _c[irandom(array_length(_c) - 1)] + _v[irandom(array_length(_v) - 1)];
	if (irandom(2) == 0) _n += " " + choose("ii", "iii", "iv", "v", "vii", "ix");
	_n = string_upper(string_char_at(_n, 1)) + string_delete(_n, 1, 1);
	rng_release(_rs);
	return _n;
}
