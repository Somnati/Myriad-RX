/// @description stats_v2_cycle(name, "global_key", labels, [c1]) -
/// the toggle's multi-state sibling: the global holds an INDEX into
/// `labels`, tapping the row advances it (wrapping). same data-driven
/// contract as stats_v2_toggle - the row carries the key, never the
/// display text. initializes the global to 0 if it doesn't exist yet,
/// so content scripts can declare cycles without setgame wiring.
function stats_v2_cycle(_name, _key, _labels, _c1 = -1) {
	if (_c1 == -1) _c1 = rgb(195, 205, 235);
	if (!variable_global_exists(_key)) variable_global_set(_key, 0);
	var _n   = array_length(_labels);
	var _idx = clamp(variable_global_get(_key), 0, _n - 1);
	array_push(dump, { name : _name, val : _labels[_idx], dep : _fdepth });
	var _row = {
		kind : 5, // cycle
		name : _name,
		val  : _key, // the target global's name
		c1   : _c1,
		c2   : c_gold,
		fdep : _fdepth,
		path : "",
		key  : _fpath + "/" + _name,
		help : "",
		fav  : false,
		data : _labels,
		open : false,
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
