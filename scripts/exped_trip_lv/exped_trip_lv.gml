/// @description exped_trip_lv(trip) -> the level of the region the trip walks (its foes, its gear)
function exped_trip_lv(_tr) {
	return exped_region(_tr).lv;
}
