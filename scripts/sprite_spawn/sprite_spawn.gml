/// @description sprite_spawn([job]) - a new sprite, rolled: a cute name
/// from soft syllables (often doubled - "momo", "bibi"), a colour from
/// the bright half of the wheel, a personality off the roster. Seated
/// somewhere in the lower third of the money room. Returns the struct.
/// @param [job]   "tap"
function sprite_spawn(_job = "tap") {
	sprites_init();
	// the name: sprite_name_gen (the one generator - the names pass, 2026-09-15)
	var _nm = sprite_name_gen();
	var _pl = sprite_personalities();
	var _lk = sprite_looks();
	// THE RARITY (his ask, 2026-09-11): the house calculator, the
	// tiles' shape (.3 / .03 / 800), eight rungs - common .. ultimate.
	// g.sprite_rarity_rate is the lane a future upgrade raises
	if (!variable_global_exists("sprite_rarity_rate")) g.sprite_rarity_rate = 100;
	var _rar = clamp(calculate_rarity(luck_rate(g.sprite_rarity_rate), .3, .03, 800, 8), 0, 7);   // luck leans it
	// the material follows the rarity: commons are matte, the exotic
	// finishes are for the exotic ones
	var _mat = _lk.mat_by_rar[_rar];
	// two colours: the body, and a second a third of the wheel round
	// for the glass interior / the jelly's depth
	var _hue = random(255);
	var _sp = {
		id     : g.sprite_seq++,
		name   : _nm,
		col    : make_colour_hsv(_hue, random_range(150, 220), random_range(225, 255)),
		col2   : make_colour_hsv((_hue + random_range(50, 90)) mod 256, random_range(170, 230), random_range(160, 230)),
		eyes   : irandom(array_length(_lk.eyes) - 1),
		mat    : _mat,
		rar    : _rar,
		pers   : irandom(array_length(_pl) - 1),
		job    : _job,
		taps   : 0,
		fx     : random_range(.12, .88),   // anywhere in the room (his ask, 2026-09-13) -
		fy     : random_range(.20, .88),   // off the edges, under the header
		away   : 0,
		asleep : false,
		hpf : 1, mpf : 1, resting : false,   // hp / mp as fractions of the sheet's max, carried home from a trip; resting = asleep until whole
		// the diary's memory (exped_say's `need` gates): trips out, fights
		// won, routs, the last planet, trips in a row without a rout
		mem    : { trips : 0, wins : 0, routs : 0, last : "", streak : 0 },
		acc    : 0,
	};
	array_push(g.sprites, _sp);
	save_mark_dirty();
	return _sp;
}
