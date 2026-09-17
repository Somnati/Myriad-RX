/// @description ability_effects(list) -> the summed lanes of a list of
/// abilities (ability_gen's structs), the shape every pawn carries as `ab`.
/// Every numeric lane is a field here (the big roster, 2026-09-17 - see
/// ability_lane_desc for what each means); the resistances are a table,
/// the immunities a list of tags, the bite one ailment with its chance,
/// once more a flag.
function ability_effects(_list) {
	var _o = {
		hp : 0, mp : 0, atk : 0, mag : 0, def : 0, mdef : 0, spd : 0, hit : 0,
		crit : 0, cnt : 0, luck : 0, low_atk : 0, boss : 0, xp : 0, tic : 0, life : 0,
		elemdmg : 0, regen : 0, eva : 0, mp0 : 0, potion : 0, pace : 0, finds : 0, inn : 0,
		haggle : 0, bonds : 0, vs_full : 0, vs_low : 0, vs_ail : 0, vs_undead : 0, vs_slime : 0, low_def : 0,
		hi_def : 0, low_eva : 0, crit_dmg : 0, low_crit_dmg : 0, low_crit : 0, cnt_pow : 0, cnt_crit : 0, stagger : 0,
		steady : 0, mp_gain : 0, mp_haste : 0, mp_rage : 0, vaccine : 0, sure : 0, night : 0, weather : 0,
		hazard : 0, wander : 0, low_xp : 0, frugal : 0, heal_pow : 0, heal_recv : 0, rest_hp : 0, rest : 0,
		gold : 0, loot : 0, first : 0, pierce : 0, taken : 0, guard : 0, low_guard : 0, dark_pow : 0,
		thick : 0, absorb : 0, kill_heal : 0, kill_mp : 0, ail_dur : 0, bleed : 0, graze : 0, throes : 0,
		momentum : 0, underdog : 0, salvo : 0, ruse : 0,
		res : { fire : 0, water : 0, nature : 0 },
		immune : [], ail : "", ailc : 0, once_more : false,
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
			case "immune_poison": case "immune_slow": case "immune_leech": case "immune_crit": array_push(_o.immune, string_delete(_ln, 1, 7)); break;
			case "ail_poison": case "ail_slow":
				// (two bites: the stronger chance wins, one ailment)
				if (_v > _o.ailc) { _o.ail = string_delete(_ln, 1, 4); _o.ailc = _v; }
				break;
			case "once_more": _o.once_more = true; break;
			default: if (variable_struct_exists(_o, _ln)) _o[$ _ln] += _v; break;
		}
		if (variable_struct_exists(_a.cfg, "also") && variable_struct_exists(_o, _a.cfg.also)) _o[$ _a.cfg.also] += _v;   // (`also`, not `pair` - pair is the house macro for event_inherited)
		if (variable_struct_exists(_a.cfg, "cost")) _o[$ _a.cfg.cost.lane] += _a.cfg.cost.v;
	}
	return _o;
}
