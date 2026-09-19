/// @description mood_unpack(sprite, s) - the mood rebuilt from mood_pack's field (a sprite saved before moods, or at rest, gets none) (q261)
function mood_unpack(_sp, _s) {
	_sp.mood = undefined;
	if (!is_string(_s) || _s == "") return;
	var _f = string_split(_s, "~");
	if (array_length(_f) < 9) return;
	var _m = { v : clamp(real(_f[0]), -1, 1), a : clamp(real(_f[1]), 0, 1), e : clamp(real(_f[2]), 0, 1), why : _f[3], why_t : g[$ "time_played_active"] ?? 0,
	           lost : undefined, pokes : real(_f[7]), pday : real(_f[8]) };
	if (_f[4] != "" && real(_f[6]) > .08) _m.lost = { name : _f[4], bond : real(_f[5]), g : clamp(real(_f[6]), 0, 1), t : 0 };
	_sp.mood = _m;
}
