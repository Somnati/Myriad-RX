/// @description exped_daylight(trip) -> -1..1: how much sun where the crew stands (< 0 = night)
/// region_daylight for the trip's region. The agent reads it
/// (exped_agent: slow going, wrong turns, a bed when there is coin),
/// the diary marks the crossings.
function exped_daylight(_tr) {
	return region_daylight(_tr.dest, exped_region(_tr));
}
