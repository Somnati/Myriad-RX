/// @description ability_score(sprite, ability) -> how much this sprite
/// wants it, by its class's shape (his ask, 2026-09-17: "the sprite to
/// pick the best one for its class/stats"). A stat lane is worth its
/// number times the class's weight in that stat (a warrior rates brawn,
/// a mage rates bookish); the rest carry fixed weights leaned by whether
/// the class fights with blows or spells. A higher tier tips it. Every
/// lane of the big roster (2026-09-17) is weighed here.
function ability_score(_sp, _a) {
	var _sh = sprite_sheet(_sp), _c = sprite_classes()[_sh.cls];
	var _ln = _a.cfg.lane, _v = _a.val;
	var _phys = (_c.shape.atk >= _c.shape.mag);
	var _w = 0;
	switch (_ln) {
		case "hp": _w = _c.shape.hp / 6; break;
		case "mp": _w = _c.shape.mp / 8; break;
		case "atk": _w = _c.shape.atk / 6; break;
		case "mag": _w = _c.shape.mag / 6; break;
		case "def": _w = _c.shape.def / 6; break;
		case "mdef": _w = _c.shape.mdef / 6; break;
		case "spd": _w = _c.shape.spd / 6; break;
		case "hit": _w = _c.shape.hit / 6; break;
		case "crit": _w = .9 + _c.crit / 10; break;
		case "cnt": _w = .5 + _c.cnt / 15; break;
		case "luck": _w = 4; break;
		case "res_fire": case "res_water": case "res_nature": _w = .5; break;
		case "res_all": _w = 1.3; break;
		case "immune_poison": case "immune_slow": case "immune_leech": _w = 5; break;
		case "immune_crit": _w = 5; break;
		case "ail_poison": case "ail_slow": _w = _phys ? .4 : .15; break;
		case "low_atk": _w = _phys ? .35 : .15; break;
		case "boss": _w = .5; break;
		case "xp": _w = .45; break;
		case "tic": _w = .9; break;
		case "life": _w = _phys ? .7 : .4; break;
		case "elemdmg": _w = _phys ? .2 : .7; break;
		case "regen": _w = 3; break;
		case "once_more": _w = 12; break;
		case "eva": _w = 1.6; break;
		case "mp0": _w = _phys ? .1 : .3; break;
		case "potion": _w = .25; break;
		case "pace": _w = .5; break;
		case "finds": _w = .5; break;
		case "inn": _w = 3; break;
		case "haggle": _w = 3; break;
		case "bonds": _w = .1; break;
		case "vs_full": _w = .35; break;
		case "vs_low": _w = .4; break;
		case "vs_ail": _w = .35; break;
		case "vs_undead": _w = .2; break;
		case "vs_slime": _w = .15; break;
		case "low_def": _w = .25; break;
		case "hi_def": _w = .3; break;
		case "low_eva": _w = .2; break;
		case "crit_dmg": _w = _phys ? .35 : .25; break;
		case "low_crit_dmg": _w = .1; break;
		case "low_crit": _w = .4; break;
		case "cnt_pow": _w = .2 + _c.cnt / 30; break;
		case "cnt_crit": _w = .3; break;
		case "stagger": _w = .15; break;
		case "steady": _w = .15; break;
		case "mp_gain": _w = _phys ? .2 : .35; break;
		case "mp_haste": _w = 1.2; break;
		case "mp_rage": _w = _phys ? .3 : .5; break;
		case "vaccine": _w = .15; break;
		case "sure": _w = .1; break;
		case "night": _w = 3; break;
		case "weather": _w = 3; break;
		case "hazard": _w = 4; break;
		case "wander": _w = 2; break;
		case "low_xp": _w = .05; break;
		case "frugal": _w = _phys ? .2 : .4; break;
		case "heal_pow": _w = _phys ? .1 : .3; break;
		case "heal_recv": _w = .2; break;
		case "rest_hp": _w = .4; break;
		case "rest": _w = .04; break;
		case "gold": _w = .3; break;
		case "loot": _w = 3; break;
		case "first": _w = .3; break;
		case "pierce": _w = _phys ? .5 : .2; break;
		case "guard": _w = .6; break;
		case "low_guard": _w = .15; break;
		case "dark_pow": _w = _phys ? .1 : .35; break;
		case "thick": _w = 1.2; break;
		case "absorb": _w = .4; break;
		case "kill_heal": _w = .4; break;
		case "kill_mp": _w = _phys ? .2 : .35; break;
		case "ail_dur": _w = 3; break;
		case "throes": _w = 4; break;
		case "momentum": _w = 1; break;
		case "underdog": _w = .4; break;
		case "salvo": _w = _phys ? .2 : .35; break;
		case "ruse": _w = _phys ? .15 : .3; break;
	}
	var _s = _v * _w;
	if (variable_struct_exists(_a.cfg, "also")) _s *= 1.6;
	if (variable_struct_exists(_a.cfg, "cost")) _s *= .85;
	return _s + _a.tier * 1.5;
}
