/// @description lane_words(dest, ri) -> [{ v, t, col }] the region's live words for its card: every lane a quarter or more off its rest, strongest first (q259)
/// "the roads quieter" / "the roads worse", "trade up" / "trade down",
/// "the dead quiet" / "the dead restless", "welcomed" / "unwelcome",
/// "the beasts thin" / "the beasts back", "the villain's grip loosened" /
/// "tightened" - each with "(fading)" since every deviation fades
function lane_words(_d, _ri) {
	var _r = lane_get(_d, _ri, false), _out = [];
	if (!is_struct(_r)) return _out;
	static _w = {
		order   : [ "the roads worse",           "the roads quieter" ],
		wild    : [ "the beasts thin",           "the beasts back" ],
		trade   : [ "trade down",                "trade up" ],
		faith   : [ "the dead restless",         "the dead quiet" ],
		welcome : [ "unwelcome here",            "welcomed here" ],
		dread   : [ "the villain's grip loosened", "the villain's grip tightened" ],
	};
	static _bad = { order : 0, wild : 1, trade : 0, faith : 0, welcome : 0, dread : 1 };   // (which sign is the bad one: t 2 = amber)
	var _nm = lane_names(), _rows = [];
	for (var _j = 0; _j < array_length(_nm); _j++) {
		var _v = _r[$ _nm[_j]] ?? 0;
		if (abs(_v) < .25) continue;
		var _up = (_v > 0);
		var _isbad = (_bad[$ _nm[_j]] == 1) ? _up : !_up;
		array_push(_rows, { a : abs(_v), v : _w[$ _nm[_j]][_up ? 1 : 0] + ((abs(_v) >= .6) ? " (for now)" : " (fading)"), t : _isbad ? 2 : 0, col : _isbad ? c_horange : c_seagreen });
	}
	array_sort(_rows, function(_a, _b) { return _b.a - _a.a; });
	for (var _i = 0; _i < min(3, array_length(_rows)); _i++) array_push(_out, _rows[_i]);
	return _out;
}
