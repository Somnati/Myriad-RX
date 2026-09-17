/// @description ability_line(ability) -> its one-line readout, the lane
/// named: "+4.8% atk", "+7 fire res", "14% poison a bite", "+1 luck"
/// (his report, 2026-09-17: "+4.8% to what?")
function ability_line(_a) {
	var _ln = _a.cfg.lane, _d = ability_lane_desc(_ln);
	if (string_pos("immune", _ln) == 1 || _ln == "undying") return _a.cfg.name;
	var _v = _a.val;
	var _num = string_format(_v, 1, ((_v == round(_v)) ? 0 : 1));
	var _s = "";
	if (_ln == "ail_poison" || _ln == "ail_slow") _s = _num + "% " + _d.word;
	else if (_ln == "luck" || string_pos("res_", _ln) == 1) _s = ((_v >= 0) ? "+" : "") + _num + " " + _d.word;
	else if (_ln == "regen") _s = "+" + _num + "% " + _d.word;
	else _s = ((_v >= 0) ? "+" : "") + _num + "% " + _d.word;
	if (variable_struct_exists(_a.cfg, "also")) { var _d2 = ability_lane_desc(_a.cfg.also); _s += " and " + _d2.word; }
	if (variable_struct_exists(_a.cfg, "cost")) { var _d3 = ability_lane_desc(_a.cfg.cost.lane); _s += ", " + string(_a.cfg.cost.v) + "% " + _d3.word; }
	return _s;
}
