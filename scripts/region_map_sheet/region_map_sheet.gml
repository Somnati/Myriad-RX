/// @description region_map_sheet(dest, region, [tier]) -> the region's ground for its map page (q288 / q311): the world's terrain cut to the territory's box - from the ZOOM TIER when it stands whole (two sheet texels a map texel), the map's own texels otherwise - with a hillshade from the heights, the sea's depth, the woods' grain, the ground past the territory greyed, and the territory's own line in its colour. Built once a source (rg.mbuf, rg.mks the sheet's texels a map texel), its surface remade when lost (rg.msurf)
function region_map_sheet(_d, _rg, _tier = undefined) {
	var _tm = _rg[$ "tmap"];
	if (!is_struct(_tm)) return undefined;
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (!is_struct(_pn) || !buffer_exists(_pn[$ "tbuf"] ?? -1) || !buffer_exists(_pn[$ "hbuf"] ?? -1) || !is_struct(_pn[$ "terr"])) return undefined;
	var _tw = _pn.tw, _th = _pn.th;
	// the source: the tier's sheets when the tier stands whole, else the map's own
	var _use = is_struct(_tier) && (_tier[$ "ready"] ?? false) && buffer_exists(_tier[$ "tbuf"] ?? -1) && buffer_exists(_tier[$ "hbuf"] ?? -1) && (_tier[$ "k"] ?? 1) >= 2;
	var _ks = _use ? 2 : 1, _tk = _use ? _tier.k : 1;   // (sheet texels a map texel; source texels a map texel)
	var _w = _tm.w * _ks, _h = _tm.h * _ks;
	if (!buffer_exists(_rg[$ "mbuf"] ?? -1) || (_rg[$ "mks"] ?? 0) != _ks) {
		if (buffer_exists(_rg[$ "mbuf"] ?? -1)) buffer_delete(_rg.mbuf);
		if (surface_exists(_rg[$ "msurf"] ?? -1)) surface_free(_rg.msurf);
		var _mb = buffer_create(_w * _h * 4, buffer_fixed, 1);
		var _tb = _use ? _tier.tbuf : _pn.tbuf, _hb = _use ? _tier.hbuf : _pn.hbuf, _sw = _tw * _tk, _sh = _th * _tk;
		var _ids = _pn.terr.ids, _el = _pn.elev, _sea = _pn.sea, _id = (_rg[$ "ri"] ?? 0) + 1;
		var _ord = surface_byte_order(), _or = _ord[0], _og = _ord[1], _ob = _ord[2], _oa = _ord[3];
		var _hgt = function(_hb0, _sx, _sy, _sw0, _sh0, _or0) { _sx = ((_sx mod _sw0) + _sw0) mod _sw0; _sy = clamp(_sy, 0, _sh0 - 1); return buffer_peek(_hb0, (_sx + _sy * _sw0) * 4 + _or0, buffer_u8); };
		for (var _j = 0; _j < _h; _j++) {
			var _by = _tm.sy + _tm.y0 + _j / _ks, _yb = clamp(floor(_by), 0, _th - 1), _sy = clamp(floor(_by * _tk), 0, _sh - 1);
			for (var _i = 0; _i < _w; _i++) {
				var _bx = _tm.sx + _tm.x0 + _i / _ks, _xb = ((floor(_bx) mod _tw) + _tw) mod _tw, _sx = ((floor(_bx * _tk) mod _sw) + _sw) mod _sw;
				var _si = (_sx + _sy * _sw) * 4, _di = (_i + _j * _w) * 4;
				var _r = buffer_peek(_tb, _si + _or, buffer_u8), _g = buffer_peek(_tb, _si + _og, buffer_u8), _b = buffer_peek(_tb, _si + _ob, buffer_u8);
				var _hg = buffer_peek(_hb, _si + _og, buffer_u8), _hbl = buffer_peek(_hb, _si + _ob, buffer_u8);
				var _wat = (_hg > 127), _mine = (_ids[_xb + _yb * _tw] == _id);
				if (_wat) {
					// THE SEA'S DEPTH (the shader's law): the texel's own colour at the shore, toward the deep past a third of the way down
					var _dp = clamp((_hbl / 255 - .1) / .5, 0, 1);
					_r = round(lerp(_r, 12, _dp * .55)); _g = round(lerp(_g, 34, _dp * .55)); _b = round(lerp(_b, 92, _dp * .45));
				} else {
					// THE HILLSHADE: the height's slope toward the upper left (the sphere's light) - lit faces lighter, shaded darker
					var _hl = _hgt(_hb, _sx - 1, _sy, _sw, _sh, _or), _hr2 = _hgt(_hb, _sx + 1, _sy, _sw, _sh, _or), _hu = _hgt(_hb, _sx, _sy - 1, _sw, _sh, _or), _hd = _hgt(_hb, _sx, _sy + 1, _sw, _sh, _or);
					var _shd = clamp(1 + (((_hl - _hr2) + (_hu - _hd)) / 255) * (_use ? 3.2 : 1.6), .62, 1.38);
					// THE WOODS' GRAIN: a wood's texel lit or shaded by its own hash - the pixel forest, at the sheet's grain
					if (_hbl > 60) { var _hh = hash_mix(_xb * 7 + _i, _yb * 13 + _j) mod 100; _shd *= lerp(1, (_hh < 38) ? 1.12 : ((_hh < 70) ? .86 : 1.0), clamp(_hbl / 255, 0, 1)); }
					_r = round(clamp(_r * _shd, 0, 255)); _g = round(clamp(_g * _shd, 0, 255)); _b = round(clamp(_b * _shd, 0, 255));
				}
				if (!_mine) {
					// past the territory: the sea a little dimmer, the land greyed and dark - the region's own ground leads
					if (_wat) { _r = round(_r * .62); _g = round(_g * .62); _b = round(_b * .66); }
					else { var _lum = (_r * .3 + _g * .59 + _b * .11); _r = round(lerp(_r, _lum, .55) * .42); _g = round(lerp(_g, _lum, .55) * .42); _b = round(lerp(_b, _lum, .55) * .42); }
				}
				buffer_poke(_mb, _di + _or, buffer_u8, _r); buffer_poke(_mb, _di + _og, buffer_u8, _g); buffer_poke(_mb, _di + _ob, buffer_u8, _b); buffer_poke(_mb, _di + _oa, buffer_u8, 255);
			}
		}
		// THE TERRITORY'S LINE in its colour: the .5 contour of the membership (the region's own LAND) over the map's texel
		// centres - the world's chamfered contour, on the sheet - a sheet texel wide, inside
		var _rc = region_col(_d, _rg[$ "ri"] ?? 0), _rcr = colour_get_red(_rc), _rcg = colour_get_green(_rc), _rcb = colour_get_blue(_rc);
		var _mem = function(_cx, _cy, _ids0, _el0, _sea0, _id0, _tw0, _th0) { if (_cy < 0 || _cy >= _th0) return 0; var _ii = (((_cx mod _tw0) + _tw0) mod _tw0) + _cy * _tw0; return (_ids0[_ii] == _id0 && _el0[_ii] >= _sea0) ? 1 : 0; };
		for (var _j = 0; _j < _h; _j++) {
			var _py = _tm.sy + _tm.y0 + (_j + .5) / _ks - .5, _piy = floor(_py), _pfy = _py - _piy;
			for (var _i = 0; _i < _w; _i++) {
				var _px = _tm.sx + _tm.x0 + (_i + .5) / _ks - .5, _pix = floor(_px), _pfx = _px - _pix;
				var _m00 = _mem(_pix, _piy, _ids, _el, _sea, _id, _tw, _th), _m10 = _mem(_pix + 1, _piy, _ids, _el, _sea, _id, _tw, _th), _m01 = _mem(_pix, _piy + 1, _ids, _el, _sea, _id, _tw, _th), _m11 = _mem(_pix + 1, _piy + 1, _ids, _el, _sea, _id, _tw, _th);
				if (_m00 + _m10 + _m01 + _m11 == 0 || _m00 + _m10 + _m01 + _m11 == 4) continue;
				var _F = lerp(lerp(_m00, _m10, _pfx), lerp(_m01, _m11, _pfx), _pfy);
				if (_F < .5) continue;
				var _gx = lerp(_m10 - _m00, _m11 - _m01, _pfy), _gy = lerp(_m01 - _m00, _m11 - _m10, _pfx);
				var _dd = (_F - .5) / max(sqrt(_gx * _gx + _gy * _gy), .08);
				if (_dd >= .95 / _ks) continue;
				var _di2 = (_i + _j * _w) * 4;
				buffer_poke(_mb, _di2 + _or, buffer_u8, _rcr); buffer_poke(_mb, _di2 + _og, buffer_u8, _rcg); buffer_poke(_mb, _di2 + _ob, buffer_u8, _rcb);
			}
		}
		_rg.mbuf = _mb; _rg.mks = _ks; _rg.msurf = -1;
	}
	if (!surface_exists(_rg[$ "msurf"] ?? -1)) { _rg.msurf = surface_create(_w, _h); buffer_set_surface(_rg.mbuf, _rg.msurf, 0); }
	return _rg.msurf;
}
