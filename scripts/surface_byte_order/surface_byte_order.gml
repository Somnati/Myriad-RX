/// @description surface_byte_order() -> [r, g, b, a]: the byte index of each channel in a surface texel, for buffer_set_surface
/// THE CHANNEL PROBE (2026-09-17): buffer_set_surface's byte order is the
/// platform's (learned the hard way in the tech demo). Once, a texel of
/// known bytes goes up and is read back; whichever byte landed in red is
/// red's, and so on; alpha is the byte left over. B G R A (the windows
/// default) if the probe reads nothing it recognises
function surface_byte_order() {
	static _ord = undefined;
	if (is_array(_ord)) return _ord;
	var _ts = surface_create(1, 1), _tb = buffer_create(4, buffer_fixed, 1);
	buffer_write(_tb, buffer_u8, 40); buffer_write(_tb, buffer_u8, 80); buffer_write(_tb, buffer_u8, 120); buffer_write(_tb, buffer_u8, 255);
	buffer_set_surface(_tb, _ts, 0);
	var _c = surface_getpixel(_ts, 0, 0);
	var _vals = [colour_get_red(_c), colour_get_green(_c), colour_get_blue(_c)];
	var _o = [2, 1, 0, 3], _ok = true, _used = [false, false, false, false];
	for (var _ch = 0; _ch < 3; _ch++) {
		var _vv = _vals[_ch], _bi = -1;
		if (abs(_vv - 40) < 6) _bi = 0; else if (abs(_vv - 80) < 6) _bi = 1; else if (abs(_vv - 120) < 6) _bi = 2;
		if (_bi < 0 || _used[_bi]) { _ok = false; break; }
		_o[_ch] = _bi; _used[_bi] = true;
	}
	if (_ok) { for (var _b2 = 0; _b2 < 4; _b2++) if (!_used[_b2]) _o[3] = _b2; } else _o = [2, 1, 0, 3];
	surface_free(_ts); buffer_delete(_tb);
	_ord = _o;
	return _ord;
}
