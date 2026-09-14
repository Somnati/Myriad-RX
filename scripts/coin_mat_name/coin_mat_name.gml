/// @description coin_mat_name() - the display name of the chosen coin
/// finish (settings > visuals), off the dice roster.
function coin_mat_name() {
	var _t = dice_mat_config();
	var _id = variable_global_exists("coin_mat") ? g.coin_mat : "gold";
	for (var _i = 0; _i < array_length(_t); _i++)
		if (_t[_i].id == _id) return _t[_i].name;
	return "gold";
}
