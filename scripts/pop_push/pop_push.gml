/// @description pop_push(dest, ri, ni, amt) -> the deviation - a place's population pushed by an event (q284): a raid takes, a fair brings; clamped +-POP_DEV_MAX, decaying back on the expedition clock (pop_tick)
function pop_push(_d, _ri, _ni, _amt) {
	exped_init();
	if (!is_struct(g.exped[$ "pop"])) g.exped.pop = {};
	var _k = lane_key(_d, _ri) + ":" + string(_ni), _r = g.exped.pop[$ _k];
	if (!is_struct(_r)) { _r = { d : 0 }; g.exped.pop[$ _k] = _r; }
	_r.d = clamp(_r.d + _amt, -POP_DEV_MAX, POP_DEV_MAX);
	save_mark_dirty();
	return _r.d;
}
