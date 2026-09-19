/// @description seat_get(dest, ri) -> the villain's SEAT { left, n } (left = seconds of vacancy remaining, n = how many have held it after the first) or undefined when nobody ever ended one (q260)
function seat_get(_d, _ri) {
	exped_init();
	if (!is_struct(g.exped[$ "seat"])) g.exped.seat = {};
	return g.exped.seat[$ lane_key(_d, _ri)];
}
