/// @description sprite_name_gen([hash]) -> a cute name off the ambient stream ("momo", "bibi", "klowen", "sha-sha", "tobbit") - or, given a hash, the one name that hash always makes
/// THE ONE NAME GENERATOR (the names pass, 2026-09-15): every sprite
/// (sprite_spawn) and everyone met on the road (exped_npc_name) is named
/// here. Soft syllables - a consonant (or, one time in six, a soft
/// cluster) and a vowel - in five shapes: doubled ("momo"), two, three, a
/// doubled tail ("tobobo"), a sung double ("bo-bo"); an ending one time
/// in four. Never a fixed list of names (his rule).
/// THE HASH MODE (2026-09-16, the leaders and the folk): with a hash, every
/// pick is hash_mix(hash, i) - no roll of the ambient stream, so it is
/// safe anywhere (inside a seeded deal too) and needs no cache or save:
/// the same hash is the same name forever. The stream mode's rolls are
/// untouched (the seeded names the papers, the rivals and the villains
/// made stay what they were).
function sprite_name_gen(_h = undefined) {
	static _c  = ["b", "m", "p", "n", "l", "d", "z", "k", "w", "t", "f", "j", "r", "s", "h", "v", "g", "y", "q"];
	static _cl = ["bl", "kl", "pl", "fl", "sh", "th", "ch", "br", "kr", "tw", "sn", "mb"];
	static _v  = ["a", "i", "o", "u", "e", "oo", "ee", "ai", "ou", "oa", "y", "ie"];
	static _e  = ["t", "n", "p", "k", "sh", "ll", "m", "s", "x", "ck", "ng", "bit"];
	if (!is_undefined(_h)) {
		var _syh = function(_c2, _cl2, _v2, _h2, _i) { return (((hash_mix(_h2, _i) mod 100) < 16) ? _cl2[hash_mix(_h2, _i + 1) mod array_length(_cl2)] : _c2[hash_mix(_h2, _i + 1) mod array_length(_c2)]) + _v2[hash_mix(_h2, _i + 2) mod array_length(_v2)]; };
		var _fh = hash_mix(_h, 0) mod 100, _nh;
		if (_fh < 30)      { var _t1 = _syh(_c, _cl, _v, _h, 10); _nh = _t1 + _t1; }
		else if (_fh < 62) _nh = _syh(_c, _cl, _v, _h, 10) + _syh(_c, _cl, _v, _h, 20);
		else if (_fh < 82) _nh = _syh(_c, _cl, _v, _h, 10) + _syh(_c, _cl, _v, _h, 20) + _syh(_c, _cl, _v, _h, 30);
		else if (_fh < 92) { var _t2 = _syh(_c, _cl, _v, _h, 20); _nh = _syh(_c, _cl, _v, _h, 10) + _t2 + _t2; }
		else               { var _t3 = _syh(_c, _cl, _v, _h, 10); _nh = _t3 + "-" + _t3; }
		if ((hash_mix(_h, 1) mod 100) < 25) _nh += _e[hash_mix(_h, 2) mod array_length(_e)];
		return _nh;
	}
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
