/// @description news_tick(dt) - every line of world news runs down by dt seconds of the expedition clock; at zero it is old news (q285)
function news_tick(_dt) {
	var _nw = g.exped[$ "news"];
	if (!is_array(_nw) || _dt <= 0) return;
	for (var _i = array_length(_nw) - 1; _i >= 0; _i--) {
		if (!is_struct(_nw[_i])) { array_delete(_nw, _i, 1); continue; }
		_nw[_i].left -= _dt;
		if (_nw[_i].left <= 0) array_delete(_nw, _i, 1);
	}
}
