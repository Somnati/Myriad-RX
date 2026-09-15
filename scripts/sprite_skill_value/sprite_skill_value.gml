/// @description sprite_skill_value(sprite, skill) -> how much this class thinks of a skill
/// The class's own eye (sprite_classes.tmpls, first = the template it
/// likes best): a template it lists rates 1 / .8, one it does not .45;
/// times the skill's punch (its mult, or its heal twice over, or one).
/// What sprite_skill_learn compares when the sheet is full.
function sprite_skill_value(_sp, _sk) {
	var _c = sprite_classes()[sprite_sheet(_sp).cls];
	var _t = _sk[$ "tmpl"] ?? -1;
	var _pref = .45;
	for (var _i = 0; _i < array_length(_c.tmpls); _i++) if (_c.tmpls[_i] == _t) { _pref = (_i == 0) ? 1 : .8; break; }
	var _punch = 1;
	if ((_sk[$ "mult"] ?? 0) > 0) _punch = _sk.mult;
	else if ((_sk[$ "healp"] ?? 0) > 0) _punch = _sk.healp * 2.2;
	if ((_sk[$ "leech"] ?? 0) > 0) _punch += _sk.leech * .5;
	if ((_sk[$ "stag"] ?? 0) > 0) _punch += _sk.stag * .6;
	return _pref * _punch;
}
