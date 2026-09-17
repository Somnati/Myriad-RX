/// @description sprite_rate(sprite) -> taps a second at its job at home
/// The personality's work x pace over SPRITE_TAP_T, the rarity's pace, and
/// THE WORK LANES (the second roster, 2026-09-17): artisan on every job,
/// busy hands / fab hand / merge hand on theirs, the foreman's aura from
/// the OTHER awake workers (sprites_tick sums it into g.sprite_work_aura),
/// the homebody while any crew is out; lazy, the flaw, the other way.
function sprite_rate(_s) {
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(_s.pers, 0, array_length(_pl) - 1)];
	var _ab = sprite_ab(_s), _job = _s[$ "job"] ?? "tap";
	var _wm = 1 + _ab.work / 100;
	_wm *= 1 + ((_job == "tap") ? _ab.work_tap : ((_job == "fab") ? _ab.work_fab : _ab.work_merge)) / 100;
	_wm *= 1 + max(0, (g[$ "sprite_work_aura"] ?? 0) - _ab.work_aura) / 100;   // (the others' - not its own)
	if (_ab.home_alone > 0 && is_struct(g[$ "exped"]) && array_length(g.exped.trips) > 0) _wm *= 1 + _ab.home_alone / 100;
	return _p.work * _p.pace * (1 + SPRITE_RAR_PACE * (_s[$ "rar"] ?? 0)) * max(.1, _wm) / SPRITE_TAP_T;
}
