/// @description crunch_time_ago(datetime);
/// @param datetime
/// HOW LONG AGO, in words: "just now", "14 minutes ago", "yesterday",
/// "3 days ago". Takes a gm datetime real (what date_current_datetime
/// returns and what save_slot_info reads out of a savefile's
/// save_datetime key) and returns "" for 0 - a file old enough to
/// predate the key simply shows no stamp rather than lying about 1899.
///
/// A gm datetime IS days as a real, so the span is a subtraction: no
/// date_*_span call, no argument-order question about which way it
/// counts. A stamp in the FUTURE (the player moved their clock, or a
/// save came off another device) folds to "just now" rather than
/// printing a negative age.
function crunch_time_ago(_dt) {
	if (_dt <= 0) return "";

	var _s = (date_current_datetime() - _dt) * 86400;
	if (_s < 45) return "just now";

	var _m = _s / 60;
	if (_m < 60) {
		var _n = max(1, floor(_m));
		return string(_n) + (_n == 1 ? " minute ago" : " minutes ago");
	}

	var _h = _m / 60;
	if (_h < 24) {
		var _n = floor(_h);
		return string(_n) + (_n == 1 ? " hour ago" : " hours ago");
	}

	var _d = floor(_h / 24);
	if (_d == 1)  return "yesterday";
	if (_d < 30)  return string(_d) + " days ago";

	var _mo = floor(_d / 30);
	if (_mo < 12) return string(_mo) + (_mo == 1 ? " month ago" : " months ago");

	var _y = floor(_d / 365);
	return string(_y) + (_y == 1 ? " year ago" : " years ago");
}
