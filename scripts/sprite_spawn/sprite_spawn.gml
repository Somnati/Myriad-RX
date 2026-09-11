/// @description sprite_spawn([job]) - a new sprite, rolled: a cute name
/// from soft syllables (often doubled - "momo", "bibi"), a colour from
/// the bright half of the wheel, a personality off the roster. Seated
/// somewhere in the lower third of the money room. Returns the struct.
/// @param [job]   "tap"
function sprite_spawn(_job = "tap") {
	sprites_init();
	// the name: consonant + vowel syllables from a soft set, two or
	// three of them, doubled a third of the time
	var _c = ["b", "m", "p", "n", "l", "d", "z", "k", "w", "t", "f", "j"];
	var _v = ["a", "i", "o", "u", "e", "oo", "ee"];
	var _syl = function(_c, _v) { return _c[irandom(array_length(_c) - 1)] + _v[irandom(array_length(_v) - 1)]; };
	var _nm;
	if (random(1) < .35) { var _s1 = _syl(_c, _v); _nm = _s1 + _s1; }
	else {
		_nm = _syl(_c, _v) + _syl(_c, _v);
		if (random(1) < .3) _nm += _syl(_c, _v);
	}
	if (random(1) < .25) _nm += choose("t", "n", "p", "k");
	var _pl = sprite_personalities();
	var _sp = {
		id     : g.sprite_seq++,
		name   : _nm,
		col    : make_colour_hsv(random(255), random_range(150, 220), random_range(225, 255)),
		pers   : irandom(array_length(_pl) - 1),
		job    : _job,
		taps   : 0,
		fx     : random_range(.15, .85),
		fy     : random_range(.62, .86),
		away   : 0,
		asleep : false,
		acc    : 0,
	};
	array_push(g.sprites, _sp);
	save_mark_dirty();
	return _sp;
}
