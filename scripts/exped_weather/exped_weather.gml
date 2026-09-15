/// @description exped_weather(trip) -> the sky over the crew now: "clear" / "rain" / "snow" / "fog" / "wind" / "storm"
/// region_weather for the trip's region (the agent's read).
function exped_weather(_tr) {
	return region_weather(_tr.dest, exped_region(_tr));
}
