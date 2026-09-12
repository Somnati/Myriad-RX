/// @description autom_ago(at) -> "4s ago" / "2m ago" / "1h ago"
/// @param at   a current_time stamp
function autom_ago(_at) {
	var _s = max(0, (current_time - _at) / 1000);
	if (_s < 60)   return string(floor(_s)) + "s ago";
	if (_s < 3600) return string(floor(_s / 60)) + "m ago";
	return string(floor(_s / 3600)) + "h ago";
}
