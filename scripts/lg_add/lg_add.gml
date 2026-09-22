/// @description lg_add(a, b) -> log10(10^a + 10^b): log-sum-exp with the bigger term peeled out; past 15 decades apart the small one is below double precision
function lg_add(_a, _b) {
	if (_a < _b) { var _t = _a; _a = _b; _b = _t; }
	if (_a - _b > 15) return _a;
	return _a + log10(1 + power(10, _b - _a));
}
