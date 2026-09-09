/// @description dice_mat_name() - the display name of the chosen dice
/// finish, for the settings row's current-value text.
///
/// A saved id that no longer exists in the roster reads as "random"
/// rather than as itself: retiring a finish must not leave a settings
/// row quoting a material the game cannot draw.
function dice_mat_name() {
	var _id = variable_global_exists("dice_mat") ? g.dice_mat : "random";
	var _t = dice_mat_config();
	for (var _i = 0; _i < array_length(_t); _i++)
		if (_t[_i].id == _id) return _t[_i].name;
	return _t[0].name;
}
