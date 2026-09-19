/// @description seat_open(dest, ri, region) - THE VILLAIN ENDED: the seat falls vacant for SEAT_DAYS world days over the region's weight (a hamlet region a fortnight, a city's faction two days), the succession count up (q260)
function seat_open(_d, _ri, _rg, _foe = "") {   // (foe: the faction's kind - leaderless, .9, the whole vacancy; q262)
	exped_init();
	if (!is_struct(g.exped[$ "seat"])) g.exped.seat = {};
	var _k = lane_key(_d, _ri), _s = g.exped.seat[$ _k];
	var _days = clamp(SEAT_DAYS / region_weight(_rg), 1, 14);
	g.exped.seat[$ _k] = { left : _days * 24 * EXPED_HOUR, n : (is_struct(_s) ? _s.n : 0) + 1, foe : _foe };
	_rg.villain_c = false;   // (region_villain answers afresh: nobody, while the seat is empty)
	save_mark_dirty();
}
