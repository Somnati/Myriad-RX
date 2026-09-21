/// @description delta_hex(arr, lo, hi, digits) -> arr packed as hex, digits (1 or 2) a value, lo..hi scaled; delta_unhex(str, arr, lo, hi, digits) reads it back
function delta_hex(_a, _lo, _hi, _dg) {
	static _hx = "0123456789abcdef";
	var _n = array_length(_a), _m = (_dg == 2) ? 255 : 15, _out = "";
	for (var _i = 0; _i < _n; _i++) {
		var _v = clamp(round((_a[_i] - _lo) / (_hi - _lo) * _m), 0, _m);
		if (_dg == 2) _out += string_char_at(_hx, (_v >> 4) + 1) + string_char_at(_hx, (_v & 15) + 1);
		else _out += string_char_at(_hx, _v + 1);
	}
	return _out;
}
function delta_unhex(_s, _a, _lo, _hi, _dg) {
	var _n = array_length(_a), _m = (_dg == 2) ? 255 : 15;
	if (string_length(_s) < _n * _dg) return false;
	var _hv = function(_c) { var _o = ord(_c); if (_o >= 48 && _o <= 57) return _o - 48; if (_o >= 97 && _o <= 102) return _o - 87; return 0; };
	for (var _i = 0; _i < _n; _i++) {
		var _v = (_dg == 2) ? (_hv(string_char_at(_s, _i * 2 + 1)) << 4) + _hv(string_char_at(_s, _i * 2 + 2)) : _hv(string_char_at(_s, _i + 1));
		_a[_i] = _lo + (_v / _m) * (_hi - _lo);
	}
	return true;
}
