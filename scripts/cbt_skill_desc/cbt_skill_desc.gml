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
			case "reform":  _kind = 25; break;
			case "bulwark": _kind = 9; break;
			case "barrier": _kind = 9; break;
			case "manaward": _kind = 10; break;
			case "regrowth": _kind = 13; break;
			case "smoke":   _kind = 14; break;
			case "rage":    _kind = 15; break;
			case "lunge":   _kind = 16; break;
			case "flurry":  _kind = 17; break;
			case "pilfer":  _kind = 18; break;
			case "song":    _kind = 22; break;
			case "smite":   _kind = 23; break;
			case "iai":     _kind = 24; break;
			case "hex":     _kind = 7; break;
		}
	}
	var _pct = string(round(cbt_balance().barrier_pct * 100)) + "%";
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
			array_push(_out, "x" + string_format(_mult, 1, 1) + " damage, and " + (((_s[$ "ail"] ?? "") == "poison") ? "the venom: 4% of their max hp each of their turns, three turns" : "the chill: they act at 60% pace for three turns"));
			array_push(_out, "reached for on a big target that does not have it yet");
			break;
		case 6:
			array_push(_out, "a blessing on " + _tg + ": " + (((_s[$ "buf"] ?? "") == "haste") ? "haste - they act at 125% pace" : ("their " + string_delete(_s[$ "buf"] ?? "buf_atk", 1, 4) + " up a quarter")) + ", three of their turns; it lifts the matching nerf instead if one is on them");
			array_push(_out, "reached for on someone who will live to use it");
			break;
		case 7:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " magic damage, and their " + string_delete(_s[$ "nerf"] ?? "nerf_atk", 1, 5) + " down a quarter for three of their turns; it undoes the matching buff instead if one is on them");
			array_push(_out, "reached for against a big stat, or a blessed foe");
			break;
		case 8:
			array_push(_out, "heals " + _tg + " " + string(round(_healp * 100)) + "% and strips every dark effect: the nerfs, the mark, the venom, the slow");
			array_push(_out, "reached for only when there is something to strip");
			break;
		case 9:
			array_push(_out, "a barrier on " + _tg + ": blows land " + _pct + " lighter for three of their turns; it lifts a breach");
			array_push(_out, "reached for when the enemies swing rather than cast");
			break;
		case 10:
			array_push(_out, "a ward on " + _tg + ": spells land " + _pct + " lighter for three of their turns; it lifts an unwarding");
			array_push(_out, "reached for when the enemies cast rather than swing");
			break;
		case 11:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " damage, and their guard is breached: blows land " + _pct + " heavier for three turns; it tears a barrier");
			array_push(_out, "reached for against an armoured foe, or a shielded one");
			break;
		case 12:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " magic damage, and they are laid open: spells land " + _pct + " heavier for three turns; it tears a ward");
			array_push(_out, "reached for against a foe with resistance to spare, or a warded one");
			break;
		case 13:
			array_push(_out, "heals " + _tg + " " + string(round(_healp * 100)) + "%, then " + string(round(cbt_balance().regen_pct * 100)) + "% more each of their turns for three");
			array_push(_out, "reached for on someone hurt who has no mending running");
			break;
		case 14:
			array_push(_out, "the user slips into the smoke: half the chance to be hit, three of its turns");
			array_push(_out, "reached for when hurt, the more foes are up");
			break;
		case 15:
			array_push(_out, "the user's atk up a quarter and its def down a quarter, three turns - a trade");
			array_push(_out, "reached for while there is health to spend");
			break;
		case 16:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " damage through " + string(round((_s[$ "pierce"] ?? .5) * 100)) + "% less of their armour");
			array_push(_out, "reached for against the armoured");
			break;
		case 17:
			array_push(_out, "two blows of x" + string_format(_mult, 1, 1) + " each, the second only if the first left them standing");
			array_push(_out, "reached for against the lightly armoured, or one nearly down");
			break;
		case 18:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " damage, and " + string(_s[$ "drainmp"] ?? 3) + " of their mp drawn into the user's");
			array_push(_out, "reached for when the user runs low and the target has mp to lose");
			break;
		case 19:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " magic damage on EVERY enemy standing");
			array_push(_out, "reached for against two or more, less the more they resist it");
			break;
		case 20:
			array_push(_out, "heals EVERY ally " + string(round(_healp * 100)) + "% of their max hp");
			array_push(_out, "reached for by how much health the whole crew is missing");
			break;
		case 21:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " magic damage, and no magic skill from them for three of their turns");
			array_push(_out, "reached for against a caster - a brute barely notices");
			break;
		case 22:
			array_push(_out, "a blessing on EVERY ally: " + (((_s[$ "buf"] ?? "") == "haste") ? "haste - they act at 125% pace" : ("their " + string_delete(_s[$ "buf"] ?? "buf_atk", 1, 4) + " up a quarter")) + ", three turns");
			array_push(_out, "reached for when two or more allies lack it");
			break;
		case 23:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " magic damage that reads no element - light's own; half again on the undead");
			array_push(_out, "reached for against the dead, and where armour outweighs resistance");
			break;
		case 24:
			array_push(_out, "x" + string_format(_mult, 1, 1) + " damage with " + string(_s[$ "crit"] ?? 30) + " points more chance to crit - one draw, one cut");
			array_push(_out, "reached for the deadlier the user's crits are, and on the wounded");
			break;
		case 25:
			array_push(_out, "heals the user 40% of its max hp");
			array_push(_out, "the emergency button: only below 35% health");
			break;
		default:
			array_push(_out, "does something. nobody wrote down what");
			break;
	}
	// the element or the school (2026-09-17)
	var _sel = _s[$ "elem"] ?? "", _ssc = _s[$ "school"] ?? "";
	if (_sel != "") { var _sei = cbt_elem_info(_sel); array_push(_out, _sei.name + ": through the target's " + _sei.name + " resistance" + ((_sel == "fire") ? ", and fire hits a tenth harder" : "")); }
	else if (_ssc == "light") array_push(_out, "light: a mending, a blessing - it cancels dark");
	else if (_ssc == "dark") array_push(_out, "dark: flat damage, it feeds and it weakens - it cancels light");
	array_push(_out, "mp: a landed basic attack builds 1 (2 on a clean hit or a crit); a fight opens at half");
	return _out;
}
