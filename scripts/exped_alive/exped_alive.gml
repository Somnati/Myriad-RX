/// @description exped_alive(trip) -> how many of the crew are still up
/// (hp above zero). Zero = the trip is routed.
function exped_alive(_tr) {
	var _n = 0;
	for (var _i = 0; _i < array_length(_tr.hp); _i++) if (_tr.hp[_i] > 0) _n++;
	return _n;
}
