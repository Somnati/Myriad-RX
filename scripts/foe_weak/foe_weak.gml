/// @description foe_weak(dest, ri, kind) -> the factor a foe of that kind rolled in the region comes in at: FOE_LEADERLESS while its kind is leaderless (its own seat, or the villain's empty one when the faction is its kind), else 1 (q262)
function foe_weak(_d, _ri, _kind) {
	if (_kind == "") return 1;
	var _ss = g.exped[$ "seat"];
	if (!is_struct(_ss)) return 1;
	var _k = lane_key(_d, _ri);
	var _v = _ss[$ _k];
	if (is_struct(_v) && _v.left > 0 && (_v[$ "foe"] ?? "") == _kind) return FOE_LEADERLESS;
	var _s = _ss[$ _k + ":" + _kind];
	if (is_struct(_s) && _s.left > 0) return FOE_LEADERLESS;
	return 1;
}
