/// @description region_map_sheet(dest, region) -> the region's ground for its map page (q288): the world's terrain sheet cut to the territory's box, the texels outside it dimmed - built once (rg.mbuf), its surface remade when lost (rg.msurf); undefined for a region without a frame or a world without its sheet
function region_map_sheet(_d, _rg) {
	var _tm = _rg[$ "tmap"];
	if (!is_struct(_tm)) return undefined;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (!is_struct(_pn) || !buffer_exists(_pn[$ "tbuf"] ?? -1) || !is_struct(_pn[$ "terr"])) return undefined;
	var _w = _tm.w, _h = _tm.h, _tw = _pn.tw, _th = _pn.th;
	if (!buffer_exists(_rg[$ "mbuf"] ?? -1)) {
		var _mb = buffer_create(_w * _h * 4, buffer_fixed, 1), _tb = _pn.tbuf, _ids = _pn.terr.ids, _id = (_rg[$ "ri"] ?? 0) + 1;
		var _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3];
		for (var _j = 0; _j < _h; _j++) {
			var _y = clamp(_tm.sy + _tm.y0 + _j, 0, _th - 1);
			for (var _i = 0; _i < _w; _i++) {
				var _x = (((_tm.sx + _tm.x0 + _i) mod _tw) + _tw) mod _tw, _si = (_x + _y * _tw) * 4, _di = (_i + _j * _w) * 4;
				var _r = buffer_peek(_tb, _si + _or, buffer_u8), _g = buffer_peek(_tb, _si + _og, buffer_u8), _b = buffer_peek(_tb, _si + _ob, buffer_u8);
				if (_ids[_x + _y * _tw] != _id) { var _lum = (_r * .3 + _g * .59 + _b * .11); _r = round(lerp(_r, _lum, .5) * .38); _g = round(lerp(_g, _lum, .5) * .38); _b = round(lerp(_b, _lum, .5) * .38); }
				buffer_poke(_mb, _di + _or, buffer_u8, _r); buffer_poke(_mb, _di + _og, buffer_u8, _g); buffer_poke(_mb, _di + _ob, buffer_u8, _b); buffer_poke(_mb, _di + _oa, buffer_u8, 255);
			}
		}
		_rg.mbuf = _mb; _rg.msurf = -1;
	}
	if (!surface_exists(_rg[$ "msurf"] ?? -1)) { _rg.msurf = surface_create(_w, _h); buffer_set_surface(_rg.mbuf, _rg.msurf, 0); }
	return _rg.msurf;
}
