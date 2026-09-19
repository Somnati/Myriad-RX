/// @description seat_open_kind(dest, ri, kind, region) - A KIND'S LEADER SLAIN (its chief, its alpha): the kind is leaderless in the region for LEAD_DAYS world days over the weight - a longer spell is kept, a shorter one refreshed (q262)
function seat_open_kind(_d, _ri, _kind, _rg) {
	exped_init();
	if (_kind == "") return;
	if (!is_struct(g.exped[$ "seat"])) g.exped.seat = {};
	var _k = lane_key(_d, _ri) + ":" + _kind;
	var _left = clamp(LEAD_DAYS / region_weight(_rg), 1, 10) * 24 * EXPED_HOUR;
	var _s = g.exped.seat[$ _k];
	if (is_struct(_s) && _s.left > _left) return;
	g.exped.seat[$ _k] = { left : _left, n : 0, kind : _kind };
	save_mark_dirty();
}
