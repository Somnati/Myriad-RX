/// @description stats_v2_toggle(name, "global_key", [c1]) - an
/// interactive row that flips a GLOBAL flag when tapped (the Myriad
/// statistics toggles, minus the display-text dispatch: the row
/// carries its target as DATA - the key - so renaming the label can
/// never break the click).
function stats_v2_toggle(_name, _key, _c1 = -1) {
	if (_c1 == -1) _c1 = rgb(195, 205, 235);
	var _on = false;
	if (variable_global_exists(_key)) _on = (variable_global_get(_key) == true);
	array_push(dump, { name : _name, val : _on ? "on" : "off", dep : _fdepth });
	var _row = {
		kind : 4, // toggle
		name : _name,
		val  : _key, // the target global's name
		c1   : _c1,
		c2   : _on ? c_gold : c_gray,
		fdep : _fdepth,
		path : "",
		key  : _fpath + "/" + _name,
		help : "",
		fav  : false,
		data : -1,
		open : _on, // current state rides here
		inst : noone,
		span : 1,
	};
	if (search != "") {
		if (string_pos(string_lower(search), string_lower(_name)) > 0) {
			_row.fdep = 0;
			array_push(rows, _row);
		}
		return;
	}
	if (_fhid == 0) array_push(rows, _row);
}
