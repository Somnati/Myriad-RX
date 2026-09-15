/// @description exped_region(trip) -> the region the trip is in (its world, its rgi)
function exped_region(_tr) {
	return region_get(_tr.dest, _tr[$ "rgi"] ?? 0);
}
