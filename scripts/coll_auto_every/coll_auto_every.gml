/// @description coll_auto_every(lv) -> the auto-collider's interval in seconds at that level (0 = off)
function coll_auto_every(_lv) {
	static _t = [0, 60, 30, 15];   // (a 3-second level was a trap on the twin: the stocks never compound)
	return _t[clamp(_lv, 0, 3)];
}
