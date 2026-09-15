/// @description star_visible(camx, camy, zoom, vw, vh) -> the star indices near a view (the draw grid)
/// The tech demo's scr_star_visible: only the cells the (parallax-padded)
/// view touches, so the per-frame cost tracks what is visible
function star_visible(_camx, _camy, _zoom, _vw, _vh) {
	var _sm = starmap_get();
	var _hw = _vw * .5 / _zoom;
	var _hh = _vh * .5 / _zoom;
	var _vcx = _camx + _hw;
	var _vcy = _camy + _hh;
	var _pad = max(_hw, _hh) * .18 + 24 / _zoom + 8;
	var _dc  = _sm.dcell;
	var _cx0 = clamp(floor((_vcx - _hw - _pad) / _dc), 0, _sm.dgw - 1);
	var _cx1 = clamp(floor((_vcx + _hw + _pad) / _dc), 0, _sm.dgw - 1);
	var _cy0 = clamp(floor((_vcy - _hh - _pad) / _dc), 0, _sm.dgh - 1);
	var _cy1 = clamp(floor((_vcy + _hh + _pad) / _dc), 0, _sm.dgh - 1);
	var _out = [];
	for (var _gy = _cy0; _gy <= _cy1; _gy++)
	for (var _gx = _cx0; _gx <= _cx1; _gx++) {
		var _lst = _sm.dgrid[_gx + _gy * _sm.dgw];
		for (var _n = 0; _n < array_length(_lst); _n++) array_push(_out, _lst[_n]);
	}
	return _out;
}
