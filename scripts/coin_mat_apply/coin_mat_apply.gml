/// @description coin_mat_apply() - seat the chosen finish on the coin
/// (obj_coin's scope): tint, metal, iri off the DICE ROSTER
/// (dice_mat_config) by g.coin_mat - settings > visuals > coin
/// material, gold by default. "random" rolls like a die's.
function coin_mat_apply() {
	var _t = dice_mat_config();
	var _id = variable_global_exists("coin_mat") ? g.coin_mat : "gold";
	var _m = _t[1];
	for (var _i = 0; _i < array_length(_t); _i++)
		if (_t[_i].id == _id) { _m = _t[_i]; break; }
	mat_id = _m.id;
	if (_m.col < 0) {
		tint  = color_set_random();
		metal = .6 + random(.4);
		iri   = 0;
	} else {
		tint  = _m.col;
		metal = max(.75, _m.metal);   // a coin is always at least mostly metal
		iri   = _m.iri;
	}
}
