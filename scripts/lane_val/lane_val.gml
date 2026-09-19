/// @description lane_val(dest, ri, lane) -> the lane's deviation from the region's average, -1..1 (0 when the region is at rest) (q259)
function lane_val(_d, _ri, _lane) {
	var _r = lane_get(_d, _ri, false);
	if (!is_struct(_r)) return 0;
	return _r[$ _lane] ?? 0;
}
