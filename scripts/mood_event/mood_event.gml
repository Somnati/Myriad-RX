/// @description mood_event(sprite, kind, [why], [mag]) - SOMETHING HAPPENED to the sprite: a push on its drives, shaped by its personality (q261)
///   rout        sad and keyed (the nervous and the shy x1.4 - shaken for days; the brave, grumpy and proud take it as ANGER: less sad, more keyed)
///   win         a little happy, a little keyed         streak      the third win running: cocky by the evening
///   buddy_down  a mate went down (the kind x1.3)       haul        home with something (the greedy x1.3)     empty  home with nothing
///   level       a level (the proud x1.3)               trip_end    the battery down by the trip's days (mag)
///   left        left behind while the others went (the eager, brave and curious: restless - keyed and a little sad; the rest hardly mind)
///   bond        a new mate (a grief heals faster)      poke        a poke in the money room (five a day count)
/// why = the reason the sheet shows ("routed at the Grey Tops"), kept three hours of playtime. Marks the save
function mood_event(_sp, _kind, _why = "", _mag = 1) {
	if (is_undefined(_sp)) return;
	var _m = mood_init(_sp), _pn = mood_pers(_sp);
	var _dv = 0, _da = 0, _de = 0;
	switch (_kind) {
		case "rout":
			if (_pn == "brave" || _pn == "grumpy" || _pn == "proud") { _dv = -.25; _da = .65; }
			else { _dv = -.5; _da = .5; if (_pn == "nervous" || _pn == "shy") _dv *= 1.4; }
			if (_pn == "sleepy") _da *= .5;
			break;
		case "win":        _dv = .1;  _da = .15; break;
		case "streak":     _dv = .3;  _da = .3;  break;
		case "buddy_down": _dv = -.3; _da = .4;  if (_pn == "kind") _dv *= 1.3; break;
		case "haul":       _dv = .4;  _da = .1;  if (_pn == "greedy") _dv *= 1.3; break;
		case "empty":      _dv = -.2; break;
		case "level":      _dv = .3;  _da = .2;  if (_pn == "proud") _dv *= 1.3; break;
		case "trip_end":   _de = -.25 - .05 * max(0, _mag); _mag = 1; break;
		case "left":       if (_pn == "eager" || _pn == "brave" || _pn == "curious") { _da = .25; _dv = -.1; } else _dv = -.03; break;
		case "bond":       _dv = .3; if (is_struct(_m.lost)) _m.lost.g *= .5; break;
		case "poke": {
			var _day = floor((g[$ "time_played_active"] ?? 0) / 86400);
			if (_m.pday != _day) { _m.pday = _day; _m.pokes = 0; }
			if (_m.pokes >= 5) return;
			_m.pokes += 1; _dv = .04;
		} break;
	}
	_m.v = clamp(_m.v + _dv * _mag, -1, 1);
	_m.a = clamp(_m.a + _da * _mag, 0, 1);
	_m.e = clamp(_m.e + _de, 0, 1);
	if (_why != "") { _m.why = _why; _m.why_t = g[$ "time_played_active"] ?? 0; }
	if (_kind != "poke") save_mark_dirty();
}
