/// @description lane_get(dest, ri, [make]) -> the region's lane record { order, wild, trade, faith, welcome, dread, w } or undefined - THE WORLD REMEMBERS THE SUM (q259)
/// A record exists only while the region is out of balance; make = true
/// creates one at rest (with the region's weight) for a push to land on
function lane_get(_d, _ri, _make = false) {
	exped_init();
	if (!is_struct(g.exped[$ "lanes"])) g.exped.lanes = {};
	var _k = lane_key(_d, _ri);
	var _r = g.exped.lanes[$ _k];
	if (is_struct(_r) || !_make) return _r;
	_r = { order : 0, wild : 0, trade : 0, faith : 0, welcome : 0, dread : 0, w : region_weight(region_get(_d, _ri)) };
	g.exped.lanes[$ _k] = _r;
	return _r;
}
