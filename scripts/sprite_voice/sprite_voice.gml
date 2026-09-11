/// @description sprite_voice(s, kind) - a sprite's noise. ONE PLACE
/// (his note, 2026-09-11: "i need to go find some cute chirping sound
/// effects"): when the chirps land, put them in the pools below and
/// every sprite has a voice. Until then it is snd_pop, pitched by the
/// sprite - each one's own pitch off its id, a hair higher for the
/// eager ones - so two sprites already sound like two sprites.
/// @param s      the struct
/// @param kind   "poke" / "tap" / "wake" / "sleep"
function sprite_voice(_s, _kind) {
	// >>> THE CHIRPS GO HERE: one array per kind, any length. A pool
	// >>> of one is fine; an empty one falls back to the pop.
	var _pool = [];
	switch (_kind) {
		case "poke":  _pool = []; break;   // e.g. [snd_chirp1, snd_chirp2]
		case "tap":   _pool = []; break;
		case "wake":  _pool = []; break;
		case "sleep": _pool = []; break;
	}
	// the sprite's own pitch: a stable roll off its id, in a cute band
	var _seed = (_s.id * 2654435761) mod 1000;
	var _base = 1.25 + (_seed / 1000) * .5;
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(_s.pers, 0, array_length(_pl) - 1)];
	_base *= lerp(.92, 1.08, clamp((_p.pace - .8) / .5, 0, 1));
	var _vol = (_kind == "tap") ? .18 : .45;
	if (array_length(_pool) > 0) {
		var _snd = _pool[irandom(array_length(_pool) - 1)];
		play_sound_ext(_snd, _base * .95, _base * 1.05, _vol, 1);
		return;
	}
	if (_kind == "tap") return;   // no pop per tap - it would be a lot of pops
	play_sound_ext(snd_pop, _base, _base + .3, _vol, 1);
}
