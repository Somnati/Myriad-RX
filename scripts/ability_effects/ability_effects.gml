/// @description ability_effects(list) -> the summed lanes of a list of
/// abilities (ability_gen's structs), the shape every pawn carries as `ab`.
function ability_effects(_list) {
	var _o = {
		hp : 0, atk : 0, mag : 0, def : 0, mdef : 0, spd : 0, hit : 0,
		crit : 0, cnt : 0, luck : 0,
		res : { fire : 0, water : 0, nature : 0 },
		immune : [], ail : "", ailc : 0,
		low_atk : 0, boss : 0, xp : 0, tic : 0, life : 0, elemdmg : 0, regen : 0, undying : false,
	};
	for (var _i = 0; _i < array_length(_list); _i++) {
		var _a = _list[_i];
		if (!is_struct(_a)) continue;
		var _ln = _a.cfg.lane, _v = _a.val;
		switch (_ln) {
			case "res_fire":   _o.res.fire += _v; break;
			case "res_water":  _o.res.water += _v; break;
			case "res_nature": _o.res.nature += _v; break;
			case "res_all":    _o.res.fire += _v; _o.res.water += _v; _o.res.nature += _v; break;
			case "immune_poison": case "immune_slow": case "immune_leech": array_push(_o.immune, string_delete(_ln, 1, 7)); break;
			case "ail_poison": case "ail_slow":
				// (two bites: the stronger chance wins, one ailment)
				if (_v > _o.ailc) { _o.ail = string_delete(_ln, 1, 4); _o.ailc = _v; }
				break;
			case "undying": _o.undying = true; break;
			default: if (variable_struct_exists(_o, _ln)) _o[$ _ln] += _v; break;
		}
		if (variable_struct_exists(_a.cfg, "pair") && variable_struct_exists(_o, _a.cfg.pair)) _o[$ _a.cfg.pair] += _v;
		if (variable_struct_exists(_a.cfg, "cost")) _o[$ _a.cfg.cost.lane] += _a.cfg.cost.v;
	}
	return _o;
}
