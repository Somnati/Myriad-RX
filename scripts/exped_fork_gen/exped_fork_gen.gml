/// @description exped_fork_gen(trip, region) -> a SHORTCUT fork or undefined - a way through the wild beside the road (q258)
/// At the deciding step, with a path planned: a WILD node next to the
/// crew (mountains / forest / marsh / hills / desert / tundra / coast)
/// that is also next to a node further along the plan - through it is
/// EXPED_SHORTCUT_F of the two roads' hours; the road is the plan's hours
/// to that same node. THE DIVERGENCE RULE (the 09-18 spec): the way
/// through must save forty percent at least, or there is no fork - a
/// choice that means nothing is not offered. The best saving wins when
/// several qualify. The fork carries the weather and the night as they
/// stand (the check reads them), its DC and the party's modifiers, and
/// the two ways as the card shows them
function exped_fork_gen(_tr, _rg) {
	if (!exped_fork_allowed(_tr, _tr.pos)) return undefined;
	var _path = _tr.path, _pos = _tr.pos;
	if (!is_array(_path) || array_length(_path) < 2) return undefined;
	static _wild = ["mountains", "forest", "marsh", "hills", "desert", "tundra", "coast"];
	var _nb = region_neighbors(_rg, _pos), _best = undefined;
	for (var _i = 0; _i < array_length(_nb); _i++) {
		var _x = _nb[_i].j;
		if (array_contains(_path, _x)) continue;
		var _kd = _rg.nodes[_x].kind;
		if (!array_contains(_wild, _kd)) continue;
		var _xn = region_neighbors(_rg, _x);
		var _road = region_hours(_rg, _pos, _path[0]);
		for (var _k = 1; _k < min(4, array_length(_path)); _k++) {
			_road += region_hours(_rg, _path[_k - 1], _path[_k]);
			var _y = _path[_k], _dxy = -1;
			for (var _j = 0; _j < array_length(_xn); _j++) if (_xn[_j].j == _y) _dxy = _xn[_j].d;
			if (_dxy < 0) continue;
			var _thr = max(1, round((_nb[_i].d + _dxy) * EXPED_SHORTCUT_F));
			if (_thr > _road * .6) continue;
			if (is_undefined(_best) || (_road - _thr) > (_best.road - _best.through)) _best = { x : _x, y : _y, k : _k, through : _thr, road : _road, land : _kd };
		}
	}
	if (is_undefined(_best)) return undefined;
	var _wx = region_weather(_tr.dest, _rg), _night = _tr[$ "night"] ?? false;
	var _fk = { kind : "shortcut", at : _pos, x : _best.x, y : _best.y, k : _best.k, through : _best.through, road : _best.road, land : _best.land,
	            wx : _wx, night : _night, born : current_time, held : 0, by : "", chosen : -1 };
	_fk.dc = exped_fork_dc(_fk);
	_fk.mods = exped_fork_mods(_tr, _fk);
	var _via = _rg.nodes[_path[0]].name, _yn = _rg.nodes[_best.y].name, _xn0 = _rg.nodes[_best.x].name;
	_fk.prompt = "the road to " + _yn + " goes round by " + _via + ", " + string(_best.road) + "h. there is a way through " + _xn0 + ", " + string(_best.through) + "h"
	             + ((_wx != "clear") ? ", in the " + _wx : "") + (_night ? ", in the dark" : "") + ".";
	_fk.choices = [ { key : "road", txt : "the road, " + string(_best.road) + "h" }, { key : "through", txt : "through the " + _best.land + ", " + string(_best.through) + "h" } ];
	return _fk;
}
