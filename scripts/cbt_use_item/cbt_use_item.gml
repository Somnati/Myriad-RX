/// @description cbt_use_item(fight, user, item, target) -> true when it did something: A POTION BY HAND (q246, the arena's item plan) - the user's item { kind, size, name } on the target: hp (a red one: four tenths, a big one eight), mp (half, a big one all), antidote (the ailments off); the item is taken from user.items when it is there (the arena's copies - a trip's pocket is exped_drink's, never touched here)
function cbt_use_item(_f, _u, _it, _t) {
	if (!is_struct(_it) || !is_struct(_t)) return false;
	var _did = false, _tx = "";
	if (_it.kind == "hp" && _t.hp > 0) { var _heal = _t.maxhp * ((_it.size >= 2) ? .8 : .4); _t.hp = min(_t.maxhp, _t.hp + _heal); _tx = _u.name + " gives " + ((_t == _u) ? "" : (_t.name + " ")) + "the " + _it.name + " - " + string(round(_heal)) + " back"; _did = true; }
	else if (_it.kind == "mp" && _t.hp > 0 && _t.maxmp > 0) { var _mp = (_it.size >= 2) ? _t.maxmp : ceil(_t.maxmp * .5); _t.mp = min(_t.maxmp, _t.mp + _mp); _tx = _u.name + " gives " + ((_t == _u) ? "" : (_t.name + " ")) + "the " + _it.name + " - the hum comes back"; _did = true; }
	else if (_it.kind == "antidote" && _t.hp > 0) { if (is_struct(_t[$ "ail"])) { _t.ail.poison = 0; _t.ail.slow = 0; _t.ail.leech = 0; } _t.leecher = undefined; _tx = _u.name + " gives " + ((_t == _u) ? "" : (_t.name + " ")) + "the antidote - clear-headed again"; _did = true; }
	if (!_did) return false;
	if (is_array(_u[$ "items"])) for (var _i = 0; _i < array_length(_u.items); _i++) if (_u.items[_i] == _it) { array_delete(_u.items, _i, 1); break; }
	cbt_log(_f, _tx); cbt_film(_f, undefined, 0, _tx);
	return true;
}
