/// @description ability_score(sprite, ability) -> how much this sprite
/// wants it, by its class's shape (his ask, 2026-09-17: "the sprite to
/// pick the best one for its class/stats"). A stat lane is worth its
/// number times the class's weight in that stat (a warrior rates brawn,
/// a mage rates bookish); the rest carry fixed weights leaned by whether
/// the class fights with blows or spells. A higher tier tips it.
function ability_score(_sp, _a) {
	var _sh = sprite_sheet(_sp), _c = sprite_classes()[_sh.cls];
	var _ln = _a.cfg.lane, _v = _a.val;
	var _phys = (_c.shape.atk >= _c.shape.mag);
	var _w = 0;
	switch (_ln) {
		case "hp":   _w = _c.shape.hp / 6; break;
		case "atk":  _w = _c.shape.atk / 6; break;
		case "mag":  _w = _c.shape.mag / 6; break;
		case "def":  _w = _c.shape.def / 6; break;
		case "mdef": _w = _c.shape.mdef / 6; break;
		case "spd":  _w = _c.shape.spd / 6; break;
		case "hit":  _w = _c.shape.hit / 6; break;
		case "crit": _w = .9 + _c.crit / 10; break;
		case "cnt":  _w = .5 + _c.cnt / 15; break;
		case "luck": _w = 4; break;
		case "res_fire": case "res_water": case "res_nature": _w = .5; break;
		case "res_all": _w = 1.3; break;
		case "immune_poison": case "immune_slow": case "immune_leech": _w = 5; break;
		case "ail_poison": case "ail_slow": _w = _phys ? .4 : .15; break;
		case "low_atk": _w = _phys ? .35 : .15; break;
		case "boss":    _w = .5; break;
		case "xp":      _w = .45; break;
		case "tic":     _w = .9; break;
		case "life":    _w = _phys ? .7 : .4; break;
		case "elemdmg": _w = _phys ? .2 : .7; break;
		case "regen":   _w = 3; break;
		case "undying": _w = 9; break;
	}
	var _s = _v * _w;
	if (variable_struct_exists(_a.cfg, "also")) _s *= 1.6;
	if (variable_struct_exists(_a.cfg, "cost")) _s *= .85;
	return _s + _a.tier * 1.5;
}
