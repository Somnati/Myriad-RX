/// @description planet_lod_focus(l, v) - THE TIER'S FOCUS (q270; his ask: "prioritize generating the high res terrain for areas the camera is centered on"): the rows still to build re-sorted nearest the focus latitude v (0..1 down the map) first
/// The rows done stay done (order[0 .. row)); the tail is sorted by its
/// distance to the focus row. Called at begin (the equator) and by
/// TierKeep.step whenever the page's focus moves a twentieth of the map
function planet_lod_focus(_l, _v) {
	_l.focus_v = clamp(_v, 0, 1);
	if (_l.ready) return;
	var _fr = _l.focus_v * _l.h;
	var _done = [];
	for (var _i = 0; _i < _l.row; _i++) array_push(_done, _l.order[_i]);
	var _have = array_create(_l.h, false);
	for (var _i = 0; _i < array_length(_done); _i++) _have[_done[_i]] = true;
	var _tail = [];
	for (var _r = 0; _r < _l.h; _r++) if (!_have[_r]) array_push(_tail, { r : _r, d : abs(_r + .5 - _fr) });
	array_sort(_tail, function(_a, _b) { return _a.d - _b.d; });
	var _order = _done;
	for (var _i = 0; _i < array_length(_tail); _i++) array_push(_order, _tail[_i].r);
	_l.order = _order;
}
