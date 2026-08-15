/// @description stats_v2_line([name], [value], [c1], [c2], [help]) -
/// one row of the statistics_v2 list. no args = a blank spacer row.
/// runs in the controller's scope during a rebuild (the declarative-
/// replay pattern: content scripts ARE the list).
/// lines have a stable KEY (folder path + name) - favorites, change
/// pulses and help popups all hang off it, so a line keeps its
/// identity across rebuilds. pass `help` to make the row tappable
/// for an explanation popup.
function stats_v2_line(_name = "", _val = "", _c1 = -1, _c2 = -1, _help = "") {
	if (_c1 == -1) _c1 = rgb(195, 205, 235);
	if (_c2 == -1) _c2 = rgb(238, 210, 130);
	var _key = _fpath + "/" + _name;
	_val = string(_val);

	// full-tree collections run even inside CLOSED folders (the build
	// always walks everything now): the clipboard dump, and change
	// detection so a stat that moved while hidden still pulses when
	// its folder reopens
	if (_name != "") {
		array_push(dump, { name : _name, val : _val, dep : _fdepth });
		var _pv = __prev[$ _key];
		if (!is_undefined(_pv) && _pv != _val) __pulse[$ _key] = __tick;
		__prev[$ _key] = _val;
	}

	var _fav = (g.stats_fav[$ _key] ?? false);
	var _row = {
		kind : 0, // plain line
		name : _name,
		val  : _val,
		c1   : _c1,
		c2   : _c2,
		fdep : _fdepth,
		path : "",
		key  : _key,
		help : _help,
		fav  : _fav,
		data : -1,
		open : false,
		inst : noone,
		span : 1,
	};

	// search mode: the list is a FLAT set of matching lines from the
	// whole tree - open state is ignored, that's the point of search
	if (search != "") {
		if (_name == "") return;
		if (string_pos(string_lower(search), string_lower(_name)) > 0) {
			_row.fdep = 0;
			array_push(rows, _row);
		}
		return;
	}

	// favorited lines get a COPY pinned into the top section, whether
	// or not their home folder is open
	if (_fav) {
		var _pin = variable_clone(_row);
		_pin.fdep = 1;
		array_push(fav_rows, _pin);
	}

	if (_fhid == 0) array_push(rows, _row);
}
