/// @description sprite_name_gen() -> a cute name off the ambient stream ("momo", "bibi", "klowen", "sha-sha", "tobbit")
/// THE ONE NAME GENERATOR (the names pass, 2026-09-15): every sprite
/// (sprite_spawn) and everyone met on the road (exped_npc_name) is named
/// here. Soft syllables - a consonant (or, one time in six, a soft
/// cluster) and a vowel - in five shapes: doubled ("momo"), two, three, a
/// doubled tail ("tobobo"), a sung double ("bo-bo"); an ending one time
/// in four. Never a fixed list of names (his rule).
function sprite_name_gen() {
	static _c  = ["b", "m", "p", "n", "l", "d", "z", "k", "w", "t", "f", "j", "r", "s", "h", "v", "g", "y", "q"];
	static _cl = ["bl", "kl", "pl", "fl", "sh", "th", "ch", "br", "kr", "tw", "sn", "mb"];
	static _v  = ["a", "i", "o", "u", "e", "oo", "ee", "ai", "ou", "oa", "y", "ie"];
	static _e  = ["t", "n", "p", "k", "sh", "ll", "m", "s", "x", "ck", "ng", "bit"];
	// (a function literal sees no outer local or static: the pools ride in as arguments)
	var _syl = function(_c2, _cl2, _v2) { return ((random(1) < .16) ? _cl2[irandom(array_length(_cl2) - 1)] : _c2[irandom(array_length(_c2) - 1)]) + _v2[irandom(array_length(_v2) - 1)]; };
	var _nm, _f = random(100);
	if (_f < 30)      { var _s1 = _syl(_c, _cl, _v); _nm = _s1 + _s1; }
	else if (_f < 62) _nm = _syl(_c, _cl, _v) + _syl(_c, _cl, _v);
	else if (_f < 82) _nm = _syl(_c, _cl, _v) + _syl(_c, _cl, _v) + _syl(_c, _cl, _v);
	else if (_f < 92) { var _s2 = _syl(_c, _cl, _v); _nm = _syl(_c, _cl, _v) + _s2 + _s2; }
	else              { var _s3 = _syl(_c, _cl, _v); _nm = _s3 + "-" + _s3; }
	if (random(1) < .25) _nm += _e[irandom(array_length(_e) - 1)];
	return _nm;
}
