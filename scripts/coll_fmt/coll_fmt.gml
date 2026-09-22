/// @description coll_fmt(lv) -> a LOG10 value in scientific dress (the framework's __fmt): "0" at the sentinel, plain under a thousand, m.mmeN past it
function coll_fmt(_lv) {
	if (_lv <= -8) return "0";
	if (_lv < 3) return string(round(power(10, _lv) * 10) / 10);
	var _e = floor(_lv), _m = round(power(10, _lv - _e) * 100) / 100;
	if (_m >= 10) { _m /= 10; _e++; }
	return string(_m) + "e" + string(_e);
}
