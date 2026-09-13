/// @description exped_retire(sid) - a sprite leaves the roster for good
/// (the swap half of the recruit moment, exped_collect). Its name goes
/// on g.exped.retired (twelve kept) so the diary can bring it up; its
/// bonds go; its body in the money room goes. Returns the name, or "".
function exped_retire(_sid) {
	exped_init();
	var _name = "";
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _s = g.sprites[_i];
		if (_s.id != _sid) continue;
		_name = _s.name;
		if (variable_struct_exists(_s, "view") && instance_exists(_s.view)) instance_destroy(_s.view);
		array_delete(g.sprites, _i, 1);
		break;
	}
	if (_name == "") return "";
	array_push(g.exped.retired, _name);
	while (array_length(g.exped.retired) > 12) array_delete(g.exped.retired, 0, 1);
	var _k = variable_struct_get_names(g.bonds);
	for (var _i = 0; _i < array_length(_k); _i++) {
		var _ab = string_split(_k[_i], ":");
		if (array_length(_ab) == 2 && (real(_ab[0]) == _sid || real(_ab[1]) == _sid))
			variable_struct_remove(g.bonds, _k[_i]);
	}
	save_mark_dirty();
	return _name;
}
