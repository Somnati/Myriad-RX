/// @description cbt_skill_desc(skill) -> [lines] - what a skill does, in words (the sheet's popup)
/// The library's six by name, the generated ones by template (cbt_skill_gen:
/// 0 heavy strike, 1 drain, 2 heal, 3 stagger, 4 heavy spell), with the
/// rolled numbers, and WHEN the ai reaches for it (its ai_score, in words).
function cbt_skill_desc(_s) {
	var _out = [];
	var _lane = _s.magic ? "magical (int vs res)" : "physical (atk vs def)";
	var _tg = (_s.targ == "enemy") ? "an enemy" : ((_s.targ == "ally") ? "an ally (or itself)" : "itself");
	array_push(_out, string(_s.cost) + " mp  -  " + _lane + "  -  on " + _tg);
	var _mult = _s[$ "mult"] ?? 0, _healp = _s[$ "healp"] ?? 0, _leech = _s[$ "leech"] ?? 0, _stag = _s[$ "stag"] ?? 0;
	var _kind = _s[$ "tmpl"] ?? -1;
	if (_kind < 0) {
		switch (_s.name) {
			case "strike":  _kind = 0; break;
			case "drain":   _kind = 1; break;
			case "mend":    _kind = 2; break;
			case "concuss": _kind = 3; break;
			case "bolt":    _kind = 4; break;
			case "reform":  _kind = 5; break;
		}
	}
	switch (_kind) {
		case 0:
			array_push(_out, "a heavy blow: x" + string_format(_mult, 1, 1) + " damage through the hit spectrum");
			array_push(_out, "reached for against an armoured target, or one nearly down");
			break;
		case 1:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " magic damage, and the user heals " + string(round(_leech * 100)) + "% of what landed");
			array_push(_out, "reached for the more hurt the user is");
			break;
		case 2:
			array_push(_out, "heals " + _tg + " for " + string(round(_healp * 100)) + "% of their max hp (never past an eroded max)");
			array_push(_out, "reached for by how much health is missing - triage");
			break;
		case 3:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " damage, and the target is knocked " + string(round(_stag * 100)) + "% of a turn back on the order");
			array_push(_out, "reached for on a fast foe about to act");
			break;
		case 4:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " magic damage: it hits where the armour is not");
			array_push(_out, "reached for when a target's armour outweighs its resistance");
			break;
		case 5:
			array_push(_out, "heals the user 40% of its max hp");
			array_push(_out, "the emergency button: only below 35% health");
			break;
		default:
			array_push(_out, "does something. nobody wrote down what");
			break;
	}
	array_push(_out, "mp: a landed basic attack builds 1 (2 on a clean hit or a crit); a fight opens at half");
	return _out;
}
