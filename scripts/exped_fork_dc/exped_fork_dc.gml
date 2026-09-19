/// @description exped_fork_dc(fork) -> the difficulty of the fork's check: THE LAND x THE WEATHER x THE NIGHT (q258)
/// A shortcut: the land's base (a pass 11, a marsh or the tundra 10, the
/// woods, the flats and the shore 9, hills 8) + the weather's word (rain
/// on a pass +5, snow +5 - but a FROZEN marsh walks, -4; fog +4, in the
/// woods +6; a storm +7, on the shore +8; wind +1) + the night (+3 - the
/// desert INVERTS: the night is the safe crossing, the day's heat the
/// risk). The way round a foe: 11 + half a level a level, LOWERED by the
/// weather that hides a crew (fog -4, a storm -3, rain -2, snow -1) and
/// the dark (-2). Clamped to the die's reach either way
function exped_fork_dc(_fk) {
	if (_fk.kind == "encounter") {
		var _d = 11 + max(0, (_fk[$ "lv"] ?? 1) - 1) * .5;
		switch (_fk.wx) { case "fog": _d -= 4; break; case "rain": _d -= 2; break; case "storm": _d -= 3; break; case "snow": _d -= 1; break; }
		if (_fk.night) _d -= 2;
		return round(clamp(_d, 4, 20));
	}
	var _b = 9;
	switch (_fk.land) { case "mountains": _b = 11; break; case "marsh": case "tundra": _b = 10; break; case "hills": _b = 8; break; }
	var _w = 0;
	switch (_fk.wx) {
		case "rain":  _w = (_fk.land == "mountains" || _fk.land == "hills") ? 5 : ((_fk.land == "marsh") ? 4 : 2); break;
		case "snow":  _w = (_fk.land == "marsh") ? -4 : 5; break;
		case "fog":   _w = (_fk.land == "forest") ? 6 : 4; break;
		case "storm": _w = (_fk.land == "coast") ? 8 : 7; break;
		case "wind":  _w = 1; break;
	}
	var _n = 0;
	if (_fk.land == "desert") _n = _fk.night ? -3 : 3;
	else if (_fk.night) _n = 3;
	return round(clamp(_b + _w + _n, 4, 22));
}
