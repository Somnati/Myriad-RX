/// @description lane_push(dest, ri, lane, amount) -> the lane's new value - a crew's deed on a region, divided by its weight (q259)
/// +amount lifts the lane, -amount lowers it; clamped -1..1. The one way
/// a lane ever moves off its rest but the tick's coupling. Marks the save
function lane_push(_d, _ri, _lane, _amt) {
	var _r = lane_get(_d, _ri, true);
	var _v = clamp((_r[$ _lane] ?? 0) + _amt / max(.1, _r.w), -1, 1);
	_r[$ _lane] = _v;
	save_mark_dirty();
	return _v;
}
