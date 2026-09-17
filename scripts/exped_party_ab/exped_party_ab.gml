/// @description exped_party_ab(trip, [alive_only]) -> the crew's ROAD lanes summed
/// (pace / sure / night / weather / finds / loot / gold, the second roster's
/// scav / pick / rooms / quest / notes and the auras): what the
/// abilities of everyone walking do for the trip as a whole (2026-09-17).
/// alive_only (default true) = the ones still up; false = the whole crew
/// (the pay at the door counts everyone who went)
function exped_party_ab(_tr, _alive = true) {
	var _o = { pace : 0, sure : 0, night : 0, weather : 0, finds : 0, loot : 0, gold : 0,
		scav : 0, pick : 0, rooms : 0, quest : 0, notes : 0,   // (the second roster, 2026-09-17)
		aura_atk : 0, aura_def : 0, aura_hit : 0, aura_luck : 0, aura_heal : 0, aura_xp : 0, aura_potion : 0 };
	for (var _k = 0; _k < array_length(_tr.sids); _k++) {
		if (_alive && _k < array_length(_tr.hp) && _tr.hp[_k] <= 0) continue;
		var _sp = exped_sprite(_tr.sids[_k]);
		if (is_undefined(_sp)) continue;
		var _ab = sprite_ab(_sp);
		_o.pace += _ab.pace; _o.sure += _ab.sure; _o.night += _ab.night; _o.weather += _ab.weather;
		_o.finds += _ab.finds; _o.loot += _ab.loot; _o.gold += _ab.gold;
		_o.scav += _ab.scav; _o.pick += _ab.pick; _o.rooms += _ab.rooms; _o.quest += _ab.quest; _o.notes += _ab.notes;
		_o.aura_atk += _ab.aura_atk; _o.aura_def += _ab.aura_def; _o.aura_hit += _ab.aura_hit; _o.aura_luck += _ab.aura_luck;
		_o.aura_heal += _ab.aura_heal; _o.aura_xp += _ab.aura_xp; _o.aura_potion += _ab.aura_potion;
	}
	return _o;
}
