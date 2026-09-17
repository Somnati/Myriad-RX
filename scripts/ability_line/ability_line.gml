/// @description ability_line(ability) -> its one-line readout: "+6.5% atk"
function ability_line(_a) {
	var _ln = _a.cfg.lane;
	if (string_pos("immune", _ln) == 1 || _ln == "undying") return _a.cfg.help;
	var _s = ((_a.val >= 0) ? "+" : "") + string_format(_a.val, 1, ((_a.val == round(_a.val)) ? 0 : 1)) + _a.cfg.unit;
	if (_ln == "ail_poison" || _ln == "ail_slow") _s = string_format(_a.val, 1, 0) + _a.cfg.unit + " " + string_delete(_ln, 1, 4);
	if (variable_struct_exists(_a.cfg, "cost")) _s += ", " + string(_a.cfg.cost.v) + "% " + _a.cfg.cost.lane;
	return _s;
}
