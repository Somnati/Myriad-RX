/// @description cbt_heal(fight, target, amount, [label]) -> hp restored
/// Every skill that heals routes through here (the tech demo's
/// combat_heal): clamped to the possibly ERODED max hp - attrition is
/// permanent within a fight by design. label "" = a silent support tick.
function cbt_heal(_f, _t, _amt, _label = "", _u = undefined) {
	if (_t.hp <= 0) return 0;   // the down stay down (bug hunt 2026-09-15: a drain's leech after a counter had killed the drainer stood it back up)
	// A SKILL'S HEAL (the caster given, 2026-09-17): gentle hands on the
	// caster's side, a good patient on the target's
	if (!is_undefined(_u)) {
		if (is_struct(_u[$ "ab"]) && _u.ab.heal_pow > 0) _amt *= 1 + _u.ab.heal_pow / 100;
		if (is_struct(_t[$ "ab"]) && _t.ab.heal_recv > 0) _amt *= 1 + _t.ab.heal_recv / 100;
	}
	_amt = max(0, round(_amt * 10) / 10);
	var _before = _t.hp;
	_t.hp = min(_t.maxhp, _t.hp + _amt);
	var _got = round((_t.hp - _before) * 10) / 10;
	if (_got <= 0) return 0;
	if (_label != "") {
		var _tx = _t.name + " recovered " + string(_got) + " (" + _label + ")";
		cbt_log(_f, _tx);
		cbt_film(_f, _t, 0, _tx);
	}
	return _got;
}
